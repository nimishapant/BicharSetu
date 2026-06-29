import 'package:flutter/material.dart';

import 'theme/auth_widgets.dart';
import 'theme/bichar_theme_extension.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return AuthScaffold(
      centerContent: true,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthHeader(
              title: 'Forgot Password',
              subtitle:
                  'Enter your registered email address to receive password reset instructions.',
              titleSize: 38,
              subtitleSize: 16,
            ),
            const SizedBox(height: 36),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                fontSize: 16,
                color: bichar.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: authFieldDecoration(
                context,
                label: 'Email Address',
                hint: 'Enter your email',
                prefixIcon: Icons.email_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }

                final emailRegex = RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                );

                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Enter a valid email';
                }

                return null;
              },
            ),
            const SizedBox(height: 32),
            AuthPrimaryButton(
              label: 'Send Reset Link',
              isLoading: _isLoading,
              onPressed: _handleSendResetLink,
            ),
            const SizedBox(height: 8),
            AuthTextLink(
              label: 'Back to Login',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    final bichar = context.bichar;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: bichar.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          'Password reset link sent to ${_emailController.text.trim()}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
