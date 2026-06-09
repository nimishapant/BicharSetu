import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';
import 'profile_layout.dart';

/// Premium profile identity block — avatar, name, handle, and bio.
class ProfileHeader extends StatefulWidget {
  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.username,
    required this.bio,
    this.profilePhotoUrl = '',
    this.heroTag,
  });

  final String displayName;
  final String username;
  final String bio;
  final String profilePhotoUrl;
  final String? heroTag;

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool _avatarHovered = false;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final colorScheme = context.colors;
    final isDark = context.isDarkMode;
    final handle = '@${widget.username}';
    final bioText = widget.bio.isEmpty
        ? 'Add a bio to tell your story…'
        : widget.bio;
    final bioIsPlaceholder = widget.bio.isEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ProfileLayout.cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  bichar.accent.withValues(alpha: 0.24),
                  bichar.cardBackground.withValues(alpha: 0.98),
                ]
              : [
                  bichar.accent.withValues(alpha: 0.1),
                  colorScheme.primaryContainer.withValues(alpha: 0.28),
                  bichar.cardBackground,
                ],
        ),
        border: Border.all(
          color: bichar.accent.withValues(alpha: isDark ? 0.32 : 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: bichar.accent.withValues(alpha: isDark ? 0.1 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MouseRegion(
                onEnter: (_) => setState(() => _avatarHovered = true),
                onExit: (_) => setState(() => _avatarHovered = false),
                child: AnimatedScale(
                  scale: _avatarHovered ? 1.03 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: _ProfileAvatar(
                    photoUrl: widget.profilePhotoUrl,
                    displayName: widget.displayName,
                    heroTag: widget.heroTag,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: bichar.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      handle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: bichar.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            bioText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: bioIsPlaceholder
                  ? bichar.textSecondary.withValues(alpha: 0.75)
                  : bichar.textPrimary.withValues(alpha: 0.88),
              fontStyle:
                  bioIsPlaceholder ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.photoUrl,
    required this.displayName,
    this.heroTag,
  });

  final String photoUrl;
  final String displayName;
  final String? heroTag;

  Color _fallbackColor(String name) {
    const colors = [
      Color(0xFF7C4DFF),
      Color(0xFF00897B),
      Color(0xFFE91E8C),
      Color(0xFF1565C0),
      Color(0xFF6A3DE8),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final accent = bichar.accent;

    final avatar = Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, bichar.accentLight],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 5),
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
              ? ColoredBox(
                  color: _fallbackColor(displayName),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName.trim().characters.first.toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                )
              : Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person_rounded,
                    size: 44,
                    color: bichar.mutedIcon,
                  ),
                ),
        ),
      ),
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: avatar);
    }
    return avatar;
  }
}
