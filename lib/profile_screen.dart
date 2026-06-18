import 'package:flutter/material.dart';
import 'account_verification_screen.dart';
import 'createpost_screen.dart';
import 'followers_screen.dart';
import 'loginScreen.dart';
import 'model/user_model.dart';
import 'model/post_model.dart';
import 'profileedit_screen.dart';
import 'repo/auth_service.dart';
import 'theme/bichar_theme_extension.dart';
import 'widgets/feed/feed_post_card.dart';
import 'widgets/profile/profile_about_tile.dart';
import 'widgets/profile/profile_action_button.dart';
import 'widgets/profile/profile_app_bar.dart';
import 'widgets/profile/profile_banner_card.dart';
import 'widgets/profile/profile_empty_state.dart';
import 'widgets/profile/profile_header.dart';
import 'widgets/profile/profile_layout.dart';
import 'widgets/profile/profile_stats_row.dart';
import 'widgets/profile/profile_tab_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});
  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _isMe ? 4 : 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _showSettingsBottomSheet(BuildContext context, {bool isPrivate = false}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _SettingsSheet(
          isPrivate: isPrivate,
          onSignOut: () async {
            Navigator.of(sheetContext).pop();
            await AuthService().signOut();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        );
      },
    );
  }


  String get _effectiveUserId => widget.userId ?? AuthService().currentUid ?? '';
  bool get _isMe => _effectiveUserId == AuthService().currentUid;

  Future<void> _toggleFollowUser() async {
    try {
      await AuthService().toggleFollowUser(_effectiveUserId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update follow status: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: AuthService().userModelStream(_effectiveUserId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final usernameDisplay = user?.username ?? 'Aditya';
        final bioDisplay = user?.aboutMe ?? '';
        final profilePhotoUrl = user?.profilePhoto ?? '';

        final currentUid = AuthService().currentUid;
        final isFollowing = user?.followers.contains(currentUid) ?? false;

        final bichar = context.bichar;

        return Scaffold(
          backgroundColor: bichar.drawerBackground,
          body: SafeArea(
            child: Column(
              children: [
                const ProfileAppBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entranceController,
                      curve: Curves.easeOut,
                    ),
                    child: NestedScrollView(
                      headerSliverBuilder: (context, _) => [
                        SliverToBoxAdapter(
                          child: ProfileLayout.constrain(
                            context: context,
                            padding: EdgeInsets.fromLTRB(
                              ProfileLayout.horizontalPadding(context),
                              8,
                              ProfileLayout.horizontalPadding(context),
                              0,
                            ),
                            child: Column(
                              children: [
                                ProfileHeader(
                                  displayName: usernameDisplay,
                                  username: usernameDisplay,
                                  bio: bioDisplay,
                                  profilePhotoUrl: profilePhotoUrl,
                                  heroTag: 'profile_avatar_$profilePhotoUrl',
                                ),
                                ProfileStatsRow(
                                  storiesCount: '0',
                                  statusCount: '${user?.postCount ?? 0}',
                                  followersCount: '${user?.followers.length ?? 0}',
                                  followingCount: '${user?.following.length ?? 0}',
                                  onFollowersTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => FollowersScreen(
                                          uids: user?.followers ?? [],
                                          title: 'Followers',
                                        ),
                                      ),
                                    );
                                  },
                                  onFollowingTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => FollowersScreen(
                                          uids: user?.following ?? [],
                                          title: 'Following',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ProfileActionButton(
                                  label: _isMe
                                      ? 'Edit Profile'
                                      : (isFollowing ? 'Unfollow' : 'Follow'),
                                  onTap: _isMe
                                      ? () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  const ProfileEditScreen(),
                                            ),
                                          );
                                        }
                                      : _toggleFollowUser,
                                  showSettings: _isMe,
                                  settingsOnTap: _isMe
                                      ? () => _showSettingsBottomSheet(
                                            context,
                                            isPrivate: user?.isPrivate ?? false,
                                          )
                                      : null,
                                ),
                                if (_isMe)
                                  ProfileBannerCard(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const AccountVerificationScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ProfileTabBar(
                                  controller: _tabController,
                                  selectedIndex: _selectedTab,
                                  showSaved: _isMe,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      body: TabBarView(
                        controller: _tabController,
                        children: [
                          _ArticlesTab(
                            userId: _effectiveUserId,
                            isPrivate: user?.isPrivate ?? false,
                            isMe: _isMe,
                            isFollower: user?.followers.contains(
                                  AuthService().currentUid,
                                ) ??
                                false,
                          ),
                          _LikedTab(
                            userId: _effectiveUserId,
                            isPrivate: user?.isPrivate ?? false,
                            isMe: _isMe,
                            isFollower: user?.followers.contains(
                                  AuthService().currentUid,
                                ) ??
                                false,
                          ),
                          if (_isMe)
                            _SavedTab(userId: _effectiveUserId),
                          _AboutTab(user: user),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArticlesTab extends StatelessWidget {
  const _ArticlesTab({
    required this.userId,
    required this.isPrivate,
    required this.isMe,
    required this.isFollower,
  });
  final String userId;
  final bool isPrivate;
  final bool isMe;
  final bool isFollower;

  @override
  Widget build(BuildContext context) {
    // Show gate if private and viewer is not the owner and not a follower
    if (isPrivate && !isMe && !isFollower) {
      return const _PrivateProfileGate();
    }

    return StreamBuilder<List<PostModel>>(
      stream: AuthService().getUserPostsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return ProfileLayout.constrain(
            context: context,
            padding: EdgeInsets.symmetric(
              horizontal: ProfileLayout.horizontalPadding(context),
            ),
            child: ProfileEmptyState(
              emoji: '📄',
              icon: Icons.article_outlined,
              title: 'No posts yet',
              subtitle: 'Start sharing your thoughts with the community.',
              actionLabel: userId == AuthService().currentUid ? 'Create First Post' : null,
              onActionTap: userId == AuthService().currentUid ? () => CreatePostScreen.show(context) : null,
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            ProfileLayout.horizontalPadding(context),
            12,
            ProfileLayout.horizontalPadding(context),
            24,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ProfileLayout.maxContentWidth(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FeedPostCard(post: post),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LikedTab extends StatelessWidget {
  const _LikedTab({
    required this.userId,
    required this.isPrivate,
    required this.isMe,
    required this.isFollower,
  });
  final String userId;
  final bool isPrivate;
  final bool isMe;
  final bool isFollower;

  @override
  Widget build(BuildContext context) {
    if (isPrivate && !isMe && !isFollower) {
      return const _PrivateProfileGate();
    }

    return StreamBuilder<List<PostModel>>(
      stream: AuthService().getUserLikedPostsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return ProfileLayout.constrain(
            context: context,
            padding: EdgeInsets.symmetric(
              horizontal: ProfileLayout.horizontalPadding(context),
            ),
            child: const ProfileEmptyState(
              emoji: '❤️',
              icon: Icons.favorite_border_rounded,
              title: 'No liked posts yet',
              subtitle: 'Posts you appreciate will appear here.',
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            ProfileLayout.horizontalPadding(context),
            12,
            ProfileLayout.horizontalPadding(context),
            24,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ProfileLayout.maxContentWidth(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FeedPostCard(post: post),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Saved tab — only shown on own profile ────────────────────────────────

class _SavedTab extends StatelessWidget {
  const _SavedTab({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      stream: AuthService().getUserSavedPostsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return ProfileLayout.constrain(
            context: context,
            padding: EdgeInsets.symmetric(
              horizontal: ProfileLayout.horizontalPadding(context),
            ),
            child: const ProfileEmptyState(
              emoji: '🔖',
              icon: Icons.bookmark_border_rounded,
              title: 'No saved posts yet',
              subtitle: 'Tap the bookmark icon on any post to save it here.',
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            ProfileLayout.horizontalPadding(context),
            12,
            ProfileLayout.horizontalPadding(context),
            24,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) => Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ProfileLayout.maxContentWidth(context),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FeedPostCard(post: posts[index]),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({
    required this.user,
  });

  final UserModel? user;

  String _getMonth(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[dt.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final joinedDisplay = user?.createdAt != null
        ? '${_getMonth(user!.createdAt!)} ${user!.createdAt!.year}'
        : 'May 2026';
    final emailDisplay = user?.email ?? 'Not set';
    final birthdayDisplay = user != null && user!.birthday.isNotEmpty
        ? user!.birthday
        : 'Not set';
    final locationDisplay = user != null && user!.location.isNotEmpty
        ? user!.location
        : 'Not set';
    final websiteDisplay = user != null && user!.website.isNotEmpty
        ? user!.website
        : 'Not set';
    final professionDisplay = user != null && user!.profession.isNotEmpty
        ? user!.profession
        : 'Not set';

    return ProfileLayout.constrain(
      context: context,
      padding: EdgeInsets.fromLTRB(
        ProfileLayout.horizontalPadding(context),
        12,
        ProfileLayout.horizontalPadding(context),
        24,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ProfileAboutTile(
              icon: Icons.work_outline_rounded,
              label: 'Profession',
              value: professionDisplay,
            ),
            ProfileAboutTile(
              icon: Icons.mail_outline_rounded,
              label: 'Email',
              value: emailDisplay,
            ),
            ProfileAboutTile(
              icon: Icons.cake_outlined,
              label: 'Birthday',
              value: birthdayDisplay,
            ),
            ProfileAboutTile(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: locationDisplay,
            ),
            ProfileAboutTile(
              icon: Icons.link_rounded,
              label: 'Website',
              value: websiteDisplay,
            ),
            ProfileAboutTile(
              icon: Icons.calendar_today_outlined,
              label: 'Joined',
              value: joinedDisplay,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Settings bottom sheet — sign out + private account toggle
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet({
    required this.isPrivate,
    required this.onSignOut,
  });

  final bool isPrivate;
  final VoidCallback onSignOut;

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late bool _isPrivate;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _isPrivate = widget.isPrivate;
  }

  Future<void> _togglePrivate(bool value) async {
    setState(() {
      _isPrivate = value;
      _updating = true;
    });
    try {
      await AuthService().setPrivateAccount(isPrivate: value);
    } catch (_) {
      // Revert on failure
      if (mounted) setState(() => _isPrivate = !value);
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Container(
      decoration: BoxDecoration(
        color: bichar.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: bichar.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: bichar.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: bichar.border, height: 1),

            // ── Private account toggle ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _updating ? null : () => _togglePrivate(!_isPrivate),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: bichar.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _isPrivate
                                ? Icons.lock_rounded
                                : Icons.lock_open_rounded,
                            color: bichar.accent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Private Account',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: bichar.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isPrivate
                                    ? 'Only followers can see your posts'
                                    : 'Anyone can see your posts',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: bichar.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _updating
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: bichar.accent,
                                ),
                              )
                            : Switch.adaptive(
                                value: _isPrivate,
                                onChanged: _togglePrivate,
                                activeThumbColor: bichar.accent,
                                activeTrackColor:
                                    bichar.accent.withValues(alpha: 0.4),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Private account info banner (shown when enabled)
            if (_isPrivate)
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: bichar.accent.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: bichar.accent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: bichar.accent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'When your account is private, only people you approve can follow you and see your posts in the feed.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: bichar.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            Divider(color: bichar.border, height: 1),

            // ── Sign out ──────────────────────────────────────────────────
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
              ),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: widget.onSignOut,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Private profile gate — shown when a non-follower views a private account
// ─────────────────────────────────────────────────────────────────────────────

class _PrivateProfileGate extends StatelessWidget {
  const _PrivateProfileGate();

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bichar.accent.withValues(alpha: 0.1),
                border: Border.all(
                  color: bichar.accent.withValues(alpha: 0.25),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.lock_rounded,
                size: 36,
                color: bichar.accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'This account is private',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: bichar.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Follow this account to see their posts\nand liked content.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: bichar.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
