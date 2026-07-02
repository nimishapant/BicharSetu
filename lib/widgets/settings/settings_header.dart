import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';

/// Premium settings hero — mirrors the navigation drawer profile gradient language.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    super.key,
    required this.username,
    required this.profilePhotoUrl,
    required this.onBack,
  });

  final String username;
  final String profilePhotoUrl;
  final VoidCallback onBack;

  String get _displayHandle => '@$username';

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final colorScheme = context.colors;
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onBack,
                icon: Icon(Icons.arrow_back_rounded, color: bichar.textPrimary),
                style: IconButton.styleFrom(
                  backgroundColor: bichar.cardBackground.withValues(alpha: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('Additional settings options — coming soon'),
                    ),
                  );
                },
                icon: Icon(Icons.more_horiz_rounded, color: bichar.textPrimary),
                style: IconButton.styleFrom(
                  backgroundColor: bichar.cardBackground.withValues(alpha: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        bichar.accent.withValues(alpha: 0.28),
                        bichar.cardBackground.withValues(alpha: 0.95),
                      ]
                    : [
                        bichar.accent.withValues(alpha: 0.14),
                        colorScheme.primaryContainer.withValues(alpha: 0.35),
                        bichar.cardBackground,
                      ],
              ),
              border: Border.all(
                color: bichar.accent.withValues(alpha: isDark ? 0.35 : 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: bichar.accent.withValues(alpha: isDark ? 0.12 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _SettingsAvatar(
                  photoUrl: profilePhotoUrl,
                  accent: bichar.accent,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: bichar.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _displayHandle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: bichar.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manage your account and preferences',
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          color: bichar.textSecondary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
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

class _SettingsAvatar extends StatelessWidget {
  const _SettingsAvatar({required this.photoUrl, required this.accent});

  final String photoUrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withValues(alpha: 0.55)],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bichar.cardBackground,
        ),
        child: ClipOval(
          child: photoUrl.isEmpty
              ? Icon(Icons.person_rounded, size: 34, color: bichar.mutedIcon)
              : Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person_rounded,
                    size: 34,
                    color: bichar.mutedIcon,
                  ),
                ),
        ),
      ),
    );
  }
}
