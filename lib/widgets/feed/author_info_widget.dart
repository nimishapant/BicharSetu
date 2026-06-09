import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';

/// Premium author row — avatar, name, verified badge, and timestamp.
class AuthorInfoWidget extends StatelessWidget {
  const AuthorInfoWidget({
    super.key,
    required this.username,
    required this.timeAgo,
    this.profilePhotoUrl = '',
    this.isVerified = false,
    this.avatarRadius = 24,
    this.onMoreTap,
  });

  final String username;
  final String timeAgo;
  final String profilePhotoUrl;
  final bool isVerified;
  final double avatarRadius;
  final VoidCallback? onMoreTap;

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF7C4DFF),
      Color(0xFF00897B),
      Color(0xFFE91E8C),
      Color(0xFF1565C0),
      Color(0xFFF57C00),
      Color(0xFF00796B),
      Color(0xFFAD1457),
      Color(0xFF6A3DE8),
    ];
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final accent = bichar.accent;
    final diameter = avatarRadius * 2;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: diameter + 6,
          height: diameter + 6,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent, accent.withValues(alpha: 0.55)],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bichar.cardBackground,
            ),
            child: ClipOval(
              child: profilePhotoUrl.isNotEmpty
                  ? Image.network(
                      profilePhotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _LetterAvatar(
                        username: username,
                        radius: avatarRadius,
                        color: _avatarColor(username),
                      ),
                    )
                  : _LetterAvatar(
                      username: username,
                      radius: avatarRadius,
                      color: _avatarColor(username),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: bichar.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  if (isVerified) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: accent,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: bichar.textSecondary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        if (onMoreTap != null)
          Material(
            color: bichar.searchFieldBackground.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onMoreTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: bichar.mutedIcon,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LetterAvatar extends StatelessWidget {
  const _LetterAvatar({
    required this.username,
    required this.radius,
    required this.color,
  });

  final String username;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final letter = username.isNotEmpty
        ? username.trim().characters.first.toUpperCase()
        : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.85,
        ),
      ),
    );
  }
}
