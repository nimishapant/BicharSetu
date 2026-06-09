import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';
import 'feed_layout.dart';

/// Shimmer-style loading skeleton for feed posts.
class FeedPostSkeleton extends StatefulWidget {
  const FeedPostSkeleton({super.key});

  @override
  State<FeedPostSkeleton> createState() => _FeedPostSkeletonState();
}

class _FeedPostSkeletonState extends State<FeedPostSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = 0.35 + (_controller.value * 0.35);
        return Opacity(opacity: t, child: child);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        decoration: BoxDecoration(
          color: bichar.cardBackground,
          borderRadius: BorderRadius.circular(FeedLayout.cardRadius),
          border: Border.all(color: bichar.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Bone(width: 48, height: 48, radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _Bone(width: 120, height: 14),
                      SizedBox(height: 8),
                      _Bone(width: 72, height: 11),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _Bone(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            const _Bone(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            const _Bone(width: 200, height: 12),
            const SizedBox(height: 16),
            Row(
              children: const [
                _Bone(width: 72, height: 32, radius: 16),
                SizedBox(width: 8),
                _Bone(width: 72, height: 32, radius: 16),
                SizedBox(width: 8),
                _Bone(width: 72, height: 32, radius: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeedLoadingSkeletons extends StatelessWidget {
  const FeedLoadingSkeletons({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => const FeedPostSkeleton()),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bichar.searchFieldBackground,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Premium empty feed state card.
class FeedEmptyState extends StatelessWidget {
  const FeedEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: bichar.cardBackground,
        borderRadius: BorderRadius.circular(FeedLayout.cardRadius),
        border: Border.all(color: bichar.border),
        boxShadow: [
          BoxShadow(
            color: bichar.accent.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bichar.chipBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.dynamic_feed_outlined,
              size: 28,
              color: bichar.accent,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: bichar.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh or tap + to share your first story.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: bichar.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
