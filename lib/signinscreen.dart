import 'package:flutter/material.dart';
import 'loginScreen.dart';
import 'repo/auth_service.dart';
import 'dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Palette from LoginScreen
const Color _bgDark      = Color(0xFF1E1E1E); 
const Color _cardBg      = Color(0xFF272727); 
const Color _purpleMid   = Color(0xFF5C2ECC); 
const Color _purpleLight = Color(0xFF7B44F0); 
const Color _border      = Color(0xFF3A2E55); 
const Color _textWhite   = Color(0xFFF0ECFF); 
const Color _textMuted   = Color(0xFF8878AA); 
const Color _fieldBg     = Color(0xFF232323); 

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                // Top: App bar replacement for dark theme
                Container(
                  width: double.infinity,
                  color: _bgDark,
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top + 20,
                    bottom: 20,
                    left: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textWhite, size: 22),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Join Community',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _textWhite,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content Card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                    decoration: const BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: _textWhite,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Welcome! Join our community today.',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: _textMuted,
                            ),
                          ),
                          const SizedBox(height: 26),

                          _Field(
                            controller: _usernameController,
                            label: 'Username',
                            hint: 'Choose a username',
                            icon: Icons.alternate_email_rounded,
                            action: TextInputAction.next,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter username' : null,
                          ),
                          const SizedBox(height: 14),
                          
                          _Field(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'Enter your email',
                            icon: Icons.email_outlined,
                            action: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter email' : null,
                          ),
                          const SizedBox(height: 14),

                          _Field(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePassword,
                            action: TextInputAction.next,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: _textMuted,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Please enter password' : null,
                          ),
                          const SizedBox(height: 14),

                          _Field(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hint: 'Confirm your password',
                            icon: Icons.lock_reset_rounded,
                            obscure: _obscureConfirmPassword,
                            action: TextInputAction.done,
                            suffix: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: _textMuted,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Please confirm password';
                              if (v != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Sign Up Button
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
                              onPressed: _isLoading ? null : _handleRegister,
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
                                      'Sign Up',
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
                            const Expanded(child: Divider(color: _border, thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or sign up with',
                                style: TextStyle(color: _textMuted, fontSize: 12),
                              ),
                            ),
                            const Expanded(child: Divider(color: _border, thickness: 1)),
                          ]),
                          const SizedBox(height: 16),

                          // Google button
                          OutlinedButton(
                            onPressed: _isLoading ? null : () {}, // AuthService Google sign up could go here
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _border, width: 1.4),
                              padding: const EdgeInsets.symmetric(vertical: 14),
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

                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(color: _textMuted, fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () => Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                                          (route) => false,
                                        ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: _purpleLight,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await AuthService().signUpWithEmailAndPassword(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully!'),
          backgroundColor: _purpleMid,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(e.message ?? 'Registration failed.');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// Reusable Field component matching LoginScreen
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
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputAction action;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: action,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: _textWhite),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textMuted, fontSize: 13, fontWeight: FontWeight.w500),
        hintText: hint,
        hintStyle: TextStyle(color: _textMuted.withValues(alpha: 0.55), fontSize: 14),
        prefixIcon: Icon(icon, color: _textMuted, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
        ),
      ),
    );
  }
}

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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFDB4437)),
        ),
      ),
    );
  }
}
