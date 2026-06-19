import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';
import 'profile_layout.dart';

/// Interactive stats grid — Stories, Status, Followers, Following.
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    this.storiesCount = '0',
    this.statusCount = '0',
    this.followersCount = '0',
    this.followingCount = '0',
    this.onStoriesTap,
    this.onStatusTap,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  final String storiesCount;
  final String statusCount;
  final String followersCount;
  final String followingCount;
  final VoidCallback? onStoriesTap;
  final VoidCallback? onStatusTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? bichar.cardBackground.withValues(alpha: 0.85)
            : bichar.cardBackground,
        borderRadius: BorderRadius.circular(ProfileLayout.cardRadius),
        border: Border.all(color: bichar.border.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: bichar.accent.withValues(alpha: isDark ? 0.06 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatCell(
            count: storiesCount,
            label: 'Stories',
            onTap: onStoriesTap,
          ),
          _StatSeparator(color: bichar.border),
          _StatCell(
            count: statusCount,
            label: 'Status',
            onTap: onStatusTap,
          ),
          _StatSeparator(color: bichar.border),
          _StatCell(
            count: followersCount,
            label: 'Followers',
            onTap: onFollowersTap,
          ),
          _StatSeparator(color: bichar.border),
          _StatCell(
            count: followingCount,
            label: 'Following',
            onTap: onFollowingTap,
          ),
        ],
      ),
    );
  }
}

class _StatSeparator extends StatelessWidget {
  const _StatSeparator({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: color.withValues(alpha: 0.8),
    );
  }
}

class _StatCell extends StatefulWidget {
  const _StatCell({
    required this.count,
    required this.label,
    this.onTap,
  });

  final String count;
  final String label;
  final VoidCallback? onTap;

  @override
  State<_StatCell> createState() => _StatCellState();
}

class _StatCellState extends State<_StatCell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          borderRadius: BorderRadius.circular(14),
          splashColor: bichar.accent.withValues(alpha: 0.08),
          child: AnimatedScale(
            scale: _pressed ? 0.94 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Text(
                    widget.count,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: bichar.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: bichar.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
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
