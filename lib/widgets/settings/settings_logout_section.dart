import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';

/// Danger-zone logout block — visually aligned with drawer sign-out styling.
class SettingsLogoutSection extends StatefulWidget {
  const SettingsLogoutSection({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<SettingsLogoutSection> createState() => _SettingsLogoutSectionState();
}

class _SettingsLogoutSectionState extends State<SettingsLogoutSection> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final error = context.colors.error;
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 15,
                  color: error.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 7),
                Text(
                  'DANGER ZONE',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.35,
                    color: error.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          error.withValues(alpha: 0.25),
                          error.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: error.withValues(alpha: isDark ? 0.3 : 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: error.withValues(alpha: isDark ? 0.14 : 0.07),
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: widget.onLogout,
                  borderRadius: BorderRadius.circular(20),
                  splashColor: error.withValues(alpha: 0.12),
                  highlightColor: error.withValues(alpha: 0.06),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: error.withValues(alpha: _hovered ? 0.5 : 0.3),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: error.withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            color: error,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Log out of account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: error,
                                  letterSpacing: -0.15,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Sign out from BicharSetu on this device',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: bichar.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: error.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
