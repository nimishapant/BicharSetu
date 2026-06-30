import 'package:flutter/material.dart';
import 'app_settings_screen.dart';
import 'article_screen.dart';
import 'saved_posts_screen.dart';
import 'trending_screen.dart';
import 'theme/bichar_theme_extension.dart';
import 'books.dart';
import 'diary_screen.dart';
import 'loginScreen.dart';
import 'model/user_model.dart';
import 'profile_screen.dart';
import 'repo/auth_service.dart';
import 'widgets/drawer/drawer_menu_item.dart';
import 'widgets/drawer/drawer_profile_header.dart';
import 'widgets/drawer/drawer_sign_out_button.dart';

const Color _textDark = Color(0xFF1D1A29);
const Color _textMid = Color(0xFF7A7690);

// Help Center palette (aligned with app settings / Material 3 surfaces)
const Color _helpBg = Color(0xFFF7F7FB);
const Color _helpSurface = Colors.white;
const Color _helpBorder = Color(0xFFEDEAF6);
const Color _helpAccent = Color(0xFF6A3DE8);

class AppNavigationDrawer extends StatefulWidget {
  const AppNavigationDrawer({super.key});

  @override
  State<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {

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
    if (item.label == 'Trending') {
      _closeAndThen(() {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const TrendingScreen()),
        );
      });
      return;
    }
    if (item.label == 'Saved Posts') {
      _closeAndThen(() {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SavedPostsScreen()),
        );
      });
      return;
    }
    if (item.label == 'Articles') {
      _closeAndThen(() {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ArticleScreen()),
        );
      });
      return;
    }
    if (item.label == 'Diary') {
      _closeAndThen(() {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const DiaryScreen()),
        );
      });
      return;
    }
    if (item.label == 'Books') {
      _closeAndThen(() {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const BooksScreen()),
        );
      });
      return;
    }
    _showComingSoon(item.label);
  }

  Future<void> _onSignOut() async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(Icons.logout_rounded, color: colorScheme.error, size: 28),
        title: const Text('Sign out'),
        content: const Text(
          'Are you sure you want to sign out of your account?',
        ),
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
            child: const Text('Sign out'),
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

  double _drawerWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 360;
    if (width >= 800) return 340;
    return width * 0.86;
  }

  void _openProfile() => _closeAndThen(() {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
        );
      });

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 800 ? 20.0 : 16.0;

    return Drawer(
      width: _drawerWidth(context),
      backgroundColor: bichar.drawerBackground,
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: StreamBuilder<UserModel?>(
          stream: AuthService().currentUserModelStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: bichar.accent,
                ),
              );
            }

            final user = snapshot.data;
            final rawName = user?.username ?? 'User';
            final displayName = rawName.isNotEmpty
                ? rawName[0].toUpperCase() + rawName.substring(1)
                : 'User';
            final handle = '@${user?.username ?? 'user'}';
            final profilePhotoUrl = user?.profilePhoto ?? '';
            final followersCount = user?.followers.length ?? 0;
            final followingCount = user?.following.length ?? 0;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      8,
                    ),
                    children: [
                      DrawerProfileHeader(
                        displayName: displayName,
                        handle: handle,
                        profilePhotoUrl: profilePhotoUrl,
                        onProfileTap: _openProfile,
                        onEditProfile: _openProfile,
                        onAddAccount: () => _showComingSoon('Add account'),
                        followersCount: followersCount,
                        followingCount: followingCount,
                      ),
                      const SizedBox(height: 20),
                      const DrawerSectionHeader(
                        title: 'Explore',
                        icon: Icons.explore_outlined,
                      ),
                      ..._exploreItems.map(
                        (item) => DrawerMenuItem(
                          icon: item.icon,
                          label: item.label,
                          onTap: () => _onExploreItemTap(item),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const DrawerSectionHeader(
                        title: 'Community',
                        icon: Icons.groups_outlined,
                      ),
                      ..._communityItems.map(
                        (item) => DrawerMenuItem(
                          icon: item.icon,
                          label: item.label,
                          onTap: () => _onCommunityItemTap(item),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const DrawerSectionHeader(
                        title: 'Settings',
                        icon: Icons.tune_rounded,
                      ),
                      DrawerMenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings and privacy',
                        onTap: () => _closeAndThen(() {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => AppSettingsScreen(
                                username: user?.username ?? 'aditya',
                              ),
                            ),
                          );
                        }),
                      ),
                      DrawerMenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help Center',
                        onTap: () => _closeAndThen(() {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const HelpCenterScreen(),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    8,
                    horizontalPadding,
                    16,
                  ),
                  child: DrawerSignOutButton(onPressed: _onSignOut),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onCommunityItemTap(_DrawerItem item) {
    _showComingSoon(item.label);
  }
}

// ---------------------------------------------------------------------------
// Help Center
// ---------------------------------------------------------------------------

/// Full-screen Help Center with searchable FAQs, quick actions, and contact.
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _contactSectionKey = GlobalKey();

  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() => _query = _searchController.text.trim().toLowerCase());
  }

  List<_FaqItem> get _filteredFaqs {
    if (_query.isEmpty) return _helpFaqItems;
    return _helpFaqItems
        .where(
          (item) =>
              item.question.toLowerCase().contains(_query) ||
              item.answer.toLowerCase().contains(_query),
        )
        .toList();
  }

  void _focusSearch() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    _searchFocusNode.requestFocus();
  }

  void _scrollToContact() {
    final context = _contactSectionKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      alignment: 0.1,
    );
  }

  void _showInfoSheet({
    required String title,
    required String body,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final bottom = MediaQuery.paddingOf(context).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: _textMid,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filtered = _filteredFaqs;
    final horizontalPadding = _helpHorizontalPadding(context);
    final contentMaxWidth = _helpMaxContentWidth(context);

    return Theme(
      data: theme.copyWith(
        dividerColor: _helpBorder,
        expansionTileTheme: ExpansionTileThemeData(
          backgroundColor: _helpSurface,
          collapsedBackgroundColor: _helpSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          iconColor: _textMid,
          collapsedIconColor: _textMid,
          textColor: _textDark,
          collapsedTextColor: _textDark,
        ),
      ),
      child: Scaffold(
        backgroundColor: _helpBg,
        appBar: AppBar(
          backgroundColor: _helpSurface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Help Center',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: _textDark,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search',
              onPressed: _focusSearch,
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  32,
                ),
                children: [
                  const _HelpWelcomeSection(),
                  const SizedBox(height: 20),
                  _HelpSearchField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onClear: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                    },
                  ),
                  const SizedBox(height: 28),
                  _HelpSectionHeader(
                    title: 'Frequently Asked Questions',
                    trailing: filtered.length != _helpFaqItems.length
                        ? '${filtered.length} result${filtered.length == 1 ? '' : 's'}'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    _HelpEmptySearchState(query: _searchController.text)
                  else
                    ...filtered.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _HelpFaqTile(item: item),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const _HelpSectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 12),
                  _HelpQuickActionsGrid(
                    onContactSupport: _scrollToContact,
                    onReportProblem: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            'Thanks for reporting. Our team will review your issue.',
                          ),
                        ),
                      );
                    },
                    onPrivacyPolicy: () => _showInfoSheet(
                      title: 'Privacy Policy',
                      body:
                          'Bichar Setu respects your privacy. We collect only the data needed to run the platform, never sell personal information, and let you export or delete your data from Settings. The full policy will be published on our website soon.',
                    ),
                    onTermsOfService: () => _showInfoSheet(
                      title: 'Terms of Service',
                      body:
                          'By using Bichar Setu you agree to post respectfully, follow community guidelines, and not misuse confession or story features. Full terms will be available on our website soon.',
                    ),
                  ),
                  const SizedBox(height: 28),
                  _HelpContactCard(key: _contactSectionKey),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _helpAccent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      "Can't find what you're looking for? Contact our support team.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double _helpHorizontalPadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= 1200) return 48;
  if (width >= 800) return 32;
  return 20;
}

double _helpMaxContentWidth(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= 1200) return 880;
  if (width >= 800) return 720;
  return width;
}

class _HelpWelcomeSection extends StatelessWidget {
  const _HelpWelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How can we help you?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: _textDark,
                height: 1.15,
              ) ??
              const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _textDark,
                height: 1.15,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Find answers to common questions and get support.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _textMid,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ) ??
              const TextStyle(
                fontSize: 16,
                color: _textMid,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
        ),
      ],
    );
  }
}

class _HelpSearchField extends StatelessWidget {
  const _HelpSearchField({
    required this.controller,
    required this.focusNode,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: _helpSurface,
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search help articles...',
          hintStyle: const TextStyle(
            color: Color(0xFF8D90A0),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF8D90A0),
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                tooltip: 'Clear search',
                onPressed: onClear,
              );
            },
          ),
          filled: true,
          fillColor: _helpSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _helpBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _helpBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _helpAccent, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _HelpSectionHeader extends StatelessWidget {
  const _HelpSectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textMid,
            ),
          ),
      ],
    );
  }
}

class _HelpEmptySearchState extends StatelessWidget {
  const _HelpEmptySearchState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: _helpSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _helpBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: _textMid.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'No articles match "$query"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try different keywords or browse all FAQs below.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _textMid,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single FAQ entry with expandable answer.
class _HelpFaqTile extends StatelessWidget {
  const _HelpFaqTile({required this.item});

  final _FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _helpSurface,
      elevation: 0,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _helpBorder),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: _helpAccent.withValues(alpha: 0.08),
            highlightColor: _helpAccent.withValues(alpha: 0.05),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(
              item.question,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _textDark,
                height: 1.3,
              ),
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.answer,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: _textMid,
                    fontWeight: FontWeight.w500,
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

class _HelpQuickActionsGrid extends StatelessWidget {
  const _HelpQuickActionsGrid({
    required this.onContactSupport,
    required this.onReportProblem,
    required this.onPrivacyPolicy,
    required this.onTermsOfService,
  });

  final VoidCallback onContactSupport;
  final VoidCallback onReportProblem;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onTermsOfService;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 600 ? 2 : 1;
    final childAspectRatio = width >= 600 ? 2.4 : 2.8;

    final actions = [
      _QuickActionData(
        icon: Icons.support_agent_rounded,
        title: 'Contact Support',
        subtitle: 'Get help from our team',
        onTap: onContactSupport,
      ),
      _QuickActionData(
        icon: Icons.bug_report_outlined,
        title: 'Report a Problem',
        subtitle: 'Report bugs or issues',
        onTap: onReportProblem,
      ),
      _QuickActionData(
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy Policy',
        subtitle: 'Read our privacy policy',
        onTap: onPrivacyPolicy,
      ),
      _QuickActionData(
        icon: Icons.description_outlined,
        title: 'Terms of Service',
        subtitle: 'View terms and conditions',
        onTap: onTermsOfService,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _HelpQuickActionCard(
          icon: action.icon,
          title: action.title,
          subtitle: action.subtitle,
          onTap: action.onTap,
        );
      },
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _HelpQuickActionCard extends StatelessWidget {
  const _HelpQuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _helpSurface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _helpBorder),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _helpAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _helpAccent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textMid,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFC2C4CF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpContactCard extends StatelessWidget {
  const _HelpContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _helpSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _helpBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 16),
          const _HelpContactRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: 'support@bicharsetu.com',
          ),
          const SizedBox(height: 14),
          const _HelpContactRow(
            icon: Icons.schedule_rounded,
            label: 'Response Time',
            value: 'Within 24 hours',
          ),
        ],
      ),
    );
  }
}

class _HelpContactRow extends StatelessWidget {
  const _HelpContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: _helpAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textMid,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

const List<_FaqItem> _helpFaqItems = [
  _FaqItem(
    question: 'How do I create a post?',
    answer:
        'Tap the compose (+) button on your home feed or profile. Choose a post type (story, article, or confession), add a title and body, attach an optional cover image, then tap Publish. Drafts are saved automatically if you leave before publishing.',
  ),
  _FaqItem(
    question: 'How do I edit my profile?',
    answer:
        'Open the navigation menu, tap your profile name, then select Edit Profile. You can update your display name, bio, profile photo, and links. Tap Save when you are done—changes appear on your public profile immediately.',
  ),
  _FaqItem(
    question: 'How do I save articles?',
    answer:
        'On any article or story, tap the bookmark icon. Saved items appear under Saved Posts in the navigation drawer. You can remove a save by tapping the bookmark again.',
  ),
  _FaqItem(
    question: 'How do I report inappropriate content?',
    answer:
        'Open the post menu (three dots) and choose Report. Select a reason (spam, harassment, etc.) and optionally add details. Our moderation team reviews reports, usually within 24 hours.',
  ),
  _FaqItem(
    question: 'How do I reset my password?',
    answer:
        'On the sign-in screen, tap Forgot password and enter your registered email. You will receive a reset link—check spam if it does not arrive. For signed-in users, go to Settings → Security and account access → Change password.',
  ),
  _FaqItem(
    question: 'How do I delete my account?',
    answer:
        'Go to Settings → Your account → Deactivate or delete account. Deactivation hides your profile temporarily; permanent deletion removes your posts and data after a confirmation period. This action cannot be undone.',
  ),
  _FaqItem(
    question: 'How do confessions work?',
    answer:
        'Confessions let you share thoughts anonymously. Create one from the compose menu and select Confession. Your identity is hidden from readers; moderators may still review content for safety. Confessions follow the same community guidelines as public posts.',
  ),
  _FaqItem(
    question: 'How do I contact support?',
    answer:
        'Email support@bicharsetu.com or use Contact Support in Quick Actions below. Include your username and a short description of the issue. We typically respond within 24 hours on business days.',
  ),
];

class _DrawerItem {
  const _DrawerItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

const List<_DrawerItem> _exploreItems = [
  _DrawerItem(icon: Icons.bookmark_border_rounded, label: 'Saved Posts'),
  _DrawerItem(icon: Icons.article_outlined, label: 'Articles'),
  _DrawerItem(icon: Icons.menu_book_rounded, label: 'Books'),
  _DrawerItem(icon: Icons.auto_stories_rounded, label: 'Diary'),
  _DrawerItem(icon: Icons.local_fire_department_rounded, label: 'Trending'),
];

const List<_DrawerItem> _communityItems = [
  _DrawerItem(
    icon: Icons.visibility_off_outlined,
    label: 'Manage Confessions',
  ),
];
