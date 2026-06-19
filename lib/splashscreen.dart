import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';
import 'loginScreen.dart';

// Colours sampled directly from the logo image
const Color _bgDark    = Color(0xFF1E1E1E); // charcoal background
const Color _purpleMid = Color(0xFF5C2ECC); // mid-purple (bridge)
const Color _purpleTop = Color(0xFF7B44F0); // lighter top arc

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Logo: fades + scales in during first 65%
    _logoFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );
    _logoScale = Tween(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    // "BicharSetu" text: slides up + fades in during last 50%
    _textFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _textSlide = Tween(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _ctrl.forward();

    // Navigate after animation + a short hold
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) =>
              user != null ? const DashboardScreen() : const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Exact charcoal from the image
      backgroundColor: _bgDark,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Large logo image ────────────────────────────────────
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Image.asset(
                      'assets/images/bichar_logo.png',
                      width: MediaQuery.sizeOf(context).width * 0.70,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _FallbackLogo(),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── "BicharSetu" wordmark matching the image font ───────
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: const Text(
                      'BicharSetu',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: _purpleMid,
                        letterSpacing: 0.5,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Tagline ─────────────────────────────────────────────
                FadeTransition(
                  opacity: _textFade,
                  child: Text(
                    'Bridging Thoughts',
                    style: TextStyle(
                      fontSize: 13,
                      color: _purpleTop.withValues(alpha: 0.55),
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Shown if the asset is missing — matches the logo colour palette
class _FallbackLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _purpleMid.withValues(alpha: 0.15),
      ),
      child: const Icon(
        Icons.edit_note_rounded,
        size: 80,
        color: _purpleMid,
      ),
    );
  }
}
