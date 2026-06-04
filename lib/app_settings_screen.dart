import 'package:flutter/material.dart';

import 'loginScreen.dart';
import 'profileedit_screen.dart';
import 'repo/auth_service.dart';
import 'security_settings_screen.dart';

const Color _bg = Color(0xFFF7F7FB);
const Color _surface = Colors.white;
const Color _textDark = Color(0xFF1D1A29);
const Color _textMid = Color(0xFF7A7690);
const Color _border = Color(0xFFEDEAF6);

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key, required this.username});

  final String username;

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _darkMode = false;

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
      const _SettingItem(
        icon: Icons.workspace_premium_outlined,
        title: 'Premium',
        subtitle:
            'Manage your BicharSetu Pro features including AI Narration, extended story editing, and premium badges.',
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
        subtitle: 'Currently using the parchment light theme.',
        trailing: Switch(
          value: _darkMode,
          onChanged: (value) => setState(() => _darkMode = value),
          activeThumbColor: const Color(0xFF6A3DE8),
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
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 12, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: _textDark,
                      size: 26,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 35 / 2,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      Text(
                        '@${widget.username}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: _textMid,
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
                      color: const Color(0xFFEFF1F5),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded, color: Color(0xFF8D90A0)),
                        SizedBox(width: 10),
                        Text(
                          'Search settings',
                          style: TextStyle(
                            color: Color(0xFF6C7080),
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
                      color: _surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
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
    final trailing = item.trailing ??
        const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFFC2C4CF),
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
            child: Icon(item.icon, size: 27, color: const Color(0xFF7E8292)),
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
                        style: const TextStyle(
                          fontSize: 35 / 2,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                    ),
                    trailing,
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 15 / 1.8,
                    color: _textMid,
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
