import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';

/// Modern engagement row — like, comment, share pills with hover/press animations.
class EngagementBar extends StatelessWidget {
  const EngagementBar({
    super.key,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isLiked,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
  });

  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _EngagementPill(
          icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          label: '$likeCount',
          isActive: isLiked,
          onTap: onLikeTap,
        ),
        const SizedBox(width: 8),
        _EngagementPill(
          icon: Icons.chat_bubble_outline_rounded,
          label: '$commentCount',
          onTap: onCommentTap,
        ),
        const SizedBox(width: 8),
        _EngagementPill(
          icon: Icons.ios_share_rounded,
          label: '$shareCount',
          onTap: onShareTap,
        ),
      ],
    );
  }
}

class _EngagementPill extends StatefulWidget {
  const _EngagementPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  State<_EngagementPill> createState() => _EngagementPillState();
}

class _EngagementPillState extends State<_EngagementPill> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;
    final accent = bichar.accent;
    final idleColor = bichar.textSecondary;
    final active = widget.isActive;

    final bgColor = active
        ? accent.withValues(alpha: isDark ? 0.22 : 0.1)
        : _hovered
            ? bichar.accent.withValues(alpha: isDark ? 0.1 : 0.05)
            : bichar.searchFieldBackground.withValues(alpha: 0.85);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: active
                    ? accent.withValues(alpha: 0.35)
                    : bichar.border.withValues(alpha: _hovered ? 0.9 : 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: Icon(
                    widget.icon,
                    key: ValueKey(active),
                    size: 18,
                    color: active ? accent : idleColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? accent : idleColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
