import 'package:flutter/material.dart';
import 'theme/bichar_theme_extension.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PrivacyPolicyScreen(),
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
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: bichar.textPrimary),
            ),
            const SizedBox(height: 8),
            Text('Last Updated: May 2024', style: TextStyle(color: bichar.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            _PolicySection(
              title: 'Data Collection',
              content: 'We collect information you provide directly to us, such as when you create an account, post content, or contact support. This includes your username, email address, and profile information.',
            ),
            _PolicySection(
              title: 'Use of Information',
              content: 'We use the information we collect to provide, maintain, and improve our services, develop new features, and protect BicharSetu and our users.',
            ),
            _PolicySection(
              title: 'Data Sharing',
              content: 'We do not sell your personal data. We may share information with service providers who perform services on our behalf, or when required by law.',
            ),
            _PolicySection(
              title: 'Security',
              content: 'We take reasonable measures to help protect your personal information from loss, theft, misuse, and unauthorized access.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: bichar.textPrimary)),
          const SizedBox(height: 10),
          Text(content, style: TextStyle(color: bichar.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}
