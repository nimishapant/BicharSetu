import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'model/comment_model.dart';
import 'repo/auth_service.dart';
import 'theme/bichar_theme_extension.dart';

const _reactions = [
  CommentReaction.like,
  CommentReaction.love,
  CommentReaction.laugh,
  CommentReaction.wow,
  CommentReaction.sad,
  CommentReaction.angry,
];

// ─── Sheet ───────────────────────────────────────────────────────────────────

class CommentSheet extends StatefulWidget {
  const CommentSheet({super.key, required this.postId});
  final String postId;

  static Future<void> show(BuildContext context, String postId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => CommentSheet(postId: postId),
    );
  }

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();
  bool _submitting = false;
  bool _uploadingImage = false;
  File? _pendingImage;

  // When replying, these are set
  CommentModel? _replyingTo;

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _startReply(CommentModel comment) {
    setState(() {
      _replyingTo = comment;
      _ctrl.text = '@${comment.username} ';
    });
    _ctrl.selection =
        TextSelection.fromPosition(TextPosition(offset: _ctrl.text.length));
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
      _ctrl.clear();
    });
    _focusNode.unfocus();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (picked == null || !mounted) return;
    setState(() => _pendingImage = File(picked.path));
  }

  void _removePendingImage() => setState(() => _pendingImage = null);

  bool get _canSend =>
      _ctrl.text.trim().isNotEmpty || _pendingImage != null;

  Future<void> _submit() async {
    if (!_canSend || _submitting) return;
    setState(() => _submitting = true);

    try {
      final user = await AuthService().getCurrentUserModel();
      if (user == null || !mounted) return;

      String imageUrl = '';
      if (_pendingImage != null) {
        setState(() => _uploadingImage = true);
        imageUrl = await AuthService().uploadCommentImage(_pendingImage!);
        if (!mounted) return;
        setState(() => _uploadingImage = false);
      }

      if (_replyingTo != null) {
        // Post as a reply
        final reply = CommentModel(
          commentId: const Uuid().v4(),
          postId: widget.postId,
          uid: user.uid,
          username: user.username,
          profilePhoto: user.profilePhoto,
          text: _ctrl.text.trim(),
          imageUrl: imageUrl,
          parentId: _replyingTo!.commentId,
          replyToUsername: _replyingTo!.username,
          createdAt: DateTime.now(),
        );
        await AuthService().addReply(reply);
      } else {
        // Post as a top-level comment
        final comment = CommentModel(
          commentId: const Uuid().v4(),
          postId: widget.postId,
          uid: user.uid,
          username: user.username,
          profilePhoto: user.profilePhoto,
          text: _ctrl.text.trim(),
          imageUrl: imageUrl,
          createdAt: DateTime.now(),
        );
        await AuthService().addComment(comment);
      }

      if (!mounted) return;
      _ctrl.clear();
      _focusNode.unfocus();
      setState(() {
        _pendingImage = null;
        _replyingTo = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text('Failed to post: $e'),
      ));
    } finally {
      if (mounted) setState(() { _submitting = false; _uploadingImage = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
      decoration: BoxDecoration(
        color: bichar.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40, height: 4,
              decoration: BoxDecoration(color: bichar.border, borderRadius: BorderRadius.circular(2)),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
              child: Row(children: [
                Text('Comments', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: bichar.textPrimary)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop(), color: bichar.textSecondary),
              ]),
            ),
            Divider(height: 1, color: bichar.border.withValues(alpha: 0.7)),

            // Comment list
            Flexible(
              child: StreamBuilder<List<CommentModel>>(
                stream: AuthService().getCommentsStream(widget.postId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: bichar.accent)),
                    );
                  }
                  final comments = snapshot.data ?? [];
                  if (comments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 48, color: bichar.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('No comments yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: bichar.textPrimary)),
                        const SizedBox(height: 6),
                        Text('Be the first to share your thoughts.', style: TextStyle(fontSize: 13, color: bichar.textSecondary)),
                      ]),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollCtrl,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: comments.length,
                    itemBuilder: (context, index) => _CommentTile(
                      comment: comments[index],
                      postId: widget.postId,
                      onReply: _startReply,
                    ),
                  );
                },
              ),
            ),

            Divider(height: 1, color: bichar.border.withValues(alpha: 0.7)),

            // Replying-to banner
            if (_replyingTo != null)
              Container(
                color: bichar.accent.withValues(alpha: 0.07),
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(children: [
                  Icon(Icons.reply_rounded, size: 16, color: bichar.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to @${_replyingTo!.username}',
                      style: TextStyle(fontSize: 13, color: bichar.accent, fontWeight: FontWeight.w600),
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: Icon(Icons.close_rounded, size: 18, color: bichar.textSecondary),
                  ),
                ]),
              ),

            // Pending image preview
            if (_pendingImage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_pendingImage!, height: 100, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 6, right: 6,
                    child: GestureDetector(
                      onTap: _removePendingImage,
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ]),
              ),

            // Input row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(padding: const EdgeInsets.all(8),
                      child: Icon(Icons.image_outlined, size: 24, color: bichar.textSecondary)),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: bichar.searchFieldBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: bichar.border),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focusNode,
                      maxLines: 4, minLines: 1,
                      textInputAction: TextInputAction.newline,
                      style: TextStyle(fontSize: 15, color: bichar.textPrimary),
                      decoration: InputDecoration(
                        hintText: _replyingTo != null ? 'Write a reply…' : 'Add a comment…',
                        hintStyle: TextStyle(color: bichar.textSecondary, fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedOpacity(
                  opacity: _canSend ? 1.0 : 0.35,
                  duration: const Duration(milliseconds: 180),
                  child: Material(
                    color: bichar.accent, shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _canSend ? _submit : null,
                      child: SizedBox(width: 44, height: 44,
                        child: (_submitting || _uploadingImage)
                            ? const Padding(padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Comment tile ─────────────────────────────────────────────────────────────

class _CommentTile extends StatefulWidget {
  const _CommentTile({
    required this.comment,
    required this.postId,
    required this.onReply,
  });
  final CommentModel comment;
  final String postId;
  final void Function(CommentModel) onReply;

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _showReplies = false;

  Color _avatarColor(String name) {
    const colors = [Color(0xFF7C4DFF), Color(0xFF00897B), Color(0xFFE91E8C), Color(0xFF1565C0), Color(0xFF6A3DE8)];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isMe = AuthService().currentUid == widget.comment.uid;
    final myUid = AuthService().currentUid ?? '';

    CommentReaction? myReaction;
    for (final r in _reactions) {
      if (widget.comment.reactions[r.name]?.contains(myUid) == true) { myReaction = r; break; }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Avatar
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _avatarColor(widget.comment.username)),
            clipBehavior: Clip.antiAlias,
            child: widget.comment.profilePhoto.isNotEmpty
                ? Image.network(widget.comment.profilePhoto, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Initial(name: widget.comment.username))
                : _Initial(name: widget.comment.username),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(
                  widget.comment.username.isNotEmpty
                      ? widget.comment.username[0].toUpperCase() + widget.comment.username.substring(1)
                      : '',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: bichar.textPrimary),
                ),
                const SizedBox(width: 6),
                Text(widget.comment.timeAgo, style: TextStyle(fontSize: 12, color: bichar.textSecondary)),
                const Spacer(),
                if (isMe)
                  GestureDetector(
                    onTap: () async {
                      try { await AuthService().deleteComment(postId: widget.comment.postId, commentId: widget.comment.commentId); }
                      catch (_) {}
                    },
                    child: Icon(Icons.close_rounded, size: 16, color: bichar.textSecondary),
                  ),
              ]),
              const SizedBox(height: 4),
              if (widget.comment.text.isNotEmpty)
                Text(widget.comment.text, style: TextStyle(fontSize: 14, height: 1.4, color: bichar.textPrimary)),
              if (widget.comment.imageUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(12),
                  child: Image.network(widget.comment.imageUrl, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink())),
              ],
              const SizedBox(height: 8),
              // Reaction bar + Reply button
              Row(children: [
                _ReactionBar(comment: widget.comment, myReaction: myReaction),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => widget.onReply(widget.comment),
                  child: Text('Reply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: bichar.textSecondary)),
                ),
              ]),
            ]),
          ),
        ]),

        // Show/hide replies
        if (widget.comment.replyCount > 0)
          Padding(
            padding: const EdgeInsets.only(left: 46, top: 6),
            child: GestureDetector(
              onTap: () => setState(() => _showReplies = !_showReplies),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  _showReplies ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  size: 18, color: bichar.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  _showReplies ? 'Hide replies' : '${widget.comment.replyCount} ${widget.comment.replyCount == 1 ? 'reply' : 'replies'}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: bichar.accent),
                ),
              ]),
            ),
          ),

        // Replies list
        if (_showReplies)
          Padding(
            padding: const EdgeInsets.only(left: 46, top: 4),
            child: StreamBuilder<List<CommentModel>>(
              stream: AuthService().getRepliesStream(widget.postId, widget.comment.commentId),
              builder: (context, snap) {
                final replies = snap.data ?? [];
                return Column(
                  children: replies.map((r) => _ReplyTile(
                    reply: r,
                    postId: widget.postId,
                    parentCommentId: widget.comment.commentId,
                    onReply: widget.onReply,
                  )).toList(),
                );
              },
            ),
          ),

        Divider(height: 1, color: bichar.border.withValues(alpha: 0.4)),
      ]),
    );
  }
}

// ─── Reply tile ───────────────────────────────────────────────────────────────

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({
    required this.reply,
    required this.postId,
    required this.parentCommentId,
    required this.onReply,
  });
  final CommentModel reply;
  final String postId;
  final String parentCommentId;
  final void Function(CommentModel) onReply;

  Color _avatarColor(String name) {
    const colors = [Color(0xFF7C4DFF), Color(0xFF00897B), Color(0xFFE91E8C), Color(0xFF1565C0), Color(0xFF6A3DE8)];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isMe = AuthService().currentUid == reply.uid;
    final myUid = AuthService().currentUid ?? '';

    CommentReaction? myReaction;
    for (final r in _reactions) {
      if (reply.reactions[r.name]?.contains(myUid) == true) { myReaction = r; break; }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _avatarColor(reply.username)),
          clipBehavior: Clip.antiAlias,
          child: reply.profilePhoto.isNotEmpty
              ? Image.network(reply.profilePhoto, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _Initial(name: reply.username))
              : _Initial(name: reply.username),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(
                reply.username.isNotEmpty
                    ? reply.username[0].toUpperCase() + reply.username.substring(1)
                    : '',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: bichar.textPrimary),
              ),
              const SizedBox(width: 6),
              Text(reply.timeAgo, style: TextStyle(fontSize: 11, color: bichar.textSecondary)),
              const Spacer(),
              if (isMe)
                GestureDetector(
                  onTap: () async {
                    try {
                      await AuthService().deleteReply(
                        postId: postId,
                        parentCommentId: parentCommentId,
                        replyId: reply.commentId,
                      );
                    } catch (_) {}
                  },
                  child: Icon(Icons.close_rounded, size: 14, color: bichar.textSecondary),
                ),
            ]),
            const SizedBox(height: 3),
            // Show @mention in accent color
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, height: 1.4, color: bichar.textPrimary),
                children: _buildReplyText(reply.text, bichar.accent),
              ),
            ),
            if (reply.imageUrl.isNotEmpty) ...[
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(10),
                child: Image.network(reply.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink())),
            ],
            const SizedBox(height: 6),
            Row(children: [
              _ReactionBar(
                comment: reply,
                myReaction: myReaction,
                parentCommentId: parentCommentId,
                isReply: true,
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => onReply(reply),
                child: Text('Reply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: bichar.textSecondary)),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  List<TextSpan> _buildReplyText(String text, Color accentColor) {
    final mentionRegex = RegExp(r'(@\w+)');
    final spans = <TextSpan>[];
    int last = 0;
    for (final match in mentionRegex.allMatches(text)) {
      if (match.start > last) spans.add(TextSpan(text: text.substring(last, match.start)));
      spans.add(TextSpan(text: match.group(0), style: TextStyle(color: accentColor, fontWeight: FontWeight.w700)));
      last = match.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return spans;
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _Initial extends StatelessWidget {
  const _Initial({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) => Center(
    child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
  );
}

// ─── Reaction bar ─────────────────────────────────────────────────────────────

class _ReactionBar extends StatefulWidget {
  const _ReactionBar({
    required this.comment,
    required this.myReaction,
    this.parentCommentId = '',
    this.isReply = false,
  });
  final CommentModel comment;
  final CommentReaction? myReaction;
  final String parentCommentId;
  final bool isReply;

  @override
  State<_ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<_ReactionBar> with SingleTickerProviderStateMixin {
  bool _pickerVisible = false;
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  void _togglePicker() {
    if (_pickerVisible) {
      _animCtrl.reverse().then((_) { if (mounted) setState(() => _pickerVisible = false); });
    } else {
      setState(() => _pickerVisible = true);
      _animCtrl.forward(from: 0);
    }
  }

  void _closePicker() {
    _animCtrl.reverse().then((_) { if (mounted) setState(() => _pickerVisible = false); });
  }

  void _react(CommentReaction r) {
    _closePicker();
    AuthService().toggleCommentReaction(
      postId: widget.comment.postId,
      commentId: widget.comment.commentId,
      reactionType: r.name,
      parentCommentId: widget.parentCommentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final myReaction = widget.myReaction;
    final total = widget.comment.totalReactions;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        GestureDetector(
          onTap: _togglePicker,
          onLongPress: () => _react(CommentReaction.like),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: myReaction != null
                  ? bichar.accent.withValues(alpha: 0.12)
                  : bichar.searchFieldBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: myReaction != null
                    ? bichar.accent.withValues(alpha: 0.4)
                    : bichar.border.withValues(alpha: 0.5),
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(myReaction != null ? myReaction.emoji : '👍',
                  style: TextStyle(fontSize: widget.isReply ? 13 : 15)),
              if (total > 0) ...[
                const SizedBox(width: 4),
                Text('$total', style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: myReaction != null ? bichar.accent : bichar.textSecondary,
                )),
              ],
            ]),
          ),
        ),
        const SizedBox(width: 6),
        if (total > 0) _TopReactionBubbles(reactions: widget.comment.reactions),
      ]),

      // Inline animated emoji picker
      if (_pickerVisible)
        FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: bichar.cardBackground,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: bichar.border.withValues(alpha: 0.8)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _reactions.map((r) {
                  final isSelected = myReaction == r;
                  return GestureDetector(
                    onTap: () => _react(r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isSelected ? bichar.accent.withValues(alpha: 0.15) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        AnimatedScale(
                          scale: isSelected ? 1.25 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Text(r.emoji, style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(height: 2),
                        Text(r.label, style: TextStyle(
                          fontSize: 9,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? bichar.accent : bichar.textSecondary,
                        )),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
    ]);
  }
}

class _TopReactionBubbles extends StatelessWidget {
  const _TopReactionBubbles({required this.reactions});
  final Map<String, List<String>> reactions;

  @override
  Widget build(BuildContext context) {
    final sorted = reactions.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    final top = sorted.take(3).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: top.asMap().entries.map((e) {
        final r = CommentReaction.values.firstWhere((x) => x.name == e.value.key, orElse: () => CommentReaction.like);
        return Transform.translate(
          offset: Offset(-(e.key * 5.0), 0),
          child: Text(r.emoji, style: const TextStyle(fontSize: 12)),
        );
      }).toList(),
    );
  }
}
