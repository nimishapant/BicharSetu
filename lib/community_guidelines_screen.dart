import 'package:flutter/material.dart';
import 'theme/bichar_theme_extension.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CommunityGuidelinesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Scaffold(
      backgroundColor: bichar.drawerBackground,
      appBar: AppBar(
        backgroundColor: bichar.cardBackground,
        title: const Text('Community Guidelines'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Principles',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: bichar.textPrimary),
            ),
            const SizedBox(height: 16),
            _GuidelineItem(
              title: '1. Respect Others',
              content: 'Treat all members of the community with respect. Harassment, hate speech, and bullying are strictly prohibited.',
            ),
            _GuidelineItem(
              title: '2. Authenticity',
              content: 'Be yourself. Do not impersonate others or spread misinformation.',
            ),
            _GuidelineItem(
              title: '3. Quality Content',
              content: 'Share meaningful and original thoughts. Avoid spamming or low-quality content.',
            ),
            _GuidelineItem(
              title: '4. Safety',
              content: 'Do not share content that promotes violence, self-harm, or illegal activities.',
            ),
            const SizedBox(height: 24),
            Text(
              'Enforcement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: bichar.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              'Violating these guidelines may result in content removal, account warnings, or permanent suspension.',
              style: TextStyle(color: bichar.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  const _GuidelineItem({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: bichar.accent)),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(color: bichar.textPrimary, height: 1.4)),
        ],
      ),
    );
  }
}
