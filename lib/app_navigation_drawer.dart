import 'package:flutter/material.dart';
import 'app_settings_screen.dart';
import 'diary_screen.dart';
import 'loginScreen.dart';
import 'model/user_model.dart';
import 'profile_screen.dart';
import 'repo/auth_service.dart';

const Color _drawerBg = Color(0xFFF3F3F5);
const Color _textDark = Color(0xFF1D1A29);
const Color _textMid = Color(0xFF7A7690);
const Color _divider = Color(0xFFE4E4E8);

class AppNavigationDrawer extends StatefulWidget {
  const AppNavigationDrawer({super.key});

  @override
  State<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getCurrentUserModel();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  String get _displayName {
    final name = _user?.username ?? 'User';
    if (name.isEmpty) return 'User';
    return name[0].toUpperCase() + name.substring(1);
  }

  String get _handle => '@${_user?.username ?? 'user'}';

  void _closeAndThen(VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  void _showComingSoon(String label) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('$label — coming soon'),
      ),
    );
  }

  void _onExploreItemTap(_DrawerItem item) {
    if (item.label == 'Diary') {
      _closeAndThen(() {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const DiaryScreen()),
        );
      });
      return;
    }
    _showComingSoon(item.label);
  }

  Future<void> _onSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Sign out',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    Navigator.of(context).pop();
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.82,
      backgroundColor: _drawerBg,
      elevation: 8,
      shadowColor: Colors.black26,
      child: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _DrawerProfileHeader(
                    displayName: _displayName,
                    handle: _handle,
                    profilePhotoUrl: _user?.profilePhoto ?? '',
                    onProfileTap: () => _closeAndThen(() {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    }),
                    onAddAccount: () => _showComingSoon('Add account'),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, thickness: 1, color: _divider),
                  const SizedBox(height: 12),
                  const _SectionLabel('EXPLORE'),
                  const SizedBox(height: 4),
                  ..._exploreItems.map(
                    (item) => _DrawerTile(
                      icon: item.icon,
                      label: item.label,
                      onTap: () => _onExploreItemTap(item),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 1, color: _divider),
                  const SizedBox(height: 8),
                  _DrawerTile(
                    icon: Icons.settings_outlined,
                    label: 'Settings and privacy',
                    onTap: () => _closeAndThen(() {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AppSettingsScreen(
                            username: _user?.username ?? 'aditya',
                          ),
                        ),
                      );
                    }),
                  ),
                  _DrawerTile(
                    icon: Icons.help_outline_rounded,
                    label: 'Help Center',
                    onTap: () => _showComingSoon('Help Center'),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, thickness: 1, color: _divider),
                  const SizedBox(height: 8),
                  _DrawerTile(
                    icon: Icons.logout_rounded,
                    label: 'Sign out',
                    iconColor: Colors.redAccent,
                    labelColor: Colors.redAccent,
                    onTap: _onSignOut,
                  ),
                ],
              ),
      ),
    );
  }
}

class _DrawerItem {
  const _DrawerItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

const List<_DrawerItem> _exploreItems = [
  _DrawerItem(icon: Icons.bookmark_border_rounded, label: 'Saved Posts'),
  _DrawerItem(icon: Icons.article_outlined, label: 'Articles'),
  _DrawerItem(icon: Icons.menu_book_outlined, label: 'Books'),
  _DrawerItem(icon: Icons.auto_stories_outlined, label: 'Diary'),
  _DrawerItem(icon: Icons.visibility_off_outlined, label: 'Manage Confessions'),
  _DrawerItem(icon: Icons.map_outlined, label: 'Story Map'),
  _DrawerItem(icon: Icons.local_fire_department_outlined, label: 'Trending'),
];

class _DrawerProfileHeader extends StatelessWidget {
  const _DrawerProfileHeader({
    required this.displayName,
    required this.handle,
    required this.profilePhotoUrl,
    required this.onProfileTap,
    required this.onAddAccount,
  });

  final String displayName;
  final String handle;
  final String profilePhotoUrl;
  final VoidCallback onProfileTap;
  final VoidCallback onAddAccount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onProfileTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8E8EC),
                border: Border.all(color: const Color(0xFFD0D0D6), width: 1.5),
              ),
              child: profilePhotoUrl.isEmpty
                  ? const Icon(
                      Icons.person_rounded,
                      size: 34,
                      color: Color(0xFFB8B4C0),
                    )
                  : ClipOval(
                      child: Image.network(
                        profilePhotoUrl,
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person_rounded,
                            size: 34,
                            color: Color(0xFFB8B4C0),
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              handle,
                              style: const TextStyle(
                                fontSize: 14,
                                color: _textMid,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onAddAccount,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.person_add_alt_1_outlined,
                              size: 22,
                              color: _textDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      _StatChip(label: '0 Following'),
                      SizedBox(width: 16),
                      _StatChip(label: '0 Followers'),
                    ],
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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        color: _textMid,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: _textMid,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = _textDark,
    this.labelColor = _textDark,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
          child: Row(
            children: [
              Icon(icon, size: 24, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
