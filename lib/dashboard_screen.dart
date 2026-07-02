import 'dart:async';

import 'package:flutter/material.dart';
import 'app_navigation_drawer.dart';
import 'theme/bichar_theme_extension.dart';
import 'createpost_screen.dart';
import 'dashboard_app_bar.dart';
import 'model/post_model.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'repo/auth_service.dart';
import 'search_screen.dart';
import 'widgets/feed/feed_bottom_nav.dart';
import 'widgets/feed/feed_header.dart';
import 'widgets/feed/feed_layout.dart';
import 'widgets/feed/feed_post_card.dart';
import 'widgets/feed/feed_skeleton.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isRefreshing = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _badgePulseController;
  late final AnimationController _fabPulseController;
  late Stream<List<PostModel>> _postsStream;

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
    final bichar = context.bichar;

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
      backgroundColor: bichar.drawerBackground,
      drawer: const AppNavigationDrawer(),
      drawerEnableOpenDragGesture: true,
      body: _selectedIndex == 1
          ? const SearchScreen(showBackButton: false)
          : _selectedIndex == 3
              ? const NotificationScreen(showBackButton: false)
              : SafeArea(
                  child: RefreshIndicator(
                    color: bichar.accent,
                    backgroundColor: bichar.cardBackground,
                    strokeWidth: 2.5,
                    displacement: 48,
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
                          backgroundColor: bichar.cardBackground,
                          surfaceTintColor: Colors.transparent,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          toolbarHeight: 68,
                          automaticallyImplyLeading: false,
                          titleSpacing: 0,
                          title: DashboardAppBarContent(
                            onProfileTap: () =>
                                _scaffoldKey.currentState?.openDrawer(),
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
                            child: Container(
                              height: 1,
                              color: bichar.border.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: FeedLayout.constrain(
                            context: context,
                            padding: EdgeInsets.fromLTRB(
                              FeedLayout.horizontalPadding(context),
                              16,
                              FeedLayout.horizontalPadding(context),
                              0,
                            ),
                            child: FeedHeader(isRefreshing: _isRefreshing),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            FeedLayout.horizontalPadding(context),
                            0,
                            FeedLayout.horizontalPadding(context),
                            100,
                          ),
                          sliver: StreamBuilder<List<PostModel>>(
                            stream: _postsStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SliverToBoxAdapter(
                                  child: FeedLayout.constrain(
                                    context: context,
                                    padding: EdgeInsets.zero,
                                    child: const FeedLoadingSkeletons(count: 4),
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
                                          Icon(
                                            Icons.error_outline_rounded,
                                            size: 40,
                                            color: bichar.textSecondary,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Could not load posts\n${snapshot.error}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: bichar.textSecondary,
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
                                return SliverToBoxAdapter(
                                  child: FeedLayout.constrain(
                                    context: context,
                                    padding: EdgeInsets.zero,
                                    child: const FeedEmptyState(),
                                  ),
                                );
                              }

                              return SliverList.builder(
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  final post = posts[index];
                                  return Center(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: FeedLayout.maxContentWidth(
                                          context,
                                        ),
                                      ),
                                      child: TweenAnimationBuilder<double>(
                                        duration: Duration(
                                          milliseconds: 420 + (index * 70),
                                        ),
                                        curve: Curves.easeOutCubic,
                                        tween: Tween(begin: 0, end: 1),
                                        builder: (context, value, child) {
                                          return Opacity(
                                            opacity: value,
                                            child: Transform.translate(
                                              offset: Offset(
                                                0,
                                                20 * (1 - value),
                                              ),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          child: FeedPostCard(post: post),
                                        ),
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
      bottomNavigationBar: FeedBottomNav(
        selectedIndex: _selectedIndex,
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
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
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
