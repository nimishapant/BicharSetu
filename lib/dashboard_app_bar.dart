import 'package:flutter/material.dart';
import 'model/user_model.dart';
import 'repo/auth_service.dart';
import 'theme/bichar_theme_extension.dart';

/// Premium sticky feed header — branding, profile, search, and featured action.
class DashboardAppBarContent extends StatelessWidget {
  const DashboardAppBarContent({
    super.key,
    required this.onProfileTap,
    required this.onSearchTap,
    required this.onSparkleTap,
  });

  final VoidCallback onProfileTap;
  final VoidCallback onSearchTap;
  final VoidCallback onSparkleTap;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: bichar.cardBackground,
        boxShadow: [
          BoxShadow(
            color: bichar.accent.withValues(alpha: isDark ? 0.06 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 10, 6),
        child: Row(
          children: [
            _PremiumProfileButton(onTap: onProfileTap),
            Expanded(
              child: Center(
                child: _BrandMark(bichar: bichar),
              ),
            ),
            _HeaderActionButton(
              icon: Icons.search_rounded,
              tooltip: 'Search',
              onTap: onSearchTap,
            ),
            const SizedBox(width: 4),
            _HeaderActionButton(
              icon: Icons.auto_awesome_rounded,
              tooltip: 'Featured',
              iconColor: const Color(0xFFE53935),
              onTap: onSparkleTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.bichar});

  final BicharTheme bichar;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/bichar_logo.png',
      height: 34,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [bichar.accent, bichar.accentLight],
        ).createShader(bounds),
        child: Text(
          'BicharSetu',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: bichar.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

class _PremiumProfileButton extends StatelessWidget {
  const _PremiumProfileButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return StreamBuilder<UserModel?>(
      stream: AuthService().currentUserModelStream,
      builder: (context, snapshot) {
        final photoUrl = snapshot.data?.profilePhoto ?? '';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [bichar.accent, bichar.accentLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: bichar.accent.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bichar.cardBackground,
                ),
                child: ClipOval(
                  child: photoUrl.isEmpty
                      ? Icon(
                          Icons.menu_rounded,
                          color: bichar.textPrimary,
                          size: 22,
                        )
                      : Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.menu_rounded,
                            color: bichar.textPrimary,
                            size: 22,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderActionButton extends StatefulWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  State<_HeaderActionButton> createState() => _HeaderActionButtonState();
}

class _HeaderActionButtonState extends State<_HeaderActionButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final color = widget.iconColor ?? bichar.textPrimary;

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
                    ? bichar.accent.withValues(alpha: context.isDarkMode ? 0.15 : 0.08)
                    : bichar.searchFieldBackground.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _hovered
                      ? bichar.accent.withValues(alpha: 0.25)
                      : bichar.border.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(widget.icon, color: color, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
