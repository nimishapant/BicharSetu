import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'app_navigation_drawer.dart';
import 'createpost_screen.dart';
import 'dashboard_app_bar.dart';
import 'model/post_model.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'repo/auth_service.dart';
import 'search_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  static const Color _accent = Color(0xFF6A3DE8);

  int _selectedIndex = 0;
  bool _isRefreshing = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _badgePulseController;
  late final AnimationController _fabPulseController;
  late final Stream<List<PostModel>> _postsStream;

  @override
  void initState() {
    super.initState();
    _postsStream = AuthService().getPostsStream();
    _badgePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _badgePulseController.dispose();
    _fabPulseController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
      _postsStream = AuthService().getPostsStream();
    });
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme.copyWith(
      primary: _accent,
      secondary: const Color(0xFF8B6EFF),
      surface: Colors.white,
    );

    return Theme(
      data: ThemeData.from(colorScheme: colorScheme).copyWith(
        textTheme: theme.textTheme,
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppNavigationDrawer(),
        drawerEnableOpenDragGesture: true,
        body: _selectedIndex == 1
            ? const SearchScreen(showBackButton: false)
            : _selectedIndex == 3
            ? const NotificationScreen(showBackButton: false)
            : SafeArea(
          child: RefreshIndicator(
            color: _accent,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  toolbarHeight: 64,
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  title: DashboardAppBarContent(
                    onProfileTap: () => _scaffoldKey.currentState?.openDrawer(),
                    onSearchTap: () {
                      setState(() => _selectedIndex = 1);
                    },
                    onSparkleTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Featured — coming soon'),
                        ),
                      );
                    },
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(height: 1, color: const Color(0xFFF0EDF8)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: _FeedHeader(isRefreshing: _isRefreshing),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: StreamBuilder<List<PostModel>>(
                    stream: _postsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6A3DE8),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      size: 40, color: Color(0xFF8B84A6)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Could not load posts\n${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF7D7892),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final posts = snapshot.data ?? [];

                      if (posts.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: _EmptyFeedState(),
                        );
                      }

                      return SliverList.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 420 + (index * 70)),
                            curve: Curves.easeOutCubic,
                            tween: Tween(begin: 0, end: 1),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 18 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: PostCard(
                                post: post,
                                accent: _accent,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          selectedIndex: _selectedIndex,
          accent: _accent,
          badgePulseController: _badgePulseController,
          fabPulseController: _fabPulseController,
          onItemTap: (index) {
            if (index == 2) {
              CreatePostScreen.show(context);
              return;
            }
            if (index == 4) {
              Navigator.of(context).push(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 350),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const ProfileScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    );
                  },
                ),
              );
              return;
            }
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.isRefreshing});

  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const Text(
            'Today\'s Feed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D1A29),
            ),
          ),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: isRefreshing
                ? const SizedBox(
                    key: ValueKey('refreshing'),
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    key: ValueKey('idle'),
                    'Pull to refresh',
                    style: TextStyle(
                      color: Color(0xFF7A7690),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeedState extends StatelessWidget {
  const _EmptyFeedState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EDF7)),
      ),
      child: const Column(
        children: [
          Icon(Icons.dynamic_feed_outlined, size: 34, color: Color(0xFF8B84A6)),
          SizedBox(height: 10),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E2940),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Pull down to refresh or tap + to add a new post.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF7D7892),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post, required this.accent});

  final PostModel post;
  final Color accent;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _likeInProgress = false;

  bool get _liked {
    final uid = AuthService().currentUid;
    return uid != null && widget.post.likes.contains(uid);
  }

  /// Generate a consistent avatar color from the username
  Color get _avatarColor {
    final colors = [
      const Color(0xFF7C4DFF),
      const Color(0xFF00897B),
      const Color(0xFFE91E8C),
      const Color(0xFF1565C0),
      const Color(0xFFF57C00),
      const Color(0xFF00796B),
      const Color(0xFFAD1457),
      const Color(0xFF6A3DE8),
    ];
    final hash = widget.post.username.hashCode.abs();
    return colors[hash % colors.length];
  }

  Future<void> _onLikeTap() async {
    if (_likeInProgress) return;
    _likeInProgress = true;
    try {
      await AuthService().toggleLike(widget.post.postId);
    } catch (_) {}
    _likeInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.post.title.isNotEmpty && widget.post.body.isNotEmpty
        ? '${widget.post.title}\n\n${widget.post.body}'
        : widget.post.title.isNotEmpty
            ? widget.post.title
            : widget.post.body;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 1.5,
      shadowColor: const Color(0x1F6A3DE8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0EDF7), width: 1),
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: _avatarColor,
                  child: Text(
                    widget.post.username.isNotEmpty
                        ? widget.post.username.trim().characters.first.toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D1A29),
                        ),
                      ),
                      Text(
                        widget.post.timeAgo,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7E7A93),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.post.category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EAFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.post.category.length > 15
                          ? '${widget.post.category.substring(0, 15)}…'
                          : widget.post.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A3DE8),
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                const Icon(Icons.more_horiz_rounded, color: Color(0xFF88839C)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              displayText,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF2F2A40),
                height: 1.45,
              ),
            ),
            if (widget.post.keywords.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.post.keywords.map((tag) {
                  return Text(
                    '#$tag',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6A3DE8),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                _ActionChip(
                  icon: _liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: '${widget.post.likeCount}',
                  activeColor: widget.accent,
                  isActive: _liked,
                  onTap: _onLikeTap,
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${widget.post.commentCount}',
                  activeColor: widget.accent,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: Icons.send_rounded,
                  label: '${widget.post.shareCount}',
                  activeColor: widget.accent,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final Color activeColor;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFFF0EAFF) : const Color(0xFFF8F7FC),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: isActive ? activeColor : const Color(0xFF706C85),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isActive ? activeColor : const Color(0xFF706C85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.accent,
    required this.badgePulseController,
    required this.fabPulseController,
    required this.onItemTap,
  });

  final int selectedIndex;
  final Color accent;
  final AnimationController badgePulseController;
  final AnimationController fabPulseController;
  final ValueChanged<int> onItemTap;

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  bool _searchTapped = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 96,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x1A241A44),
              blurRadius: 18,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              index: 0,
              selectedIndex: widget.selectedIndex,
              accent: widget.accent,
              onTap: widget.onItemTap,
            ),
            Expanded(
              child: GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _searchTapped = true;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _searchTapped = false;
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _searchTapped = false;
                  });
                },
                onTap: () => widget.onItemTap(1),
                child: AnimatedScale(
                  scale: _searchTapped ? 0.9 : 1.0,
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  child: _NavItem(
                    icon: Icons.search_rounded,
                    activeIcon: Icons.search_rounded,
                    label: 'Search',
                    index: 1,
                    selectedIndex: widget.selectedIndex,
                    accent: widget.accent,
                    onTap: (_) {},
                    isWrappedInExpanded: true,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedAddButton(
                    controller: widget.fabPulseController,
                    accent: widget.accent,
                    onTap: () => widget.onItemTap(2),
                  ),
                ],
              ),
            ),
            _NavItem(
              icon: Icons.notifications_none_rounded,
              activeIcon: Icons.notifications_rounded,
              label: 'Notifications',
              index: 3,
              selectedIndex: widget.selectedIndex,
              accent: widget.accent,
              onTap: widget.onItemTap,
              badgePulseController: widget.badgePulseController,
              showBadge: true,
            ),
            _ProfileNavItem(
              index: 4,
              selectedIndex: widget.selectedIndex,
              accent: widget.accent,
              onTap: widget.onItemTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.accent,
    required this.onTap,
    this.showBadge = false,
    this.badgePulseController,
    this.isWrappedInExpanded = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int selectedIndex;
  final Color accent;
  final ValueChanged<int> onTap;
  final bool showBadge;
  final AnimationController? badgePulseController;
  final bool isWrappedInExpanded;

  @override
  Widget build(BuildContext context) {
    final bool isActive = selectedIndex == index;
    final Color itemColor = isActive ? accent : const Color(0xFF191725);

    final inner = InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 28,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      isActive ? activeIcon : icon,
                      key: ValueKey(isActive),
                      color: itemColor,
                      size: 28,
                    ),
                  ),
                ),
                if (showBadge && badgePulseController != null)
                  Positioned(
                    right: 2,
                    top: 1,
                    child: AnimatedBuilder(
                      animation: badgePulseController!,
                      builder: (context, child) {
                        final pulse =
                            0.85 + (badgePulseController!.value * 0.25);
                        return Transform.scale(scale: pulse, child: child);
                      },
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4A73),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: itemColor,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(label),
          ),
        ],
      ),
    );

    return isWrappedInExpanded ? inner : Expanded(child: inner);
  }
}

class _ProfileNavItem extends StatelessWidget {
  const _ProfileNavItem({
    required this.index,
    required this.selectedIndex,
    required this.accent,
    required this.onTap,
  });

  final int index;
  final int selectedIndex;
  final Color accent;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bool isActive = selectedIndex == index;
    final Color itemColor = isActive ? accent : const Color(0xFF191725);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFF2EEFF) : const Color(0xFFF5F3FA),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isActive ? accent.withValues(alpha: 0.45) : const Color(0xFFE2D9FF),
                  width: 1.4,
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 20,
                color: isActive ? accent : const Color(0xFF2A233D),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: itemColor,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              child: const Text('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedAddButton extends StatelessWidget {
  const AnimatedAddButton({
    super.key,
    required this.controller,
    required this.accent,
    required this.onTap,
  });

  final AnimationController controller;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double t = controller.value;
        final double glow = 0.2 + (0.2 * math.sin(t * math.pi));
        return Transform.scale(
          scale: 0.98 + (0.04 * t),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: glow),
                  blurRadius: 22,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Material(
        color: accent,
        shape: const CircleBorder(),
        elevation: 6,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: 64,
            height: 64,
            child: Icon(Icons.add_rounded, color: Colors.white, size: 38),
          ),
        ),
      ),
    );
  }
}
