import 'package:flutter/material.dart';
import 'model/user_model.dart';
import 'profile_screen.dart';
import 'repo/auth_service.dart';
import 'theme/bichar_theme_extension.dart';

/// Displays a list of followers or following for a given user.
class FollowersScreen extends StatelessWidget {
  const FollowersScreen({
    super.key,
    required this.uids,
    required this.title,
  });

  /// List of user UIDs to display.
  final List<String> uids;

  /// 'Followers' or 'Following'
  final String title;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Scaffold(
      backgroundColor: bichar.drawerBackground,
      appBar: AppBar(
        backgroundColor: bichar.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: bichar.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: bichar.border.withValues(alpha: 0.7)),
        ),
      ),
      body: uids.isEmpty
          ? _EmptyFollowState(title: title)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: uids.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                indent: 72,
                endIndent: 16,
                color: bichar.border.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                return _UserTile(uid: uids[index]);
              },
            ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: AuthService().userModelStream(uid),
      builder: (context, snapshot) {
        final bichar = context.bichar;
        final user = snapshot.data;
        final username = user?.username ?? '';
        final photo = user?.profilePhoto ?? '';
        final bio = user?.aboutMe ?? '';

        if (snapshot.connectionState == ConnectionState.waiting && user == null) {
          return const _UserTileSkeleton();
        }

        if (user == null) return const SizedBox.shrink();

        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProfileScreen(userId: uid),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _Avatar(photoUrl: photo, username: username),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username.isNotEmpty
                            ? username[0].toUpperCase() + username.substring(1)
                            : '',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: bichar.textPrimary,
                        ),
                      ),
                      if (bio.isNotEmpty && bio != 'Write something about yourself...')
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            bio,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: bichar.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _FollowButton(targetUid: uid),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FollowButton extends StatefulWidget {
  const _FollowButton({required this.targetUid});
  final String targetUid;

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _loading = false;

  bool _isMe() => AuthService().currentUid == widget.targetUid;

  @override
  Widget build(BuildContext context) {
    if (_isMe()) return const SizedBox.shrink();
    final bichar = context.bichar;

    return StreamBuilder<UserModel?>(
      stream: AuthService().userModelStream(AuthService().currentUid ?? ''),
      builder: (context, snapshot) {
        final me = snapshot.data;
        final isFollowing = me?.following.contains(widget.targetUid) ?? false;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: TextButton(
            onPressed: _loading
                ? null
                : () async {
                    setState(() => _loading = true);
                    try {
                      await AuthService().toggleFollowUser(widget.targetUid);
                    } finally {
                      if (mounted) setState(() => _loading = false);
                    }
                  },
            style: TextButton.styleFrom(
              backgroundColor: isFollowing
                  ? bichar.searchFieldBackground
                  : bichar.accent,
              foregroundColor: isFollowing ? bichar.textPrimary : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isFollowing
                      ? bichar.border
                      : Colors.transparent,
                ),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            child: _loading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isFollowing ? bichar.textPrimary : Colors.white,
                    ),
                  )
                : Text(isFollowing ? 'Following' : 'Follow'),
          ),
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.username});
  final String photoUrl;
  final String username;

  Color _color() {
    const colors = [
      Color(0xFF7C4DFF),
      Color(0xFF00897B),
      Color(0xFFE91E8C),
      Color(0xFF1565C0),
      Color(0xFF6A3DE8),
    ];
    return colors[username.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color(),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl.isNotEmpty
          ? Image.network(photoUrl, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _initials())
          : _initials(),
    );
  }

  Widget _initials() {
    return Center(
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _UserTileSkeleton extends StatelessWidget {
  const _UserTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final shimmer = bichar.border.withValues(alpha: 0.4);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: shimmer)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 13, width: 120, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 6),
                Container(height: 11, width: 180, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFollowState extends StatelessWidget {
  const _EmptyFollowState({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            title == 'Followers'
                ? Icons.group_outlined
                : Icons.person_add_alt_1_outlined,
            size: 56,
            color: bichar.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title == 'Followers' ? 'No followers yet' : 'Not following anyone',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: bichar.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title == 'Followers'
                ? 'When someone follows this account,\nthey will appear here.'
                : 'Accounts followed will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: bichar.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
