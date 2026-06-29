import 'package:flutter/material.dart';

import 'bichar_theme_extension.dart';

/// Shared layout for login, signup, and forgot-password screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.body,
    this.centerContent = false,
    this.maxWidth = 520,
  });

  final Widget body;
  final bool centerContent;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: bichar.textPrimary,
            size: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: centerContent
            ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: body,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: body,
              ),
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleSize = 40,
    this.subtitleSize = 18,
  });

  final String title;
  final String subtitle;
  final double titleSize;
  final double subtitleSize;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            color: bichar.textPrimary,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: subtitleSize,
            height: 1.45,
            color: bichar.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

InputDecoration authFieldDecoration(
  BuildContext context, {
  required String label,
  required String hint,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  final bichar = context.bichar;
  final base = Theme.of(context).inputDecorationTheme;

  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      color: bichar.accent.withValues(alpha: 0.9),
      fontWeight: FontWeight.w600,
      fontSize: 15,
    ),
    hintText: hint,
    hintStyle: TextStyle(
      fontSize: 16,
      color: bichar.textSecondary.withValues(alpha: 0.75),
    ),
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: bichar.mutedIcon)
        : null,
    suffixIcon: suffixIcon,
    filled: base.filled,
    fillColor: bichar.searchFieldBackground,
    contentPadding: base.contentPadding,
    border: base.border,
    enabledBorder: base.enabledBorder,
    focusedBorder: base.focusedBorder,
    errorBorder: base.errorBorder,
    focusedErrorBorder: base.focusedErrorBorder,
  );
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bichar.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: bichar.accent.withValues(alpha: 0.55),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.85),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class AuthDividerLabel extends StatelessWidget {
  const AuthDividerLabel({super.key, this.label = 'or continue with'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Row(
      children: [
        Expanded(
          child: Divider(color: bichar.border, thickness: 1.2),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              color: bichar.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: bichar.border, thickness: 1.2),
        ),
      ],
    );
  }
}

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: bichar.border),
        foregroundColor: bichar.textPrimary,
        backgroundColor: bichar.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AuthGoogleIcon(),
          const SizedBox(width: 12),
          Text(
            'Continue with Google',
            style: TextStyle(
              color: bichar.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthGoogleIcon extends StatelessWidget {
  const AuthGoogleIcon({super.key});

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
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFFDB4437),
          ),
        ),
      ),
    );
  }
}

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prefix,
    required this.linkText,
    this.onTap,
  });

  final String prefix;
  final String linkText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prefix,
          style: TextStyle(
            color: bichar.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: TextStyle(
              color: bichar.accent,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthTextLink extends StatelessWidget {
  const AuthTextLink({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: bichar.accent,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
