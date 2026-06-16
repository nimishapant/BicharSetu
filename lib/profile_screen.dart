import 'package:flutter/material.dart';
import 'account_verification_screen.dart';
import 'createpost_screen.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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

  void _showSettingsBottomSheet(BuildContext context) {
    final bichar = context.bichar;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: bichar.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: bichar.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
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
                  onTap: () async {
                    Navigator.of(context).pop();
                    await AuthService().signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
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
                                  statusCount: '0',
                                  followersCount: '${user?.followers.length ?? 0}',
                                  followingCount: '${user?.following.length ?? 0}',
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
                                      ? () => _showSettingsBottomSheet(context)
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      body: TabBarView(
                        controller: _tabController,
                        children: [
                          _ArticlesTab(userId: _effectiveUserId),
                          _LikedTab(userId: _effectiveUserId),
                          _AboutTab(
                            user: user,
                          ),
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
  const _ArticlesTab({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
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
  const _LikedTab({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
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
