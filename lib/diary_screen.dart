import 'package:flutter/material.dart';

const Color _accent = Color(0xFF6A3DE8);
const Color _accentDark = Color(0xFF4A2BB8);
const Color _accentLight = Color(0xFF8B6EFF);
const Color _bg = Color(0xFFF7F7FB);
const Color _surface = Colors.white;
const Color _textDark = Color(0xFF1D1A29);
const Color _textMid = Color(0xFF7A7690);
const Color _border = Color(0xFFE8E4F4);
const Color _chipBg = Color(0xFFF0EDF8);

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  int _selectedTab = 0;
  bool _isSearching = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _isSearching = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _DiaryFab(onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('New diary entry — coming soon'),
          ),
        );
      }),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DiaryAppBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(child: _DiaryTabBar(
                    selectedIndex: _selectedTab,
                    onChanged: (i) => setState(() => _selectedTab = i),
                  )),
                  const SizedBox(width: 10),
                  _CalendarSquareButton(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Calendar — coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: _border),
            _FilterRow(
              onDateTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Date filter — coming soon'),
                  ),
                );
              },
            ),
            const Divider(height: 1, thickness: 1, color: _border),
            Expanded(
              child: Container(
                color: _bg,
                child: _isSearching
                    ? const _DiaryEmptyState(searching: true)
                    : _DiaryEmptyState(
                        searching: false,
                        isPublicTab: _selectedTab == 0,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaryAppBar extends StatelessWidget {
  const _DiaryAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 4),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.chevron_left_rounded,
            iconColor: _accent,
            onTap: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Diary',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [_accentLight, _accentDark],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _CircleIconButton(
            icon: Icons.workspace_premium_rounded,
            iconColor: _accent,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _chipBg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: iconColor, size: 24),
        ),
      ),
    );
  }
}

class _DiaryTabBar extends StatelessWidget {
  const _DiaryTabBar({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _TabChip(
            label: 'Public Diaries',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabChip(
            label: 'My Diary',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? _accent : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _textMid,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarSquareButton extends StatelessWidget {
  const _CalendarSquareButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _textDark.withValues(alpha: 0.15)),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: _accent,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.onDateTap});

  final VoidCallback onDateTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 18, color: _accent),
          const SizedBox(width: 8),
          const Text(
            'All Time',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const Spacer(),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDateTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accent.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_rounded, size: 16, color: _accent),
                    SizedBox(width: 6),
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaryEmptyState extends StatelessWidget {
  const _DiaryEmptyState({
    required this.searching,
    this.isPublicTab = true,
  });

  final bool searching;
  final bool isPublicTab;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (searching)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _accent,
                ),
              ),
            ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8E8EC),
              border: Border.all(color: const Color(0xFFD8D8DE), width: 1.5),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 52,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            searching ? 'Searching Journals' : 'No journals yet',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _textMid,
            ),
          ),
          if (!searching) ...[
            const SizedBox(height: 8),
            Text(
              isPublicTab
                  ? 'Public diaries will appear here.'
                  : 'Tap + to write your first diary entry.',
              style: const TextStyle(
                fontSize: 14,
                color: _textMid,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiaryFab extends StatelessWidget {
  const _DiaryFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_accentLight, _accentDark],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Center(
            child: Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
