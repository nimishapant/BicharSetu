import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dashboard_screen.dart';
import 'loginScreen.dart';
import 'repo/auth_service.dart';
import 'theme/auth_widgets.dart';
import 'theme/bichar_theme_extension.dart';

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
    final bichar = context.bichar;

    return AuthScaffold(
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            const AuthHeader(
              title: 'Create Account',
              subtitle: 'Welcome! Join our community today.',
              titleSize: 40,
              subtitleSize: 18,
            ),
            const SizedBox(height: 28),
            _buildTextField(
              controller: _usernameController,
              label: 'Username',
              hint: 'Choose a username',
              validatorText: 'Please enter username',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              validatorText: 'Please enter email',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              validatorText: 'Please enter password',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: bichar.mutedIcon,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              validatorText: 'Please confirm password',
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: bichar.mutedIcon,
                ),
              ),
            ),
            const SizedBox(height: 28),
            AuthPrimaryButton(
              label: 'Sign Up',
              isLoading: _isLoading,
              onPressed: _handleRegister,
            ),
            const SizedBox(height: 28),
            const AuthDividerLabel(),
            const SizedBox(height: 20),
            AuthGoogleButton(onPressed: _isLoading ? null : () {}),
            const SizedBox(height: 24),
            AuthFooterLink(
              prefix: 'Already have an account? ',
              linkText: 'Login',
              onTap: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String validatorText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    final bichar = context.bichar;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 16,
        color: bichar.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: authFieldDecoration(
        context,
        label: label,
        hint: hint,
        suffixIcon: suffixIcon,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return validatorText;
        if (label == 'Confirm Password' && value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().signUpWithEmailAndPassword(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Account created successfully! Welcome to BicharSetu.',
          ),
          backgroundColor: context.bichar.accent,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Registration failed. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
