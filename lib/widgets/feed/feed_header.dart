import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';
import 'feed_layout.dart';

/// Premium feed section header — greeting, subtitle, and refresh indicator.
class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key, required this.isRefreshing});

  final bool isRefreshing;

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final colorScheme = context.colors;
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FeedLayout.cardRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        bichar.accent.withValues(alpha: 0.28),
                        bichar.cardBackground.withValues(alpha: 0.95),
                      ]
                    : [
                        bichar.accent.withValues(alpha: 0.12),
                        colorScheme.primaryContainer.withValues(alpha: 0.3),
                        bichar.cardBackground,
                      ],
              ),
              border: Border.all(
                color: bichar.accent.withValues(alpha: isDark ? 0.35 : 0.16),
              ),
              boxShadow: [
                BoxShadow(
                  color: bichar.accent.withValues(alpha: isDark ? 0.1 : 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()} 👋',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: bichar.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Discover stories from your community',
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: bichar.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Today\'s Feed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: bichar.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: isRefreshing
                    ? Container(
                        key: const ValueKey('refreshing'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: bichar.chipBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: bichar.accent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Updating…',
                              style: TextStyle(
                                color: bichar.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        key: const ValueKey('idle'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: bichar.searchFieldBackground.withValues(
                            alpha: 0.7,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe_down_rounded,
                              size: 14,
                              color: bichar.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Pull to refresh',
                              style: TextStyle(
                                color: bichar.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
