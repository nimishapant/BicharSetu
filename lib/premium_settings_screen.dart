import 'package:flutter/material.dart';

const Color _bg = Color(0xFFF7F7FB);
const Color _surface = Colors.white;
const Color _headerTint = Color(0xFFFFF8E8);
const Color _textDark = Color(0xFF1D1A29);
const Color _textMid = Color(0xFF7A7690);
const Color _goldPrimary = Color(0xFFD4A017);
const Color _goldDark = Color(0xFFB8860B);
const Color _goldLight = Color(0xFFFFF3CD);
const Color _accent = Color(0xFF6A3DE8);
const Color _cardBorder = Color(0xFFE0E4EC);
const Color _cardBg = Color(0xFFF8FAFD);

class PremiumSettingsScreen extends StatefulWidget {
  const PremiumSettingsScreen({super.key, this.isPro = false});

  /// Whether the current user has an active BicharSetu Pro subscription.
  final bool isPro;

  static Future<void> open(BuildContext context, {bool isPro = false}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PremiumSettingsScreen(isPro: isPro),
      ),
    );
  }

  @override
  State<PremiumSettingsScreen> createState() => _PremiumSettingsScreenState();
}

class _PremiumSettingsScreenState extends State<PremiumSettingsScreen> {
  late bool _aiNarrationEnabled;
  late bool _extendedEditingEnabled;
  late bool _premiumBadgeVisible;

  @override
  void initState() {
    super.initState();
    _aiNarrationEnabled = widget.isPro;
    _extendedEditingEnabled = widget.isPro;
    _premiumBadgeVisible = widget.isPro;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  void _onProFeatureChanged(bool value, void Function(bool) setter, String label) {
    if (!widget.isPro) {
      _showSnack('Upgrade to BicharSetu Pro to use $label');
      return;
    }
    setState(() => setter(value));
    _showSnack('$label ${value ? 'enabled' : 'disabled'}');
  }

  void _onUpgradeTap() {
    _showSnack('BicharSetu Pro upgrade — coming soon');
  }

  void _onManageSubscription() {
    _showSnack('Manage subscription — coming soon');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PremiumTopBar(
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PremiumHeader(isPro: widget.isPro),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Column(
                        children: [
                          _ProStatusCard(
                            isPro: widget.isPro,
                            onUpgrade: _onUpgradeTap,
                            onManage: _onManageSubscription,
                          ),
                          const SizedBox(height: 20),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Pro features',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _textMid,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _PremiumFeatureCard(
                            icon: Icons.record_voice_over_rounded,
                            iconBg: _goldLight,
                            iconColor: _goldDark,
                            title: 'AI Narration',
                            subtitle:
                                'Listen to stories with natural AI-powered voice narration in multiple languages.',
                            value: _aiNarrationEnabled,
                            enabled: widget.isPro,
                            onChanged: (v) => _onProFeatureChanged(
                              v,
                              (val) => _aiNarrationEnabled = val,
                              'AI Narration',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _PremiumFeatureCard(
                            icon: Icons.edit_note_rounded,
                            iconBg: const Color(0xFFEDE7FF),
                            iconColor: _accent,
                            title: 'Extended Story Editing',
                            subtitle:
                                'Edit published stories for up to 7 days instead of the standard 24-hour window.',
                            value: _extendedEditingEnabled,
                            enabled: widget.isPro,
                            onChanged: (v) => _onProFeatureChanged(
                              v,
                              (val) => _extendedEditingEnabled = val,
                              'Extended Story Editing',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _PremiumFeatureCard(
                            icon: Icons.workspace_premium_rounded,
                            iconBg: _goldLight,
                            iconColor: _goldDark,
                            title: 'Premium Badge',
                            subtitle:
                                'Display the exclusive BicharSetu Pro badge on your profile and posts.',
                            value: _premiumBadgeVisible,
                            enabled: widget.isPro,
                            onChanged: (v) => _onProFeatureChanged(
                              v,
                              (val) => _premiumBadgeVisible = val,
                              'Premium Badge',
                            ),
                          ),
                          const SizedBox(height: 20),
                          const _PremiumTipBanner(),
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

class _PremiumTopBar extends StatelessWidget {
  const _PremiumTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(4, 6, 12, 4),
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
              'Premium',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_goldPrimary, _goldDark],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader({required this.isPro});

  final bool isPro;

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
                  Color(0xFFFFD54F),
                  _goldPrimary,
                  _goldDark,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _goldPrimary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'BicharSetu Pro',
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
            isPro
                ? 'Manage your Pro features including AI Narration, extended story editing, and your premium badge.'
                : 'Unlock AI Narration, extended story editing, and an exclusive premium badge with BicharSetu Pro.',
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

class _ProStatusCard extends StatelessWidget {
  const _ProStatusCard({
    required this.isPro,
    required this.onUpgrade,
    required this.onManage,
  });

  final bool isPro;
  final VoidCallback onUpgrade;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    if (isPro) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5B35D5),
              Color(0xFF6A3DE8),
              Color(0xFF8B6EFF),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Pro member',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'All Pro features are available on your account.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onManage,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Manage',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: _textMid, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You are on the free plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Upgrade to unlock AI Narration, extended story editing, and your premium profile badge.',
            style: TextStyle(
              fontSize: 13,
              color: _textMid,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onUpgrade,
            style: FilledButton.styleFrom(
              backgroundColor: _goldPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.workspace_premium_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Upgrade to BicharSetu Pro',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeatureCard extends StatelessWidget {
  const _PremiumFeatureCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? () => onChanged(!value) : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: enabled ? _textDark : _textMid,
                            ),
                          ),
                        ),
                        if (!enabled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _goldLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: _goldDark,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textMid,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: _accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumTipBanner extends StatelessWidget {
  const _PremiumTipBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _goldLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _goldPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _goldPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tips_and_updates_outlined,
              color: _goldDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Turn on AI Narration to enjoy hands-free reading. Extended editing lets you refine stories after publishing, and the premium badge helps readers recognize Pro creators.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: _goldDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
