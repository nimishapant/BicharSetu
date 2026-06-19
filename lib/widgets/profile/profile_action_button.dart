import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';

/// Gradient Edit Profile CTA with optional settings icon button.
class ProfileActionButton extends StatefulWidget {
  const ProfileActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.settingsOnTap,
    this.showSettings = true,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback? settingsOnTap;
  final bool showSettings;

  @override
  State<ProfileActionButton> createState() => _ProfileActionButtonState();
}

class _ProfileActionButtonState extends State<ProfileActionButton> {
  bool _editPressed = false;
  bool _settingsPressed = false;
  bool _editHovered = false;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: MouseRegion(
              onEnter: (_) => setState(() => _editHovered = true),
              onExit: (_) => setState(() => _editHovered = false),
              child: GestureDetector(
                onTapDown: (_) => setState(() => _editPressed = true),
                onTapUp: (_) => setState(() => _editPressed = false),
                onTapCancel: () => setState(() => _editPressed = false),
                onTap: widget.onTap,
                child: AnimatedScale(
                  scale: _editPressed ? 0.97 : 1.0,
                  duration: const Duration(milliseconds: 120),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [bichar.accent, bichar.accentLight],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: bichar.accent.withValues(
                            alpha: _editHovered ? 0.38 : 0.28,
                          ),
                          blurRadius: _editHovered ? 18 : 14,
                          offset: Offset(0, _editHovered ? 7 : 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onTap,
                        borderRadius: BorderRadius.circular(16),
                        splashColor: Colors.white.withValues(alpha: 0.15),
                        child: Center(
                          child: Text(
                            widget.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.showSettings) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTapDown: (_) => setState(() => _settingsPressed = true),
              onTapUp: (_) => setState(() => _settingsPressed = false),
              onTapCancel: () => setState(() => _settingsPressed = false),
              onTap: widget.settingsOnTap,
              child: AnimatedScale(
                scale: _settingsPressed ? 0.92 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: Material(
                  color: bichar.searchFieldBackground.withValues(alpha: 0.85),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.settingsOnTap,
                    splashColor: bichar.accent.withValues(alpha: 0.1),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: bichar.border.withValues(alpha: 0.9),
                        ),
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: bichar.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
