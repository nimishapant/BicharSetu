import 'package:flutter/material.dart';
import 'model/post_model.dart';
import 'repo/auth_service.dart';
import 'theme/bichar_theme_extension.dart';
import 'widgets/feed/feed_post_card.dart';
import 'widgets/feed/feed_skeleton.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Scaffold(
      backgroundColor: bichar.drawerBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Premium Trending Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      bichar.accent,
                      bichar.accent.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: bichar.accent.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Trending',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text('Trending options — coming soon'),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The most loved stories and thoughts today',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Trending Posts List
            Expanded(
              child: StreamBuilder<List<PostModel>>(
                stream: AuthService().getPostsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 3,
                      itemBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: FeedLoadingSkeletons(count: 1),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final posts = snapshot.data ?? [];
                  
                  // Sort by popularity: Likes (primary), then Comments (secondary)
                  final trendingPosts = List<PostModel>.from(posts);
                  trendingPosts.sort((a, b) {
                    final aPopularity = a.likeCount + (a.commentCount * 0.5);
                    final bPopularity = b.likeCount + (b.commentCount * 0.5);
                    return bPopularity.compareTo(aPopularity);
                  });

                  if (trendingPosts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.trending_up_rounded, size: 64, color: bichar.textSecondary.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text(
                            'No trending posts yet',
                            style: TextStyle(color: bichar.textSecondary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: trendingPosts.length > 50 ? 50 : trendingPosts.length, // Show top 50
                    itemBuilder: (context, index) {
                      final post = trendingPosts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Stack(
                          children: [
                            FeedPostCard(post: post),
                            // Trending Rank Badge
                            Positioned(
                              top: 12,
                              right: 48,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getRankColor(index, bichar),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getRankColor(index, bichar).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '#${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Color _getRankColor(int index, BicharTheme bichar) {
    if (index == 0) return const Color(0xFFFFD700); // Gold
    if (index == 1) return const Color(0xFFC0C0C0); // Silver
    if (index == 2) return const Color(0xFFCD7F32); // Bronze
    return bichar.accent; // Blue theme
  }
}
