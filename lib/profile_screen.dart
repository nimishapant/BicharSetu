import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─── Theme constants (matches dashboard_screen.dart) ────────────────────────
const Color _accent = Color(0xFF6A3DE8);
const Color _accentLight = Color(0xFF8B6EFF);
const Color _bg = Color(0xFFF7F7FB);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────────────
            _ProfileAppBar(),
            // ── Scrollable body ──────────────────────────────────────────────
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverToBoxAdapter(child: _ProfileHeader()),
                  SliverToBoxAdapter(child: _StatsRow()),
                  SliverToBoxAdapter(child: _BioSection()),
                  SliverToBoxAdapter(child: _ActionRow()),
                  SliverToBoxAdapter(child: _VerifiedBanner()),
                  SliverToBoxAdapter(
                    child: _TabBar(
                      controller: _tabController,
                      selectedIndex: _selectedTab,
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: const [
                    _ArticlesTab(),
                    _LikedTab(),
                    _AboutTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Text(
              'BicharSetu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _textDark,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const Spacer(),
          _IconBtn(icon: Icons.search_rounded, onTap: () {}),
          const SizedBox(width: 6),
          _IconBtn(icon: Icons.notifications_none_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: _textDark, size: 24),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Header (avatar + name + camera)
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
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
                border: Border.all(color: _border, width: 1.2),
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
                      border: Border.all(color: _accent.withOpacity(0.25), width: 2.5),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 44,
                      color: Color(0xFFB0A8CC),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: _accent,
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
                  const Text(
                    'Aditya',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@aditya',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textMid,
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
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _surface,
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
      child: const Text(
        'Add a bio to tell your story...',
        style: TextStyle(
          fontSize: 14,
          color: _textMid,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Profile + Settings button row
// ─────────────────────────────────────────────────────────────────────────────
class _ActionRow extends StatelessWidget {
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
                onTap: () {},
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
                        color: _accent.withOpacity(0.35),
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
          Container(
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
                      color: _accent.withOpacity(0.3),
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
                      color: Colors.white.withOpacity(0.2),
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
  const _TabBar({required this.controller, required this.selectedIndex});
  final TabController controller;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      margin: const EdgeInsets.only(top: 10),
      child: TabBar(
        controller: controller,
        labelColor: _accent,
        unselectedLabelColor: _textMid,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicatorColor: _accent,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: _border,
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
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
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
            value: 'May 2026',
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
