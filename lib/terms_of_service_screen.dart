import 'package:flutter/material.dart';
import 'theme/bichar_theme_extension.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const TermsOfServiceScreen(),
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
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: bichar.textPrimary),
            ),
            const SizedBox(height: 8),
            Text('Last Updated: May 2024', style: TextStyle(color: bichar.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            _TermsSection(
              title: '1. Acceptance of Terms',
              content: 'By accessing or using BicharSetu, you agree to be bound by these Terms of Service and all applicable laws and regulations.',
            ),
            _TermsSection(
              title: '2. User Accounts',
              content: 'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
            ),
            _TermsSection(
              title: '3. Content Ownership',
              content: 'You retain ownership of the content you post on BicharSetu. However, by posting content, you grant us a worldwide, non-exclusive license to use, display, and distribute that content.',
            ),
            _TermsSection(
              title: '4. Prohibited Conduct',
              content: 'You agree not to use the service for any unlawful purpose or in any way that violates our Community Guidelines.',
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.title, required this.content});
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
