import 'package:flutter/material.dart';
import 'theme/bichar_theme_extension.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key, this.initialTab = 0});
  final int initialTab;

  static Future<void> open(BuildContext context, {int initialTab = 0}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HelpCenterScreen(initialTab: initialTab),
      ),
    );
  }

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Scaffold(
      backgroundColor: bichar.drawerBackground,
      appBar: AppBar(
        backgroundColor: bichar.cardBackground,
        title: const Text('Help & Support'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: bichar.accent,
          unselectedLabelColor: bichar.textSecondary,
          indicatorColor: bichar.accent,
          tabs: const [
            Tab(text: 'FAQ'),
            Tab(text: 'Contact'),
            Tab(text: 'Report'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FaqTab(),
          _ContactTab(),
          _ReportTab(),
        ],
      ),
    );
  }
}

class _FaqTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _FaqItem(
          question: 'How do I create a post?',
          answer: 'Tap the "+" icon in the bottom navigation bar to start writing your story.',
        ),
        _FaqItem(
          question: 'How can I change my profile photo?',
          answer: 'Go to Settings > Your account > Edit Profile to update your photo.',
        ),
        _FaqItem(
          question: 'Is BicharSetu free to use?',
          answer: 'Yes, basic features are free. We also offer a Pro subscription for advanced features.',
        ),
      ],
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return ExpansionTile(
      title: Text(question, style: TextStyle(fontWeight: FontWeight.w700, color: bichar.textPrimary)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: TextStyle(color: bichar.textSecondary, height: 1.5)),
        ),
      ],
    );
  }
}

class _ContactTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.email_outlined, size: 64, color: Colors.blueAccent),
          const SizedBox(height: 24),
          Text(
            'Contact Our Support Team',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: bichar.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'We usually respond within 24 hours. You can reach us at:',
            textAlign: TextAlign.center,
            style: TextStyle(color: bichar.textSecondary),
          ),
          const SizedBox(height: 24),
          Text(
            'support@bicharsetu.com',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: bichar.accent),
          ),
        ],
      ),
    );
  }
}

class _ReportTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Report a Problem',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: bichar.textPrimary),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Describe the issue you encountered...',
              fillColor: bichar.cardBackground,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted. Thank you!')),
              );
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }
}
