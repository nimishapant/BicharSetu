import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';

/// Distinct destructive action pinned to the bottom of the navigation drawer.
class DrawerSignOutButton extends StatefulWidget {
  const DrawerSignOutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<DrawerSignOutButton> createState() => _DrawerSignOutButtonState();
}

class _DrawerSignOutButtonState extends State<DrawerSignOutButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final error = colorScheme.error;
    final isDark = context.isDarkMode;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: error.withValues(alpha: isDark ? 0.35 : 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: error.withValues(alpha: isDark ? 0.18 : 0.1),
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(18),
            splashColor: error.withValues(alpha: 0.15),
            highlightColor: error.withValues(alpha: 0.08),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: error.withValues(alpha: _hovered ? 0.55 : 0.35),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: error, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Sign out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: error,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
