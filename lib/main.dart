import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'splashscreen.dart';
import 'theme/app_localizations.dart';
import 'theme/app_theme.dart';
import 'theme/privacy_controller.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await GoogleSignIn.instance.initialize();
  } catch (_) {
    // Ignore Google Sign-In initialization errors
  }

  final themeController = ThemeController();
  await themeController.load();

  final privacyController = PrivacyController();
  await privacyController.load();

  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;

  const MyApp({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Bichar Setu',
          theme: AppTheme.light(
            accentColor: themeController.accentColor,
            fontFamily: themeController.fontFamily,
          ),
          darkTheme: AppTheme.dark(
            accentColor: themeController.accentColor,
            fontFamily: themeController.fontFamily,
          ),
          themeMode: themeController.themeMode,
          locale: themeController.locale,
          localizationsDelegates: [
            const AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ne'),
            Locale('ja'),
            Locale('zh'),
          ],
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(themeController.textScaleFactor),
              ),
              child: child!,
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
