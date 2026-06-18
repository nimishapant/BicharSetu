import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';
import 'profile_layout.dart';

/// Material 3 segmented tab bar for Articles, Liked, Saved, and About.
class ProfileTabBar extends StatelessWidget {
  const ProfileTabBar({
    super.key,
    required this.controller,
    required this.selectedIndex,
    this.articlesLabel = 'Articles',
    this.likedLabel = 'Liked',
    this.savedLabel = 'Saved',
    this.aboutLabel = 'About',
    this.showSaved = false,
  });

  final TabController controller;
  final int selectedIndex;
  final String articlesLabel;
  final String likedLabel;
  final String savedLabel;
  final String aboutLabel;
  /// Only show Saved tab on own profile
  final bool showSaved;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;
    final labels = showSaved
        ? [articlesLabel, likedLabel, savedLabel, aboutLabel]
        : [articlesLabel, likedLabel, aboutLabel];

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bichar.searchFieldBackground.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(ProfileLayout.cardRadius),
          border: Border.all(color: bichar.border.withValues(alpha: 0.7)),
        ),
        child: TabBar(
          controller: controller,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: EdgeInsets.zero,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          indicator: BoxDecoration(
            color: bichar.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: bichar.accent.withValues(alpha: isDark ? 0.15 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: bichar.accent.withValues(alpha: 0.2)),
          ),
          labelColor: bichar.accent,
          unselectedLabelColor: bichar.textSecondary,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.1),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: List.generate(labels.length, (index) {
            return Tab(
              height: 42,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontWeight: selectedIndex == index
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
                child: Text(labels[index]),
              ),
            );
          }),
        ),
      ),
    );
  }
}
