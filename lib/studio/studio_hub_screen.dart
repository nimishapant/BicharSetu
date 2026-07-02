import 'package:flutter/material.dart';
import '../theme/bichar_theme_extension.dart';

class StudioHubScreen extends StatelessWidget {
  const StudioHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Scaffold(
      backgroundColor: bichar.drawerBackground,
      appBar: AppBar(
        backgroundColor: bichar.cardBackground,
        title: const Text('BicharSetu Studio'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_outlined, size: 64, color: bichar.accent),
            const SizedBox(height: 16),
            Text(
              'Studio Hub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: bichar.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your creator tools are coming soon.',
              style: TextStyle(
                fontSize: 15,
                color: bichar.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
