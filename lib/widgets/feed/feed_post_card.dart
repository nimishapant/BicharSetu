import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../comment_sheet.dart';
import '../../edit_post_screen.dart';
import '../../model/post_model.dart';
import '../../model/user_model.dart';
import '../../repo/auth_service.dart';
import '../../theme/bichar_theme_extension.dart';
import '../post_backgrounds.dart';
import 'author_info_widget.dart';
import 'category_chip.dart';
import 'engagement_bar.dart';
import 'feed_layout.dart';

/// Premium feed post card — Material 3 surface with hover lift and smooth entrance.
class FeedPostCard extends StatefulWidget {
  const FeedPostCard({super.key, required this.post});

  final PostModel post;

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  bool _likeInProgress = false;
  bool _hovered = false;

  bool get _isMyPost =>
      AuthService().currentUid != null &&
      AuthService().currentUid == widget.post.uid;

  bool get _liked {
    final uid = AuthService().currentUid;
    return uid != null && widget.post.likes.contains(uid);
  }

  Future<void> _onLikeTap() async {
    if (_likeInProgress) return;
    _likeInProgress = true;
    try {
      await AuthService().toggleLike(widget.post.postId);
    } catch (_) {}
    _likeInProgress = false;
  }

  void _showPostMenu() {
    final bichar = context.bichar;
    final canEdit = widget.post.canEdit;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: bichar.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: bichar.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Edit — only if within 24 h
              ListTile(
                enabled: canEdit,
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: canEdit
                        ? bichar.accent.withValues(alpha: 0.1)
                        : bichar.border.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.edit_outlined,
                      color: canEdit ? bichar.accent : bichar.textSecondary,
                      size: 20),
                ),
                title: Text(
                  canEdit ? 'Edit post' : 'Edit post (24 h window closed)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: canEdit ? bichar.textPrimary : bichar.textSecondary,
                  ),
                ),
                subtitle: canEdit && widget.post.createdAt != null
                    ? Text(
                        '${23 - DateTime.now().difference(widget.post.createdAt!).inHours}h left to edit',
                        style: TextStyle(fontSize: 12, color: bichar.textSecondary),
                      )
                    : null,
                onTap: canEdit
                    ? () {
                        Navigator.of(ctx).pop();
                        EditPostSheet.show(context, widget.post);
                      }
                    : null,
              ),
              // Delete
              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent, size: 20),
                ),
                title: const Text('Delete post',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent)),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final messenger = ScaffoldMessenger.of(context);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Delete post'),
                      content: const Text(
                          'This will permanently remove your post. This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dCtx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                          onPressed: () => Navigator.of(dCtx).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    try {
                      await AuthService().deletePost(widget.post.postId);
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.redAccent,
                        content: Text('Failed to delete: $e'),
                      ));
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _onCommentTap() {
    CommentSheet.show(context, widget.post.postId);
  }

  Future<void> _onShareTap() async {
    // Build a shareable text summary of the post
    final title = widget.post.title.isNotEmpty ? widget.post.title : '';
    final body = widget.post.body.isNotEmpty ? widget.post.body : '';
    final username = widget.post.username;
    final shareText = [
      if (title.isNotEmpty) title,
      if (body.isNotEmpty) body,
      '\n— by @$username on Bichar Setu',
    ].join('\n\n');

    // Copy to clipboard and show a snackbar
    await Clipboard.setData(ClipboardData(text: shareText));

    // Increment the share count in Firestore
    try {
      await AuthService().incrementShareCount(widget.post.postId);
    } catch (_) {}

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text(
              'Post copied to clipboard',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  String get _displayText {
    if (widget.post.title.isNotEmpty && widget.post.body.isNotEmpty) {
      return '${widget.post.title}\n\n${widget.post.body}';
    }
    if (widget.post.title.isNotEmpty) return widget.post.title;
    return widget.post.body;
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;
    final accent = bichar.accent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Transform.translate(
        offset: Offset(0, _hovered ? -2 : 0),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FeedLayout.cardRadius),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(
                alpha: isDark
                    ? (_hovered ? 0.18 : 0.08)
                    : (_hovered ? 0.14 : 0.06),
              ),
              blurRadius: _hovered ? 28 : 18,
              offset: Offset(0, _hovered ? 10 : 6),
            ),
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.06 : 0.03),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Material(
          color: bichar.cardBackground,
          borderRadius: BorderRadius.circular(FeedLayout.cardRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            splashColor: accent.withValues(alpha: 0.06),
            highlightColor: accent.withValues(alpha: 0.03),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FeedLayout.cardRadius),
                border: Border.all(
                  color: _hovered
                      ? accent.withValues(alpha: isDark ? 0.35 : 0.22)
                      : bichar.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Coloured background block (shows above author info) ──
                  if (widget.post.backgroundIndex > 0)
                    _ColoredPostBody(
                      text: _displayText,
                      backgroundIndex: widget.post.backgroundIndex,
                    ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthorInfoWidget(
                          username: widget.post.username,
                          timeAgo: widget.post.timeAgo,
                          profilePhotoUrl: widget.post.profilePhoto,
                          onMoreTap: _isMyPost ? _showPostMenu : null,
                        ),
                        if (widget.post.category.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          CategoryChip(category: widget.post.category),
                        ],
                        if (widget.post.backgroundIndex == 0) ...[
                          const SizedBox(height: 14),
                          Text(
                            _displayText,
                            style: TextStyle(
                              fontSize: 15.5,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                              color: bichar.textPrimary,
                              letterSpacing: 0.05,
                            ),
                          ),
                        ],
                        if (widget.post.keywords.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: widget.post.keywords.map((tag) {
                              return Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: accent.withValues(alpha: 0.9),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Divider(
                          height: 1,
                          color: bichar.border.withValues(alpha: 0.85),
                        ),
                        const SizedBox(height: 10),
                        StreamBuilder<UserModel?>(
                          stream: AuthService().userModelStream(
                              AuthService().currentUid ?? ''),
                          builder: (context, snap) {
                            final isSaved = snap.data?.savedPosts
                                    .contains(widget.post.postId) ??
                                false;
                            return EngagementBar(
                              likeCount: widget.post.likeCount,
                              commentCount: widget.post.commentCount,
                              shareCount: widget.post.shareCount,
                              isLiked: _liked,
                              isSaved: isSaved,
                              onLikeTap: _onLikeTap,
                              onCommentTap: _onCommentTap,
                              onShareTap: _onShareTap,
                              onSaveTap: () async {
                                final wasSaved = isSaved;
                                try {
                                  await AuthService()
                                      .toggleSavePost(widget.post.postId);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      duration:
                                          const Duration(seconds: 1),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      content: Row(children: [
                                        Icon(
                                          wasSaved
                                              ? Icons.bookmark_remove_outlined
                                              : Icons.bookmark_added_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isSaved
                                              ? 'Post removed from saved'
                                              : 'Post saved!',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ]),
                                    ),
                                  );
                                } catch (_) {}
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

/// Full-width gradient block that renders post text on a coloured background.
class _ColoredPostBody extends StatelessWidget {
  const _ColoredPostBody({
    required this.text,
    required this.backgroundIndex,
  });

  final String text;
  final int backgroundIndex;

  @override
  Widget build(BuildContext context) {
    final gradient = PostBackground.gradientFor(backgroundIndex);
    if (gradient == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(FeedLayout.cardRadius),
        ),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.4,
            shadows: [
              Shadow(
                color: Color(0x40000000),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
