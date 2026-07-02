import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';

/// Premium profile header for the navigation drawer — gradient backdrop,
/// bordered avatar, stat cards, and quick profile actions.
class DrawerProfileHeader extends StatelessWidget {
  const DrawerProfileHeader({
    super.key,
    required this.displayName,
    required this.handle,
    required this.profilePhotoUrl,
    required this.onProfileTap,
    required this.onAddAccount,
    this.onEditProfile,
    this.followingCount = 0,
    this.followersCount = 0,
  });

  final String displayName;
  final String handle;
  final String profilePhotoUrl;
  final VoidCallback onProfileTap;
  final VoidCallback onAddAccount;
  final VoidCallback? onEditProfile;
  final int followingCount;
  final int followersCount;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final colorScheme = context.colors;
    final isDark = context.isDarkMode;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onProfileTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
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
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileAvatar(photoUrl: profilePhotoUrl, accent: bichar.accent),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: bichar.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          handle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: bichar.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _HeaderIconButton(
                    icon: Icons.person_add_rounded,
                    tooltip: 'Add Friend',
                    onTap: onAddAccount,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DrawerStatCard(
                      label: 'Following',
                      value: '$followingCount',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DrawerStatCard(
                      label: 'Followers',
                      value: '$followersCount',
                    ),
                  ),
                ],
              ),
              if (onEditProfile != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onEditProfile,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: bichar.accent,
                      side: BorderSide(
                        color: bichar.accent.withValues(alpha: 0.45),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl, required this.accent});

  final String photoUrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent,
            accent.withValues(alpha: 0.55),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  Icons.person_rounded,
                  size: 38,
                  color: bichar.mutedIcon,
                )
              : Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person_rounded,
                    size: 38,
                    color: bichar.mutedIcon,
                  ),
                ),
        ),
      ),
    );
  }
}

class _DrawerStatCard extends StatelessWidget {
  const _DrawerStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bichar.border.withValues(alpha: 0.9)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: bichar.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: bichar.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Material(
      color: bichar.cardBackground.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: bichar.textPrimary),
          ),
        ),
      ),
    );
  }
}
