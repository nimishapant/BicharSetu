import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';

/// Premium rounded navigation card used inside [AppNavigationDrawer].
/// Supports hover elevation (desktop/web), ripple, and animated selection.
class DrawerMenuItem extends StatefulWidget {
  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.iconColor,
    this.labelColor,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? iconColor;
  final Color? labelColor;
  final bool destructive;

  @override
  State<DrawerMenuItem> createState() => _DrawerMenuItemState();
}

class _DrawerMenuItemState extends State<DrawerMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final colorScheme = context.colors;
    final isDark = context.isDarkMode;

    final accent = widget.destructive
        ? colorScheme.error
        : (widget.iconColor ?? bichar.accent);
    final labelColor = widget.labelColor ??
        (widget.destructive ? colorScheme.error : bichar.textPrimary);

    final bool elevated = _hovered && !widget.isSelected;
    final Color cardColor = widget.isSelected
        ? accent.withValues(alpha: isDark ? 0.22 : 0.1)
        : (elevated
            ? bichar.cardBackground
            : bichar.cardBackground.withValues(alpha: isDark ? 0.55 : 0.92));

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: elevated
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: cardColor,
            elevation: 0,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(18),
              splashColor: accent.withValues(alpha: 0.12),
              highlightColor: accent.withValues(alpha: 0.06),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.isSelected
                        ? accent.withValues(alpha: 0.45)
                        : bichar.border.withValues(alpha: isDark ? 0.9 : 1),
                    width: widget.isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon sits in a soft tinted capsule for visual hierarchy.
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? accent.withValues(alpha: isDark ? 0.28 : 0.14)
                            : accent.withValues(alpha: isDark ? 0.14 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 22,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight:
                              widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: labelColor,
                          letterSpacing: -0.15,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: widget.isSelected || _hovered ? 1 : 0,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: bichar.textSecondary.withValues(alpha: 0.7),
                      ),
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

/// Section heading with subtle divider accent for grouped navigation.
class DrawerSectionHeader extends StatelessWidget {
  const DrawerSectionHeader({
    super.key,
    required this.title,
    this.icon,
  });

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: bichar.accent.withValues(alpha: 0.85)),
            const SizedBox(width: 6),
          ],
          Text(
            title.toUpperCase(),
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
    );
  }
}
