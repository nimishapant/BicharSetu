import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dashboard_screen.dart';
import 'forgetpassword.dart';
import 'repo/auth_service.dart';
import 'signinscreen.dart';
import 'theme/auth_widgets.dart';
import 'theme/bichar_theme_extension.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 14),
                Image.asset(
                  'assets/images/bichar_logo.png',
                  height: 96,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.account_balance,
                    size: 96,
                    color: bichar.accent,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'BicharSetu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: bichar.textPrimary,
                  ),
                ),
                Text(
                  'A platform for thoughts that connect',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: bichar.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 44),
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: bichar.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to continue to your account',
                  style: TextStyle(
                    fontSize: 22,
                    color: bichar.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(
                    fontSize: 16,
                    color: bichar.textPrimary,
                  ),
                  decoration: authFieldDecoration(
                    context,
                    label: 'Email or Username',
                    hint: 'Enter your email or username',
                    prefixIcon: Icons.mail_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email or username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(
                    fontSize: 16,
                    color: bichar.textPrimary,
                  ),
                  decoration: authFieldDecoration(
                    context,
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ForgetPasswordScreen(),
                              ),
                            );
                          },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: bichar.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                AuthPrimaryButton(
                  label: 'Login',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 26),
                const AuthDividerLabel(),
                const SizedBox(height: 20),
                AuthGoogleButton(onPressed: _isLoading ? null : () {}),
                const SizedBox(height: 30),
                AuthFooterLink(
                  prefix: "Don't have an account? ",
                  linkText: 'Sign Up',
                  onTap: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignInScreen(),
                            ),
                          );
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final emailOrUsername = _emailController.text.trim();
      final password = _passwordController.text;

      await AuthService().signInWithEmailOrUsername(
        emailOrUsername: emailOrUsername,
        password: password,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged in successfully as $emailOrUsername'),
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
          content: Text(e.message ?? 'Login failed. Please try again.'),
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
