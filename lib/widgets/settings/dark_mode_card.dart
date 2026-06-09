import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';
import 'premium_card.dart';

/// Highlighted appearance control — animated switch with moon/sun visual state.
class DarkModeCard extends StatelessWidget {
  const DarkModeCard({
    super.key,
    required this.isDarkModeEnabled,
    required this.subtitle,
    required this.onChanged,
  });

  final bool isDarkModeEnabled;
  final String subtitle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  size: 15,
                  color: bichar.accent.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 7),
                Text(
                  'APPEARANCE',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.35,
                    color: bichar.textSecondary.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          bichar.border,
                          bichar.border.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          PremiumCard(
            highlighted: true,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkModeEnabled
                          ? [
                              const Color(0xFF2D2A45),
                              const Color(0xFF6A3DE8),
                            ]
                          : [
                              const Color(0xFFFFE082),
                              const Color(0xFFFFB74D),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: bichar.accent.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Icon(
                      isDarkModeEnabled
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      key: ValueKey(isDarkModeEnabled),
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Night and Dark mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: bichar.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.35,
                          color: bichar.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        child: Text(subtitle),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 1.05,
                  child: Switch.adaptive(
                    value: isDarkModeEnabled,
                    onChanged: onChanged,
                    activeThumbColor: isDark ? bichar.accentLight : bichar.accent,
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
