import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';

/// Material 3–inspired bottom navigation with center FAB — matches drawer/settings.
class FeedBottomNav extends StatefulWidget {
  const FeedBottomNav({
    super.key,
    required this.selectedIndex,
    required this.badgePulseController,
    required this.fabPulseController,
    required this.onItemTap,
  });

  final int selectedIndex;
  final AnimationController badgePulseController;
  final AnimationController fabPulseController;
  final ValueChanged<int> onItemTap;

  @override
  State<FeedBottomNav> createState() => _FeedBottomNavState();
}

class _FeedBottomNavState extends State<FeedBottomNav> {
  bool _searchPressed = false;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: bichar.cardBackground,
          border: Border(top: BorderSide(color: bichar.border.withValues(alpha: 0.8))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 88,
          child: Row(
            children: [
              _NavSlot(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                selectedIndex: widget.selectedIndex,
                onTap: widget.onItemTap,
              ),
              Expanded(
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _searchPressed = true),
                  onTapUp: (_) => setState(() => _searchPressed = false),
                  onTapCancel: () => setState(() => _searchPressed = false),
                  onTap: () => widget.onItemTap(1),
                  child: AnimatedScale(
                    scale: _searchPressed ? 0.92 : 1.0,
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOutCubic,
                    child: _NavSlot(
                      icon: Icons.search_rounded,
                      activeIcon: Icons.search_rounded,
                      label: 'Search',
                      index: 1,
                      selectedIndex: widget.selectedIndex,
                      onTap: (_) {},
                      isWrappedInExpanded: true,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: FeedCreateFab(
                  controller: widget.fabPulseController,
                  onTap: () => widget.onItemTap(2),
                ),
              ),
              _NavSlot(
                icon: Icons.notifications_none_rounded,
                activeIcon: Icons.notifications_rounded,
                label: 'Alerts',
                index: 3,
                selectedIndex: widget.selectedIndex,
                onTap: widget.onItemTap,
                badgePulseController: widget.badgePulseController,
                showBadge: true,
              ),
              _ProfileNavSlot(
                index: 4,
                selectedIndex: widget.selectedIndex,
                onTap: widget.onItemTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    this.showBadge = false,
    this.badgePulseController,
    this.isWrappedInExpanded = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool showBadge;
  final AnimationController? badgePulseController;
  final bool isWrappedInExpanded;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isActive = selectedIndex == index;

    final inner = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: bichar.accent.withValues(alpha: 0.1),
        highlightColor: bichar.accent.withValues(alpha: 0.05),
        child: SizedBox(
          height: 88,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? bichar.accent.withValues(alpha: context.isDarkMode ? 0.2 : 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) => ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                        child: Icon(
                          isActive ? activeIcon : icon,
                          key: ValueKey(isActive),
                          color: isActive ? bichar.accent : bichar.textPrimary,
                          size: 26,
                        ),
                      ),
                      if (showBadge && badgePulseController != null)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: AnimatedBuilder(
                            animation: badgePulseController!,
                            builder: (context, child) {
                              final pulse =
                                  0.85 + (badgePulseController!.value * 0.25);
                              return Transform.scale(scale: pulse, child: child);
                            },
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4A73),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: bichar.cardBackground,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isActive ? bichar.accent : bichar.textSecondary,
                  fontSize: 11.5,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0.1,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );

    return isWrappedInExpanded ? inner : Expanded(child: inner);
  }
}

class _ProfileNavSlot extends StatelessWidget {
  const _ProfileNavSlot({
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isActive = selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: bichar.accent.withValues(alpha: 0.1),
          child: SizedBox(
            height: 88,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? LinearGradient(
                            colors: [
                              bichar.accent,
                              bichar.accentLight,
                            ],
                          )
                        : null,
                    color: isActive ? null : bichar.searchFieldBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive
                          ? Colors.transparent
                          : bichar.border,
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 18,
                    color: isActive ? Colors.white : bichar.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isActive ? bichar.accent : bichar.textSecondary,
                    fontSize: 11.5,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  ),
                  child: const Text('Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium gradient FAB for creating posts.
class FeedCreateFab extends StatelessWidget {
  const FeedCreateFab({
    super.key,
    required this.controller,
    required this.onTap,
  });

  final AnimationController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final accent = bichar.accent;
    final accentLight = bichar.accentLight;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        final glow = 0.18 + (0.22 * math.sin(t * math.pi));
        return Transform.scale(
          scale: 0.96 + (0.04 * t),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: glow),
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          splashColor: Colors.white.withValues(alpha: 0.2),
          child: Ink(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent, accentLight],
              ),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
