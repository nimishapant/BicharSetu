import 'package:flutter/material.dart';

const Color _bg = Color(0xFFF7F7FB);
const Color _surface = Colors.white;
const Color _headerTint = Color(0xFFE8F1FF);
const Color _textDark = Color(0xFF1D1A29);
const Color _textMid = Color(0xFF7A7690);
const Color _bluePrimary = Color(0xFF1565C0);
const Color _blueDark = Color(0xFF0D47A1);
const Color _blueLight = Color(0xFFE3F2FD);
const Color _cardBorder = Color(0xFFE0E4EC);
const Color _cardBg = Color(0xFFF8FAFD);
const Color _tipBg = Color(0xFFE3F2FD);
const Color _tipText = Color(0xFF0D47A1);

const String _changePasswordIcon =
    'assets/images/change_password_passkey.png';
const String _twoFactorIcon = 'assets/images/two_factor_shield.png';
const String _activeSessionIcon = 'assets/images/active_session_phone.png';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SecuritySettingsScreen(),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('$label — coming soon'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SecurityTopBar(
              onBack: () => Navigator.of(context).pop(),
              onSearchTap: () => _showComingSoon(context, 'Search settings'),
              onSparkleTap: () => _showComingSoon(context, 'Featured'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SecurityHeader(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Column(
                        children: [
                          _SecurityOptionCard(
                            imageAsset: _changePasswordIcon,
                            iconBg: _blueLight,
                            title: 'Change Password',
                            subtitle: 'Update your account password',
                            onTap: () =>
                                _showComingSoon(context, 'Change Password'),
                          ),
                          const SizedBox(height: 12),
                          _SecurityOptionCard(
                            imageAsset: _twoFactorIcon,
                            iconBg: _blueLight,
                            title: 'Two-Factor Authentication',
                            subtitle: 'Add an extra layer of protection',
                            badge: 'RECOMMENDED',
                            onTap: () => _showComingSoon(
                              context,
                              'Two-Factor Authentication',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SecurityOptionCard(
                            imageAsset: _activeSessionIcon,
                            iconBg: _blueLight,
                            title: 'Active Sessions',
                            subtitle: 'Manage logged-in devices',
                            onTap: () =>
                                _showComingSoon(context, 'Active Sessions'),
                          ),
                          const SizedBox(height: 20),
                          const _SecurityTipBanner(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityTopBar extends StatelessWidget {
  const _SecurityTopBar({
    required this.onBack,
    required this.onSearchTap,
    required this.onSparkleTap,
  });

  final VoidCallback onBack;
  final VoidCallback onSearchTap;
  final VoidCallback onSparkleTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _textDark,
              size: 20,
            ),
          ),
          const Expanded(
            child: Text(
              'SecuritySettings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: 0.2,
              ),
            ),
          ),
          IconButton(
            onPressed: onSearchTap,
            icon: const Icon(Icons.search_rounded, color: _textDark, size: 26),
          ),
          IconButton(
            onPressed: onSparkleTap,
            icon: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFE53935),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityHeader extends StatelessWidget {
  const _SecurityHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: const BoxDecoration(
        color: _headerTint,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF42A5F5),
                  _bluePrimary,
                  _blueDark,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _bluePrimary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Security & Privacy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Protect your account with advanced security settings and manage your privacy preferences.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: _textMid.withValues(alpha: 0.95),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityOptionCard extends StatelessWidget {
  const _SecurityOptionCard({
    required this.imageAsset,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final String imageAsset;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported_outlined,
                        color: _bluePrimary,
                        size: 24,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _bluePrimary.withValues(alpha: 0.55),
                          ),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: _bluePrimary,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textMid,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFC2C4CF),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityTipBanner extends StatelessWidget {
  const _SecurityTipBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _tipBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _bluePrimary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _bluePrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: _bluePrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Enable Two-Factor Authentication to significantly reduce the risk of unauthorized access to your account.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: _tipText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
