import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'about_screen.dart';
import 'community_guidelines_screen.dart';
import 'help_center_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'theme/bichar_theme_extension.dart';

class ResourcesLegalScreen extends StatelessWidget {
  const ResourcesLegalScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ResourcesLegalScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Scaffold(
      backgroundColor: bichar.drawerBackground,
      appBar: AppBar(
        backgroundColor: bichar.cardBackground,
        title: const Text('Resources & Legal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _SectionHeader(title: 'Help & Resources'),
          _SettingTile(
            title: 'Help Center',
            subtitle: 'Frequently asked questions and support.',
            icon: Icons.help_outline_rounded,
            onTap: () => HelpCenterScreen.open(context),
          ),
          _SettingTile(
            title: 'Contact Support',
            subtitle: 'Get in touch with our team.',
            icon: Icons.support_agent_rounded,
            onTap: () => HelpCenterScreen.open(context, initialTab: 1),
          ),
          _SettingTile(
            title: 'Report a Problem',
            subtitle: 'Let us know if something isn\'t working.',
            icon: Icons.bug_report_outlined,
            onTap: () => HelpCenterScreen.open(context, initialTab: 2),
          ),
          _SettingTile(
            title: 'Community Guidelines',
            subtitle: 'Rules and expected behavior.',
            icon: Icons.groups_outlined,
            onTap: () => CommunityGuidelinesScreen.open(context),
          ),
          _SettingTile(
            title: 'About BicharSetu',
            subtitle: 'Learn more about the platform.',
            icon: Icons.info_outline_rounded,
            onTap: () => AboutScreen.open(context),
          ),
          const Divider(height: 32),
          _SectionHeader(title: 'Legal'),
          _SettingTile(
            title: 'Privacy Policy',
            subtitle: 'How we handle your data.',
            icon: Icons.privacy_tip_outlined,
            onTap: () => PrivacyPolicyScreen.open(context),
          ),
          _SettingTile(
            title: 'Terms of Service',
            subtitle: 'Rules for using the application.',
            icon: Icons.description_outlined,
            onTap: () => TermsOfServiceScreen.open(context),
          ),
          _SettingTile(
            title: 'Open Source Licenses',
            subtitle: 'Credits for third-party software.',
            icon: Icons.code_rounded,
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'BicharSetu',
              applicationIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset('assets/images/logo.png', height: 60),
              ),
            ),
          ),
          _VersionTile(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: context.bichar.accent,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bichar.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: bichar.accent, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: bichar.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: bichar.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _VersionTile extends StatefulWidget {
  @override
  State<_VersionTile> createState() => _VersionTileState();
}

class _VersionTileState extends State<_VersionTile> {
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = '${info.version} (${info.buildNumber})';
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bichar.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.phonelink_setup_rounded, color: bichar.textSecondary, size: 20),
      ),
      title: Text(
        'App Version',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: bichar.textPrimary,
        ),
      ),
      subtitle: Text(
        _version,
        style: TextStyle(
          fontSize: 13,
          color: bichar.textSecondary,
        ),
      ),
    );
  }
}
