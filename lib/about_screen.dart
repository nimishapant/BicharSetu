import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'theme/bichar_theme_extension.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AboutScreen(),
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
        title: const Text('About BicharSetu'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 120),
              const SizedBox(height: 24),
              Text(
                'BicharSetu',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: bichar.accent),
              ),
              const SizedBox(height: 12),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.data?.version ?? '1.0.0';
                  final build = snapshot.data?.buildNumber ?? '1';
                  return Text(
                    'Version $version ($build)',
                    style: TextStyle(color: bichar.textSecondary, fontWeight: FontWeight.w600),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'BicharSetu is a platform for sharing thoughts, stories, and ideas. We believe in the power of expression and community.',
                textAlign: TextAlign.center,
                style: TextStyle(color: bichar.textPrimary, height: 1.6, fontSize: 15),
              ),
              const Spacer(),
              Text(
                '© 2024 BicharSetu Team',
                style: TextStyle(color: bichar.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
