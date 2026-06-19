import 'package:flutter/material.dart';
import 'forgetpassword.dart';
import 'signinscreen.dart';
import 'repo/auth_service.dart';
import 'dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Exact palette from the BicharSetu logo image
const Color _bgDark      = Color(0xFF1E1E1E); // charcoal background
const Color _cardBg      = Color(0xFF272727); // slightly lighter card
const Color _purpleMid   = Color(0xFF5C2ECC); // main purple
const Color _purpleLight = Color(0xFF7B44F0); // lighter/hover purple
const Color _border      = Color(0xFF3A2E55); // subtle border
const Color _textWhite   = Color(0xFFF0ECFF); // near-white text
const Color _textMuted   = Color(0xFF8878AA); // muted helper text
const Color _fieldBg     = Color(0xFF232323); // input field bg

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  bool _obscure      = true;
  bool _isLoading    = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: _bgDark,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height),
          child: IntrinsicHeight(
            child: Column(
              children: [

                // ── Top: logo + wordmark exactly as the image ───────────
                Container(
                  width: double.infinity,
                  color: _bgDark,
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top + 32,
                    bottom: 24,
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/bichar_logo.png',
                        width: size.width * 0.52,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.edit_note_rounded,
                          size: 90,
                          color: _purpleMid,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'BicharSetu',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: _purpleMid,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'A platform for thoughts that connect',
                        style: TextStyle(
                          fontSize: 12,
                          color: _purpleLight.withValues(alpha: 0.55),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bottom: form card ────────────────────────────────────
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                    decoration: const BoxDecoration(
                      color: _cardBg,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          // Heading
                          const Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: _textWhite,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Login to continue to your account',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: _textMuted,
                            ),
                          ),
                          const SizedBox(height: 26),

                          // Email / Username
                          _Field(
                            controller: _emailCtrl,
                            label: 'Email or Username',
                            hint: 'Enter your email or username',
                            icon: Icons.person_outline_rounded,
                            action: TextInputAction.next,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Please enter email or username'
                                    : null,
                          ),
                          const SizedBox(height: 14),

                          // Password
                          _Field(
                            controller: _passCtrl,
                            label: 'Password',
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscure,
                            action: TextInputAction.done,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _textMuted,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty)
                                    ? 'Please enter password'
                                    : null,
                          ),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgetPasswordScreen(),
                                        ),
                                      ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: _purpleLight,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Login button — purple gradient like the logo
                          Container(
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [_purpleMid, _purpleLight],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _purpleMid.withValues(alpha: 0.45),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          Row(children: [
                            const Expanded(
                                child: Divider(
                                    color: _border, thickness: 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or continue with',
                                style: TextStyle(
                                    color: _textMuted, fontSize: 12),
                              ),
                            ),
                            const Expanded(
                                child: Divider(
                                    color: _border, thickness: 1)),
                          ]),
                          const SizedBox(height: 16),

                          // Google button
                          OutlinedButton(
                            onPressed:
                                _isLoading ? null : _handleGoogleLogin,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: _border, width: 1.4),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                _GoogleIcon(),
                                SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    color: _textWhite,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sign-up link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                    color: _textMuted, fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const SignInScreen(),
                                          ),
                                        ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: _purpleLight,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService().signInWithEmailOrUsername(
        emailOrUsername: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(e.message ?? 'Login failed.');
    } catch (e) {
      if (mounted) _showError('An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().signInWithGoogle();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted && e.code != 'sign-in-aborted') {
        _showError(e.message ?? 'Google Sign-In failed.');
      }
    } catch (e) {
      if (mounted) _showError('An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        content: Text(msg,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Dark-themed input field ───────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.action,
    this.obscure = false,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputAction action;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: action,
      style: const TextStyle(fontSize: 15, color: _textWhite),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: _textMuted, fontSize: 13, fontWeight: FontWeight.w500),
        hintText: hint,
        hintStyle:
            TextStyle(color: _textMuted.withValues(alpha: 0.55), fontSize: 14),
        prefixIcon: Icon(icon, color: _textMuted, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: _fieldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _purpleMid, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.6),
        ),
      ),
    );
  }
}

// ── Google icon ───────────────────────────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Image.asset(
        'assets/images/google_logo.png',
        width: 18,
        height: 18,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Text(
          'G',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDB4437)),
        ),
      ),
    );
  }
}
