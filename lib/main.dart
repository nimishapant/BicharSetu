import 'package:flutter/material.dart';
import 'premium_settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BicharSetu',
      home: const PremiumSettingsScreen(isPro: false),
    );
  }
}
