import 'package:flutter/material.dart';

import 'loginScreen.dart';
import 'premium_settings_screen.dart';
import 'profileedit_screen.dart';
import 'repo/auth_service.dart';
import 'security_settings_screen.dart';
import 'theme/bichar_theme_extension.dart';
import 'theme/theme_controller.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key, required this.username});

  final String username;

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final ThemeController _themeController = ThemeController();

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out of BicharSetu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Log out',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await AuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, _) {
        final items = <_SettingItem>[
          _SettingItem(
            icon: Icons.person_outline_rounded,
            title: 'Your account',
            subtitle:
                'View and manage your account details, download a BicharSetu data archive, or manage account deactivation.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProfileEditScreen(),
                ),
              );
            },
          ),
          const _SettingItem(
            icon: Icons.verified_user_outlined,
            title: 'Account Status',
            subtitle:
                'Check your current account standing and review any potential violations or restrictions.',
          ),
          _SettingItem(
            icon: Icons.lock_outline_rounded,
            title: 'Security and account access',
            subtitle:
                'Manage your account security, monitor active sessions, and control which apps have access to your profile.',
            onTap: () => SecuritySettingsScreen.open(context),
          ),
          _SettingItem(
            icon: Icons.workspace_premium_outlined,
            title: 'Premium',
            subtitle:
                'Manage your BicharSetu Pro features including AI Narration, extended story editing, and premium badges.',
            onTap: () => PremiumSettingsScreen.open(context),
          ),
          const _SettingItem(
            icon: Icons.auto_awesome_outlined,
            title: 'BicharSetu Studio',
            subtitle:
                'Access your creator dashboard, track story analytics, and manage your wallet and earnings.',
          ),
          _SettingItem(
            icon: Icons.dark_mode_outlined,
            title: 'Night and Dark mode',
            subtitle: _themeController.currentThemeLabel,
            trailing: Switch(
              value: _themeController.isDarkModeEnabled,
              onChanged: _themeController.setDarkModeEnabled,
            ),
          ),
          const _SettingItem(
            icon: Icons.shield_outlined,
            title: 'Privacy and safety',
            subtitle:
                'Manage the content you see and share, including blocked accounts, muted writers, and story visibility.',
          ),
          const _SettingItem(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle:
                'Control alerts for appreciation, relekhans, comments, and important platform updates.',
          ),
          const _SettingItem(
            icon: Icons.accessibility_new_rounded,
            title: 'Experience & Languages',
            subtitle:
                'Standardize your reading experience with theme preferences and interface language settings.',
          ),
          const _SettingItem(
            icon: Icons.more_horiz_rounded,
            title: 'Resources & Legal',
            subtitle:
                'Explore the BicharSetu help center, community guidelines, and professional support.',
          ),
        ];

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 12, 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: bichar.textPrimary,
                          size: 26,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 35 / 2,
                              fontWeight: FontWeight.w700,
                              color: bichar.textPrimary,
                            ),
                          ),
                          Text(
                            '@${widget.username}',
                            style: TextStyle(
                              fontSize: 14,
                              color: bichar.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    children: [
                      Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: bichar.searchFieldBackground,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: bichar.mutedIcon),
                            const SizedBox(width: 10),
                            Text(
                              'Search settings',
                              style: TextStyle(
                                color: bichar.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final item in items) _SettingsTile(item: item),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          color: bichar.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: bichar.border),
                        ),
                        child: TextButton(
                          onPressed: _onLogout,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Log out of account',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingItem {
  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.item});

  final _SettingItem item;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final trailing = item.trailing ??
        Icon(
          Icons.chevron_right_rounded,
          color: bichar.textSecondary.withValues(alpha: 0.6),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(item.icon, size: 27, color: bichar.mutedIcon),
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
                          item.title,
                          style: TextStyle(
                            fontSize: 35 / 2,
                            fontWeight: FontWeight.w600,
                            color: bichar.textPrimary,
                          ),
                        ),
                      ),
                      trailing,
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 15 / 1.8,
                      color: bichar.textSecondary,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
