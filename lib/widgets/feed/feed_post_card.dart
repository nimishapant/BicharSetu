import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../comment_sheet.dart';
import '../../model/post_model.dart';
import '../../repo/auth_service.dart';
import '../../theme/bichar_theme_extension.dart';
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
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthorInfoWidget(
                    username: widget.post.username,
                    timeAgo: widget.post.timeAgo,
                    profilePhotoUrl: widget.post.profilePhoto,
                    onMoreTap: () {},
                  ),
                  if (widget.post.category.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    CategoryChip(category: widget.post.category),
                  ],
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
                  EngagementBar(
                    likeCount: widget.post.likeCount,
                    commentCount: widget.post.commentCount,
                    shareCount: widget.post.shareCount,
                    isLiked: _liked,
                    onLikeTap: _onLikeTap,
                    onCommentTap: _onCommentTap,
                    onShareTap: _onShareTap,
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
