import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';

/// Premium profile top bar — back, title, search, and notifications.
class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({
    super.key,
    this.onBack,
    this.onSearchTap,
    this.onNotificationsTap,
  });

  final VoidCallback? onBack;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: bichar.cardBackground,
        border: Border(
          bottom: BorderSide(color: bichar.border.withValues(alpha: 0.7)),
        ),
        boxShadow: [
          BoxShadow(
            color: bichar.accent.withValues(alpha: isDark ? 0.05 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
      child: Row(
        children: [
          _ProfileHeaderIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onTap: onBack ?? () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: bichar.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          _ProfileHeaderIconButton(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onTap: onSearchTap ?? () {},
          ),
          const SizedBox(width: 2),
          _ProfileHeaderIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            onTap: onNotificationsTap ?? () {},
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderIconButton extends StatefulWidget {
  const _ProfileHeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_ProfileHeaderIconButton> createState() =>
      _ProfileHeaderIconButtonState();
}

class _ProfileHeaderIconButtonState extends State<_ProfileHeaderIconButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Tooltip(
            message: widget.tooltip,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _hovered
                    ? bichar.accent.withValues(
                        alpha: context.isDarkMode ? 0.15 : 0.08,
                      )
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                widget.icon,
                color: bichar.textPrimary,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
