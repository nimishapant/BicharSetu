import 'package:flutter/material.dart';
import 'model/user_model.dart';
import 'repo/auth_service.dart';
import 'theme/bichar_theme_extension.dart';
import 'theme/privacy_controller.dart';

class PrivacySafetyScreen extends StatelessWidget {
  const PrivacySafetyScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PrivacySafetyScreen(),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
            'This action is permanent and cannot be undone. All your data, including posts and profile info, will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      _showComingSoon(context, 'Account deletion');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final privacy = PrivacyController.instance;

    return ListenableBuilder(
      listenable: privacy,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: bichar.drawerBackground,
          appBar: AppBar(
            backgroundColor: bichar.cardBackground,
            title: const Text('Privacy and safety'),
          ),
          body: StreamBuilder<UserModel?>(
            stream: AuthService().currentUserModelStream,
            builder: (context, snapshot) {
              final user = snapshot.data;
              final isPrivate = user?.isPrivate ?? false;

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _SectionHeader(title: 'Account Privacy'),
                  _SwitchTile(
                    title: 'Private Account',
                    subtitle:
                        'Only people you approve can see your posts and gallery.',
                    value: isPrivate,
                    onChanged: (val) =>
                        AuthService().setPrivateAccount(isPrivate: val),
                  ),
                  _SwitchTile(
                    title: 'Show Profile Information',
                    subtitle: 'Allow others to see your about me and location.',
                    value: privacy.showProfileInfo,
                    onChanged: privacy.setShowProfileInfo,
                  ),
                  _SwitchTile(
                    title: 'Show Online Status',
                    subtitle: 'Let others see when you are active.',
                    value: privacy.showOnlineStatus,
                    onChanged: privacy.setShowOnlineStatus,
                  ),
                  const Divider(height: 32),
                  _SectionHeader(title: 'Interaction Controls'),
                  _PermissionTile(
                    title: 'Who can comment on my posts?',
                    value: privacy.commentPermission,
                    onSelected: privacy.setCommentPermission,
                  ),
                  _PermissionTile(
                    title: 'Who can message me?',
                    value: privacy.messagePermission,
                    onSelected: privacy.setMessagePermission,
                  ),
                  _PermissionTile(
                    title: 'Who can mention/tag me?',
                    value: privacy.mentionPermission,
                    onSelected: privacy.setMentionPermission,
                  ),
                  const Divider(height: 32),
                  _SectionHeader(title: 'Safety'),
                  _ActionTile(
                    title: 'Blocked Users',
                    icon: Icons.block_flipped,
                    onTap: () => _showComingSoon(context, 'Blocked users list'),
                  ),
                  _ActionTile(
                    title: 'Muted Users',
                    icon: Icons.volume_off_outlined,
                    onTap: () => _showComingSoon(context, 'Muted users list'),
                  ),
                  _ActionTile(
                    title: 'Restricted Users',
                    icon: Icons.remove_circle_outline,
                    onTap: () => _showComingSoon(context, 'Restricted users list'),
                  ),
                  _SwitchTile(
                    title: 'Sensitive Content Filter',
                    subtitle: 'Limit exposure to potentially sensitive content.',
                    value: privacy.sensitiveContentFilter,
                    onChanged: privacy.setSensitiveContentFilter,
                  ),
                  const Divider(height: 32),
                  _SectionHeader(title: 'Data & Security'),
                  _ActionTile(
                    title: 'Manage App Permissions',
                    icon: Icons.settings_applications_outlined,
                    onTap: () => _showComingSoon(context, 'App permissions'),
                  ),
                  _ActionTile(
                    title: 'Clear Search History',
                    icon: Icons.history_rounded,
                    onTap: () => _showComingSoon(context, 'Clear history'),
                  ),
                  _ActionTile(
                    title: 'Download My Data',
                    icon: Icons.download_for_offline_outlined,
                    onTap: () => _showComingSoon(context, 'Data download'),
                  ),
                  _ActionTile(
                    title: 'Deactivate Account',
                    icon: Icons.no_accounts_outlined,
                    onTap: () => _showComingSoon(context, 'Account deactivation'),
                  ),
                  _ActionTile(
                    title: 'Delete Account',
                    icon: Icons.delete_forever_outlined,
                    color: Colors.red,
                    onTap: () => _handleDeleteAccount(context),
                  ),
                ],
              );
            },
          ),
        );
      },
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

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: bichar.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: bichar.textSecondary),
      ),
      activeColor: bichar.accent,
      value: value,
      onChanged: onChanged,
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.title,
    required this.value,
    required this.onSelected,
  });

  final String title;
  final InteractionPermission value;
  final ValueChanged<InteractionPermission> onSelected;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: bichar.textPrimary),
      ),
      subtitle: Text(
        value.label,
        style: TextStyle(fontSize: 13, color: bichar.accent, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showPermissionPicker(context, title, value, onSelected),
    );
  }

  void _showPermissionPicker(BuildContext context, String title,
      InteractionPermission current, ValueChanged<InteractionPermission> onSelected) {
    final bichar = context.bichar;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: bichar.textPrimary),
              ),
              const SizedBox(height: 16),
              ...InteractionPermission.values.map((opt) {
                final isSelected = opt == current;
                return ListTile(
                  title: Text(
                    opt.label,
                    style: TextStyle(
                        color: isSelected ? bichar.accent : bichar.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: bichar.accent)
                      : null,
                  onTap: () {
                    onSelected(opt);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final iconColor = color ?? bichar.accent;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: color ?? bichar.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
