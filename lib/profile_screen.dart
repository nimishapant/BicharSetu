

import 'package:flutter/material.dart';
import 'profileedit_screen.dart';
import 'theme/bichar_theme_extension.dart';
import 'repo/auth_service.dart';
import 'model/user_model.dart';
import 'loginScreen.dart';

// ─── Theme constants (matches dashboard_screen.dart) ────────────────────────
const Color _accent = Color(0xFF6A3DE8);
const Color _accentLight = Color(0xFF8B6EFF);
const Color _surface = Colors.white;
const Color _textDark = Color(0xFF1D1A29);
const Color _textMid = Color(0xFF7A7690);
const Color _border = Color(0xFFF0EDF7);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 5),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1A29),
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.of(context).pop(); // Close bottom sheet
                  await AuthService().signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  String _getMonth(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[dt.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: AuthService().currentUserModelStream,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final usernameDisplay = user?.username ?? 'Aditya';
        final emailDisplay = user?.email ?? 'adityasama98@gmail.com';
        final bioDisplay = user?.aboutMe ?? '';
        final profilePhotoUrl = user?.profilePhoto ?? '';
        final joinedDisplay = user?.createdAt != null
            ? '${_getMonth(user!.createdAt!)} ${user.createdAt!.year}'
            : 'May 2026';

        final bichar = context.bichar;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // ── App bar ──────────────────────────────────────────────────────
                _ProfileAppBar(bichar: bichar),
                // ── Scrollable body ──────────────────────────────────────────────
                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, _) => [
                      SliverToBoxAdapter(
                        child: _ProfileHeader(
                          username: usernameDisplay,
                          displayName: usernameDisplay,
                          profilePhotoUrl: profilePhotoUrl,
                          bichar: bichar,
                        ),
                      ),
                      SliverToBoxAdapter(child: _StatsRow(bichar: bichar)),
                      SliverToBoxAdapter(
                        child: _BioSection(bio: bioDisplay, bichar: bichar),
                      ),
                      SliverToBoxAdapter(
                        child: _ActionRow(
                          onSettingsTap: () => _showSettingsBottomSheet(context),
                        ),
                      ),
                      SliverToBoxAdapter(child: _VerifiedBanner()),
                      SliverToBoxAdapter(
                        child: _TabBar(
                          controller: _tabController,
                          selectedIndex: _selectedTab,
                          bichar: bichar,
                        ),
                      ),
                    ],
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        const _ArticlesTab(),
                        const _LikedTab(),
                        _AboutTab(joinedDate: joinedDisplay, email: emailDisplay),
                      ],
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

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar({required this.bichar});

  final BicharTheme bichar;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bichar.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_rounded, color: bichar.textPrimary, size: 26),
            tooltip: 'Back to home',
          ),
          Expanded(
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: bichar.textPrimary,
              ),
            ),
          ),
          _IconBtn(icon: Icons.search_rounded, onTap: () {}, bichar: bichar),
          const SizedBox(width: 2),
          _IconBtn(icon: Icons.notifications_none_rounded, onTap: () {}, bichar: bichar),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    required this.bichar,
  });
  final IconData icon;
  final VoidCallback onTap;
  final BicharTheme bichar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: bichar.textPrimary, size: 24),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Header (avatar + name + camera)
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String username;
  final String displayName;
  final String profilePhotoUrl;
  final BicharTheme bichar;

  const _ProfileHeader({
    required this.username,
    required this.displayName,
    required this.profilePhotoUrl,
    required this.bichar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bichar.cardBackground,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      child: Stack(
        children: [
          // Camera icon top-right
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF2EEFF),
                shape: BoxShape.circle,
                border: Border.all(color: bichar.border, width: 1.2),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 18,
                color: _textMid,
              ),
            ),
          ),
          // Avatar + name row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with + badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEDE8FB),
                      border: Border.all(color: bichar.accent.withValues(alpha: 0.25), width: 2.5),
                    ),
                    child: profilePhotoUrl.isEmpty
                        ? const Icon(
                            Icons.person_rounded,
                            size: 44,
                            color: Color(0xFFB0A8CC),
                          )
                        : ClipOval(
                            child: Image.network(
                              profilePhotoUrl,
                              fit: BoxFit.cover,
                              width: 76,
                              height: 76,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person_rounded,
                                  size: 44,
                                  color: Color(0xFFB0A8CC),
                                );
                              },
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: bichar.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Name & username
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: bichar.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@$username',
                    style: TextStyle(
                      fontSize: 14,
                      color: bichar.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.bichar});

  final BicharTheme bichar;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bichar.cardBackground,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      child: Row(
        children: const [
          _StatItem(count: '0', label: 'Stories'),
          _StatDivider(),
          _StatItem(count: '0', label: 'Status'),
          _StatDivider(),
          _StatItem(count: '0', label: 'Followers'),
          _StatDivider(),
          _StatItem(count: '0', label: 'Following'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.count, required this.label});
  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _textMid,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: _border,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bio Section
// ─────────────────────────────────────────────────────────────────────────────
class _BioSection extends StatelessWidget {
  final String bio;
  final BicharTheme bichar;
  const _BioSection({required this.bio, required this.bichar});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: bichar.cardBackground,
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
      child: Text(
        bio.isEmpty ? 'Add a bio to tell your story...' : bio,
        style: TextStyle(
          fontSize: 14,
          color: bichar.textSecondary,
          fontStyle: bio.isEmpty ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Profile + Settings button row
// ─────────────────────────────────────────────────────────────────────────────
class _ActionRow extends StatelessWidget {
  final VoidCallback onSettingsTap;
  const _ActionRow({required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Row(
        children: [
          // Edit Profile button — accent purple (replaces the orange/red)
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileEditScreen(),
                    ),
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_accent, _accentLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const SizedBox(
                    height: 48,
                    child: Center(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Settings button
          GestureDetector(
            onTap: onSettingsTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _border, width: 1.5),
                color: const Color(0xFFF8F7FC),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: _textMid,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Verified BicharSetu Banner
// ─────────────────────────────────────────────────────────────────────────────
class _VerifiedBanner extends StatefulWidget {
  @override
  State<_VerifiedBanner> createState() => _VerifiedBannerState();
}

class _VerifiedBannerState extends State<_VerifiedBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              'SPONSORED • BICHAR SETU',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: _textMid,
                letterSpacing: 1.0,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _shimmer,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment(-1 + _shimmer.value * 2, 0),
                    end: Alignment(1 + _shimmer.value * 2, 0),
                    colors: const [
                      Color(0xFF5B35D5),
                      Color(0xFF6A3DE8),
                      Color(0xFF8B6EFF),
                      Color(0xFF6A3DE8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Be a Verified BicharSetu! ⭐',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Get the exclusive verified badge.\nBuild trust and stand out.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Tab Bar
// ─────────────────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.controller,
    required this.selectedIndex,
    required this.bichar,
  });
  final TabController controller;
  final int selectedIndex;
  final BicharTheme bichar;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bichar.cardBackground,
      margin: const EdgeInsets.only(top: 10),
      child: TabBar(
        controller: controller,
        labelColor: bichar.accent,
        unselectedLabelColor: bichar.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicatorColor: bichar.accent,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: bichar.border,
        tabs: const [
          Tab(text: 'Articles (0)'),
          Tab(text: 'Liked (0)'),
          Tab(text: 'About'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab content: Articles
// ─────────────────────────────────────────────────────────────────────────────
class _ArticlesTab extends StatelessWidget {
  const _ArticlesTab();

  @override
  Widget build(BuildContext context) {
    return _EmptyTabState(
      icon: Icons.article_outlined,
      message: 'No articles found.',
      sub: 'Tap + to publish your first article.',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab content: Liked
// ─────────────────────────────────────────────────────────────────────────────
class _LikedTab extends StatelessWidget {
  const _LikedTab();

  @override
  Widget build(BuildContext context) {
    return _EmptyTabState(
      icon: Icons.favorite_border_rounded,
      message: 'No liked posts yet.',
      sub: 'Posts you like will appear here.',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab content: About
// ─────────────────────────────────────────────────────────────────────────────
class _AboutTab extends StatelessWidget {
  final String joinedDate;
  final String email;

  const _AboutTab({
    required this.joinedDate,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _AboutTile(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: email,
          ),
          const SizedBox(height: 10),
          _AboutTile(
            icon: Icons.cake_outlined,
            label: 'Birthday',
            value: 'Not set',
          ),
          const SizedBox(height: 10),
          _AboutTile(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: 'Not set',
          ),
          const SizedBox(height: 10),
          _AboutTile(
            icon: Icons.link_rounded,
            label: 'Website',
            value: 'Not set',
          ),
          const SizedBox(height: 10),
          _AboutTile(
            icon: Icons.calendar_today_outlined,
            label: 'Joined',
            value: joinedDate,
          ),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF2EEFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _accent, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: _textMid,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: _textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared empty-state widget
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({
    required this.icon,
    required this.message,
    required this.sub,
  });
  final IconData icon;
  final String message;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFF2EEFF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: _accent),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: _textMid,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
