import 'package:flutter/material.dart';
import 'model/post_model.dart';
import 'repo/auth_service.dart';
import 'theme/bichar_theme_extension.dart';
import 'widgets/feed/feed_post_card.dart';
import 'widgets/feed/feed_skeleton.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final uid = AuthService().currentUid;

    return Scaffold(
      backgroundColor: bichar.drawerBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: bichar.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Posts',
          style: TextStyle(
            color: bichar.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: uid == null
          ? const Center(child: Text('Please sign in to view saved posts'))
          : StreamBuilder<List<PostModel>>(
              stream: AuthService().getUserSavedPostsStream(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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

                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border_rounded,
                          size: 64,
                          color: bichar.textSecondary.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No saved posts yet',
                          style: TextStyle(
                            color: bichar.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FeedPostCard(post: post),
                    );
                  },
                );
              },
            ),
    );
  }
}
