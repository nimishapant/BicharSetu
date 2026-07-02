import 'package:flutter/material.dart';

import 'account_status_screen.dart';
import 'experience_languages_screen.dart';
import 'loginScreen.dart';
import 'privacy_safety_screen.dart';
import 'resources_legal_screen.dart';
import 'theme/app_localizations.dart';
import 'notification_screen.dart';
import 'premium_settings_screen.dart';
import 'profileedit_screen.dart';
import 'repo/auth_service.dart';
import 'security_settings_screen.dart';
import 'theme/bichar_theme_extension.dart';
import 'theme/theme_controller.dart';
import 'widgets/settings/dark_mode_card.dart';
import 'widgets/settings/setting_tile.dart';
import 'widgets/settings/settings_header.dart';
import 'widgets/settings/settings_logout_section.dart';
import 'widgets/settings/settings_search_field.dart';
import 'widgets/settings/settings_section.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key, required this.username});

  final String username;

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final ThemeController _themeController = ThemeController();
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();

  String _searchQuery = '';
  String _profilePhotoUrl = '';
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    final user = await _authService.getCurrentUserModel();
    if (!mounted) return;
    setState(() {
      _profilePhotoUrl = user?.profilePhoto ?? '';
      _loadingProfile = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(String title, String subtitle) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery;
    return title.toLowerCase().contains(q) ||
        subtitle.toLowerCase().contains(q);
  }

  Future<void> _onLogout() async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(Icons.logout_rounded, color: colorScheme.error, size: 28),
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out of BicharSetu?'),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
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

  List<_SettingItem> _accountItems(BuildContext context) => [
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
        _SettingItem(
          icon: Icons.verified_user_outlined,
          title: 'Account Status',
          subtitle:
              'Check your current account standing and review any potential violations or restrictions.',
          onTap: () => AccountStatusScreen.open(context),
        ),
        _SettingItem(
          icon: Icons.lock_outline_rounded,
          title: 'Security and account access',
          subtitle:
              'Manage your account security, monitor active sessions, and control which apps have access to your profile.',
          onTap: () => SecuritySettingsScreen.open(context),
        ),
      ];

  List<_SettingItem> _premiumItems(BuildContext context) => [
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
      ];

  List<_SettingItem> _privacyItems(BuildContext context) => [
        _SettingItem(
          icon: Icons.shield_outlined,
          title: 'Privacy and safety',
          subtitle:
              'Manage the content you see and share, including blocked accounts, muted writers, and story visibility.',
          onTap: () => PrivacySafetyScreen.open(context),
        ),
      ];

  List<_SettingItem> _communicationItems(BuildContext context) => [
        _SettingItem(
          icon: Icons.notifications_none_rounded,
          title: context.l10n.notifications,
          subtitle:
              'Control alerts for appreciation, relekhans, comments, and important platform updates.',
          onTap: () => NotificationScreen.open(context),
        ),
      ];

  List<_SettingItem> _localizationItems(BuildContext context) => [
        _SettingItem(
          icon: Icons.accessibility_new_rounded,
          title: context.l10n.experienceLanguages,
          subtitle:
              'Standardize your reading experience with theme preferences and interface language settings.',
          onTap: () => ExperienceLanguagesScreen.open(context),
        ),
      ];

  List<_SettingItem> _supportItems(BuildContext context) => [
        _SettingItem(
          icon: Icons.more_horiz_rounded,
          title: 'Resources & Legal',
          subtitle:
              'Explore the BicharSetu help center, community guidelines, and professional support.',
          onTap: () => ResourcesLegalScreen.open(context),
        ),
      ];

  List<_SettingItem> _filterItems(List<_SettingItem> items) {
    return items
        .where((item) => _matchesSearch(item.title, item.subtitle))
        .toList();
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<_SettingItem> items,
  }) {
    final filtered = _filterItems(items);
    if (filtered.isEmpty) return const SizedBox.shrink();

    return SettingsSection(
      title: title,
      icon: icon,
      children: filtered
          .map(
            (item) => SettingTile(
              icon: item.icon,
              title: item.title,
              subtitle: item.subtitle,
              onTap: item.onTap,
            ),
          )
          .toList(),
    );
  }

  bool get _showDarkModeCard {
    if (_searchQuery.isEmpty) return true;
    const title = 'Night and Dark mode';
    final subtitle = _themeController.currentThemeLabel;
    return _matchesSearch(title, subtitle) ||
        _searchQuery.contains('appearance') ||
        _searchQuery.contains('dark') ||
        _searchQuery.contains('night') ||
        _searchQuery.contains('theme');
  }

  bool get _showLogout {
    if (_searchQuery.isEmpty) return true;
    return _matchesSearch('Log out of account', 'Sign out from BicharSetu');
  }

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 48;
    if (width >= 800) return 32;
    return 18;
  }

  double _maxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 720;
    if (width >= 800) return 640;
    return width;
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: bichar.drawerBackground,
          body: SafeArea(
            child: _loadingProfile
                ? Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: bichar.accent,
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: _maxContentWidth(context),
                      ),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          _horizontalPadding(context),
                          8,
                          _horizontalPadding(context),
                          28,
                        ),
                        children: [
                          SettingsHeader(
                            username: widget.username,
                            profilePhotoUrl: _profilePhotoUrl,
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          SettingsSearchField(
                            controller: _searchController,
                            onChanged: (value) => setState(
                              () => _searchQuery = value.trim().toLowerCase(),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _buildSection(
                            title: context.l10n.account,
                            icon: Icons.person_outline_rounded,
                            items: _accountItems(context),
                          ),
                          _buildSection(
                            title: context.l10n.premium,
                            icon: Icons.workspace_premium_outlined,
                            items: _premiumItems(context),
                          ),
                          if (_showDarkModeCard)
                            DarkModeCard(
                              isDarkModeEnabled:
                                  _themeController.isDarkModeEnabled,
                              subtitle: _themeController.currentThemeLabel,
                              onChanged: _themeController.setDarkModeEnabled,
                            ),
                          _buildSection(
                            title: context.l10n.privacy,
                            icon: Icons.shield_outlined,
                            items: _privacyItems(context),
                          ),
                          _buildSection(
                            title: context.l10n.communication,
                            icon: Icons.notifications_none_rounded,
                            items: _communicationItems(context),
                          ),
                          _buildSection(
                            title: context.l10n.localization,
                            icon: Icons.language_rounded,
                            items: _localizationItems(context),
                          ),
                          _buildSection(
                            title: context.l10n.support,
                            icon: Icons.support_agent_rounded,
                            items: _supportItems(context),
                          ),
                          if (_showLogout)
                            SettingsLogoutSection(onLogout: _onLogout),
                        ],
                      ),
                    ),
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
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
}
