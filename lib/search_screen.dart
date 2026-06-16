import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'model/user_model.dart';
import 'repo/auth_service.dart';
import 'profile_screen.dart';

const Color _surface = Colors.white;
const Color _headerTint = Color(0xFFFFF0F0);
const Color _textDark = Color(0xFF1D1A29);
const Color _textMid = Color(0xFF7A7690);
const Color _accentRed = Color(0xFF8B1538);
const Color _searchIconRed = Color(0xFFB71C1C);
const Color _tabInactive = Color(0xFF9E9AA8);
const Color _borderLight = Color(0xFFF0E4E4);

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    this.showBackButton = true,
    this.initialTabIndex = 0,
  });

  final bool showBackButton;
  final int initialTabIndex;

  static Future<void> open(
    BuildContext context, {
    int initialTabIndex = 0,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchScreen(
          showBackButton: true,
          initialTabIndex: initialTabIndex,
        ),
      ),
    );
  }

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = ['Top', 'Latest', 'People', 'Media', 'Tags'];

  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<UserModel> _peopleResults = [];
  bool _peopleLoading = false;
  String? _peopleError;

  @override
  void initState() {
    super.initState();
    final tabIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: tabIndex,
    );
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _searchController.removeListener(_onSearchTextChanged);
    _tabController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 2) {
      _runPeopleSearch();
    }
    setState(() {});
  }

  void _onSearchTextChanged() {
    if (_tabController.index == 2) {
      _runPeopleSearch();
    }
  }

  Future<void> _runPeopleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _peopleResults = [];
        _peopleLoading = false;
        _peopleError = null;
      });
      return;
    }

    setState(() {
      _peopleLoading = true;
      _peopleError = null;
    });

    try {
      final results = await _fetchPeople(query);
      if (!mounted) return;
      setState(() {
        _peopleResults = results;
        _peopleLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _peopleLoading = false;
        _peopleError = 'Could not load people. Try again.';
        _peopleResults = [];
      });
    }
  }

  Future<List<UserModel>> _fetchPeople(String query) async {
    final trimmed = query.trim().toLowerCase();
    final currentUid = AuthService().currentUid;
    final firestore = FirebaseFirestore.instance;

    try {
      final snapshot = await firestore
          .collection('users')
          .orderBy('username')
          .startAt([trimmed])
          .endAt(['$trimmed\uf8ff'])
          .limit(30)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) => user.uid != currentUid)
          .toList();
    } on FirebaseException {
      final snapshot = await firestore.collection('users').limit(80).get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) {
            if (user.uid == currentUid) return false;
            return user.username.toLowerCase().contains(trimmed) ||
                user.email.toLowerCase().contains(trimmed);
          })
          .take(30)
          .toList();
    }
  }

  void _goToPeopleTab() {
    _tabController.animateTo(2);
    _searchFocus.requestFocus();
    _runPeopleSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchTopBar(
              showBackButton: widget.showBackButton,
              onBack: () => Navigator.of(context).pop(),
              onSearchIconTap: () => _searchFocus.requestFocus(),
              onSparkleTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Featured — coming soon'),
                  ),
                );
              },
            ),
            Container(
              decoration: const BoxDecoration(
                color: _headerTint,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) {
                        if (_tabController.index != 2) {
                          _goToPeopleTab();
                        } else {
                          _runPeopleSearch();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: const TextStyle(
                          color: _textMid,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: _surface,
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: _searchIconRed,
                          size: 24,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: _borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: _borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(
                            color: _accentRed.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                    dividerColor: Colors.transparent,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                    labelColor: _accentRed,
                    unselectedLabelColor: _tabInactive,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF8F4C),
                          Color(0xFFE53935),
                          Color(0xFF8B1538),
                        ],
                      ),
                    ),
                    indicatorPadding: const EdgeInsets.only(bottom: 10),
                    tabs: _tabs.map((label) => Tab(text: label)).toList(),
                    onTap: (index) {
                      if (index == 2) {
                        _runPeopleSearch();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PlaceholderTab(
                    title: 'Top results',
                    query: _searchController.text,
                  ),
                  _PlaceholderTab(
                    title: 'Latest',
                    query: _searchController.text,
                  ),
                  _PeopleTab(
                    query: _searchController.text,
                    loading: _peopleLoading,
                    error: _peopleError,
                    results: _peopleResults,
                    onRetry: _runPeopleSearch,
                  ),
                  _PlaceholderTab(
                    title: 'Media',
                    query: _searchController.text,
                  ),
                  _PlaceholderTab(
                    title: 'Tags',
                    query: _searchController.text,
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

class _SearchTopBar extends StatelessWidget {
  const _SearchTopBar({
    required this.showBackButton,
    required this.onBack,
    required this.onSearchIconTap,
    required this.onSparkleTap,
  });

  final bool showBackButton;
  final VoidCallback onBack;
  final VoidCallback onSearchIconTap;
  final VoidCallback onSparkleTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _textDark,
                size: 20,
              ),
            )
          else
            const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'SearchTab',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: 0.2,
              ),
            ),
          ),
          IconButton(
            onPressed: onSearchIconTap,
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

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title, required this.query});

  final String title;
  final String query;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          query.trim().isEmpty
              ? 'Type in the search bar to find posts and more.'
              : 'Showing results for "${query.trim()}" — coming soon.',
          style: const TextStyle(
            fontSize: 14,
            color: _textMid,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _PeopleTab extends StatelessWidget {
  const _PeopleTab({
    required this.query,
    required this.loading,
    required this.error,
    required this.results,
    required this.onRetry,
  });

  final String query;
  final bool loading;
  final String? error;
  final List<UserModel> results;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Search by username or email to find people.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _textMid, height: 1.4),
          ),
        ),
      );
    }

    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: _accentRed, strokeWidth: 2.5),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: _textMid)),
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No people found for "${query.trim()}".',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: _textMid, height: 1.4),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = results[index];
        return _PersonTile(user: user);
      },
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProfileScreen(userId: user.uid),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              _Avatar(photoUrl: user.profilePhoto),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    if (user.aboutMe.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.aboutMe,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: _textMid),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _textMid, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8E8EC),
        border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.35)),
      ),
      child: photoUrl.isEmpty
          ? const Icon(Icons.person_rounded, color: Color(0xFFB0A8B8), size: 28)
          : ClipOval(
              child: Image.network(
                photoUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person_rounded,
                  color: Color(0xFFB0A8B8),
                  size: 28,
                ),
              ),
            ),
    );
  }
}
