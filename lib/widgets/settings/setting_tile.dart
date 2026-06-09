import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';

/// Premium settings row — icon capsule, title, description, chevron/switch, hover lift.
class SettingTile extends StatefulWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;
    final accent = widget.iconColor ?? bichar.accent;
    final bool interactive = widget.onTap != null;
    final bool showChevron = widget.trailing == null && interactive;

    final trailing = widget.trailing ??
        (showChevron
            ? AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: _hovered ? 1 : 0.55,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: bichar.textSecondary.withValues(alpha: 0.75),
                ),
              )
            : widget.trailing);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: _hovered && interactive
            ? bichar.accent.withValues(alpha: isDark ? 0.08 : 0.04)
            : Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          splashColor: accent.withValues(alpha: 0.1),
          highlightColor: accent.withValues(alpha: 0.05),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.fromLTRB(14, _hovered ? 14 : 13, 14, 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, size: 23, color: accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: bichar.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.35,
                          color: bichar.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: trailing,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
