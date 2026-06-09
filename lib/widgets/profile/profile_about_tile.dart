import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';
import 'profile_layout.dart';

/// Premium about info tile — icon capsule, label, and value.
class ProfileAboutTile extends StatefulWidget {
  const ProfileAboutTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  State<ProfileAboutTile> createState() => _ProfileAboutTileState();
}

class _ProfileAboutTileState extends State<ProfileAboutTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final accent = bichar.accent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _hovered
              ? bichar.accent.withValues(
                  alpha: context.isDarkMode ? 0.06 : 0.03,
                )
              : bichar.cardBackground,
          borderRadius: BorderRadius.circular(ProfileLayout.cardRadius),
          border: Border.all(
            color: _hovered
                ? accent.withValues(alpha: 0.25)
                : bichar.border.withValues(alpha: 0.85),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(
                  alpha: context.isDarkMode ? 0.2 : 0.1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon, color: accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: bichar.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 15,
                      color: bichar.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1,
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
