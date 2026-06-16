import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'model/comment_model.dart';
import 'repo/auth_service.dart';
import 'theme/bichar_theme_extension.dart';

/// Bottom sheet for viewing and adding comments on a post.
class CommentSheet extends StatefulWidget {
  const CommentSheet({super.key, required this.postId});

  final String postId;

  /// Show the comment sheet as a modal bottom sheet.
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
  bool _submitting = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _submitting) return;

    setState(() => _submitting = true);
    try {
      final user = await AuthService().getCurrentUserModel();
      if (user == null) return;

      final comment = CommentModel(
        commentId: const Uuid().v4(),
        postId: widget.postId,
        uid: user.uid,
        username: user.username,
        profilePhoto: user.profilePhoto,
        text: text,
        createdAt: DateTime.now(),
      );

      await AuthService().addComment(comment);
      if (mounted) {
        _ctrl.clear();
        _focusNode.unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            content: Text('Failed to post comment: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: bichar.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
              child: Row(
                children: [
                  Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: bichar.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    color: bichar.textSecondary,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: bichar.border.withValues(alpha: 0.7)),
            // Comment list
            Flexible(
              child: StreamBuilder<List<CommentModel>>(
                stream: AuthService().getCommentsStream(widget.postId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }

                  final comments = snapshot.data ?? [];

                  if (comments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: bichar.textSecondary.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No comments yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: bichar.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Be the first to share your thoughts.',
                            style: TextStyle(
                              fontSize: 13,
                              color: bichar.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 62,
                      endIndent: 16,
                      color: bichar.border.withValues(alpha: 0.4),
                    ),
                    itemBuilder: (context, index) {
                      return _CommentTile(comment: comments[index]);
                    },
                  );
                },
              ),
            ),
            Divider(height: 1, color: bichar.border.withValues(alpha: 0.7)),
            // Input row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        style: TextStyle(
                          fontSize: 15,
                          color: bichar.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a comment…',
                          hintStyle: TextStyle(
                            color: bichar.textSecondary,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedOpacity(
                    opacity: _ctrl.text.trim().isNotEmpty ? 1.0 : 0.35,
                    duration: const Duration(milliseconds: 180),
                    child: Material(
                      color: bichar.accent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _ctrl.text.trim().isNotEmpty ? _submit : null,
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: _submitting
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});
  final CommentModel comment;

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF7C4DFF),
      Color(0xFF00897B),
      Color(0xFFE91E8C),
      Color(0xFF1565C0),
      Color(0xFF6A3DE8),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isMe = AuthService().currentUid == comment.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _avatarColor(comment.username),
            ),
            clipBehavior: Clip.antiAlias,
            child: comment.profilePhoto.isNotEmpty
                ? Image.network(
                    comment.profilePhoto,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        comment.username.isNotEmpty
                            ? comment.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      comment.username.isNotEmpty
                          ? comment.username[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username.isNotEmpty
                          ? comment.username[0].toUpperCase() +
                              comment.username.substring(1)
                          : '',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: bichar.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: bichar.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (isMe)
                      GestureDetector(
                        onTap: () async {
                          try {
                            await AuthService().deleteComment(
                              postId: comment.postId,
                              commentId: comment.commentId,
                            );
                          } catch (_) {}
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: bichar.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: bichar.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
