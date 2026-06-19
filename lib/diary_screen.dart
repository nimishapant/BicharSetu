import 'package:flutter/material.dart';
import 'diary_entry_sheet.dart';
import 'model/diary_entry_model.dart';
import 'repo/auth_service.dart';
import 'theme/bichar_theme_extension.dart';

const Color _accent      = Color(0xFF6A3DE8);
const Color _accentDark  = Color(0xFF4A2BB8);
const Color _accentLight = Color(0xFF8B6EFF);
const Color _bg          = Color(0xFFF7F7FB);
const Color _surface     = Colors.white;
const Color _textDark    = Color(0xFF1D1A29);
const Color _textMid     = Color(0xFF7A7690);
const Color _border      = Color(0xFFE8E4F4);
const Color _chipBg      = Color(0xFFF0EDF8);

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});
  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  int _selectedTab = 1;
  int _selectedDayIndex = 0;
  int _streakDays = 0;
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    _weekDates = _buildWeek(DateTime.now());
    _selectedDayIndex = _weekDates.indexWhere((d) =>
        d.year == DateTime.now().year &&
        d.month == DateTime.now().month &&
        d.day == DateTime.now().day);
    if (_selectedDayIndex < 0) _selectedDayIndex = 0;
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final s = await AuthService().getDiaryStreak();
    if (mounted) setState(() => _streakDays = s);
  }

  List<DateTime> _buildWeek(DateTime anchor) {
    final sun = anchor.subtract(Duration(days: anchor.weekday % 7));
    return List.generate(7, (i) => sun.add(Duration(days: i)));
  }

  DateTime get _selectedDate => _weekDates[_selectedDayIndex];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _accent, onPrimary: Colors.white,
            surface: _surface, onSurface: _textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _weekDates = _buildWeek(picked);
        _selectedDayIndex = _weekDates.indexWhere((d) =>
            d.year == picked.year &&
            d.month == picked.month &&
            d.day == picked.day);
        if (_selectedDayIndex < 0) _selectedDayIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Scaffold(
      backgroundColor: bichar.cardBackground,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _DiaryFab(
        onTap: () => DiaryEntrySheet.show(
          context,
          initialDate: _selectedDate,
        ).then((_) => _loadStreak()),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── App bar ──────────────────────────────────────────────────
            _DiaryAppBar(onBack: () => Navigator.of(context).pop()),

            // ── Tab + streak + calendar ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(children: [
                Expanded(
                  flex: 5,
                  child: _DiaryTabBar(
                    selectedIndex: _selectedTab,
                    onChanged: (i) => setState(() => _selectedTab = i),
                  ),
                ),
                if (_selectedTab == 1) ...[
                  const SizedBox(width: 8),
                  _StreakBadge(days: _streakDays),
                ],
                const SizedBox(width: 8),
                _CalendarButton(onTap: _pickDate),
              ]),
            ),

            // ── Week date picker (only for My Diary) ─────────────────────
            if (_selectedTab == 1) ...[
              const SizedBox(height: 14),
              _WeekDatePicker(
                dates: _weekDates,
                selectedIndex: _selectedDayIndex,
                onSelected: (i) => setState(() => _selectedDayIndex = i),
              ),
            ],
            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 1, color: _border),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: _selectedTab == 1
                  ? _MyDiaryTab(
                      selectedDate: _selectedDate,
                      onEntryChanged: _loadStreak,
                    )
                  : const _PublicDiaryTab(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── My Diary tab ─────────────────────────────────────────────────────────────

class _MyDiaryTab extends StatelessWidget {
  const _MyDiaryTab(
      {required this.selectedDate, required this.onEntryChanged});
  final DateTime selectedDate;
  final VoidCallback onEntryChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DiaryEntryModel>>(
      stream: AuthService().getDiaryEntriesForDate(selectedDate),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: _accent));
        }
        final entries = snap.data ?? [];
        if (entries.isEmpty) {
          return _EmptyDay(
            date: selectedDate,
            onWrite: () => DiaryEntrySheet.show(context,
                    initialDate: selectedDate)
                .then((_) => onEntryChanged()),
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: entries.length,
          itemBuilder: (context, i) => _DiaryCard(
            entry: entries[i],
            onEdit: () =>
                DiaryEntrySheet.show(context, existing: entries[i])
                    .then((_) => onEntryChanged()),
            onDelete: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text('Delete entry'),
                  content: const Text(
                      'This entry will be permanently deleted.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await AuthService()
                    .deleteDiaryEntry(entries[i].entryId);
                onEntryChanged();
              }
            },
          ),
        );
      },
    );
  }
}

// ─── Public Diary tab ─────────────────────────────────────────────────────────

class _PublicDiaryTab extends StatelessWidget {
  const _PublicDiaryTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DiaryEntryModel>>(
      stream: AuthService().getPublicDiaryStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: _accent));
        }
        final entries = snap.data ?? [];
        if (entries.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.menu_book_rounded,
                  size: 64, color: _textMid),
              const SizedBox(height: 16),
              const Text('No public diaries yet',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _textDark)),
              const SizedBox(height: 8),
              const Text('Be the first to share your thoughts.',
                  style: TextStyle(fontSize: 14, color: _textMid)),
            ]),
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: entries.length,
          itemBuilder: (context, i) =>
              _DiaryCard(entry: entries[i], isPublicView: true),
        );
      },
    );
  }
}

// ─── Empty day state ──────────────────────────────────────────────────────────

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.date, required this.onWrite});
  final DateTime date;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _chipBg,
              border: Border.all(color: _border, width: 1.5),
            ),
            child: const Icon(Icons.edit_note_rounded,
                size: 48, color: _accent),
          ),
          const SizedBox(height: 20),
          Text(
            isToday ? 'No entry for today' : 'No entry for this day',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark),
          ),
          const SizedBox(height: 8),
          Text(
            isToday
                ? 'How was your day? Write it down.'
                : 'You can still add an entry for this date.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, color: _textMid, height: 1.4),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onWrite,
            style: FilledButton.styleFrom(
              backgroundColor: _accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Write entry',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ]),
      ),
    );
  }
}

// ─── Diary card ───────────────────────────────────────────────────────────────

class _DiaryCard extends StatelessWidget {
  const _DiaryCard({
    required this.entry,
    this.onEdit,
    this.onDelete,
    this.isPublicView = false,
  });
  final DiaryEntryModel entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isPublicView;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header: date + mood + menu
        Row(children: [
          Text(entry.formattedDate,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textMid,
                  letterSpacing: 0.3)),
          const Spacer(),
          Text(entry.mood.emoji,
              style: const TextStyle(fontSize: 20)),
          if (!isPublicView && (onEdit != null || onDelete != null)) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded,
                  size: 20, color: _textMid),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onSelected: (v) {
                if (v == 'edit') onEdit?.call();
                if (v == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ])),
                const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text('Delete',
                          style: TextStyle(color: Colors.redAccent)),
                    ])),
              ],
            ),
          ],
        ]),
        if (entry.title.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(entry.title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                  height: 1.2)),
        ],
        if (entry.body.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(entry.body,
              maxLines: isPublicView ? 4 : null,
              overflow: isPublicView
                  ? TextOverflow.ellipsis
                  : TextOverflow.visible,
              style: const TextStyle(
                  fontSize: 14.5, color: _textDark, height: 1.5)),
        ],
        if (entry.updatedAt != null) ...[
          const SizedBox(height: 10),
          Text('Edited',
              style: TextStyle(
                  fontSize: 11,
                  color: _textMid.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic)),
        ],
        if (entry.isPublic) ...[
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.public_rounded, size: 13,
                color: _accent.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text('Public',
                style: TextStyle(
                    fontSize: 11,
                    color: _accent.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600)),
          ]),
        ],
      ]),
    );
  }
}

// ─── Reusable smaller widgets ─────────────────────────────────────────────────

class _DiaryAppBar extends StatelessWidget {
  const _DiaryAppBar({required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 4),
      child: Row(children: [
        _CircleBtn(icon: Icons.chevron_left_rounded, onTap: onBack),
        Expanded(
          child: Column(children: [
            const Text('Diary',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _textDark)),
            const SizedBox(height: 6),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                    colors: [_accentLight, _accentDark]),
              ),
            ),
          ]),
        ),
        _CircleBtn(
          icon: Icons.workspace_premium_rounded,
          onTap: () {},
        ),
      ]),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});
  final int days;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.local_fire_department_rounded, size: 18,
            color: days > 0 ? const Color(0xFFFF7043) : _textMid),
        const SizedBox(width: 4),
        Text('$days Day Streak',
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _textDark)),
      ]),
    );
  }
}

class _WeekDatePicker extends StatelessWidget {
  const _WeekDatePicker(
      {required this.dates,
      required this.selectedIndex,
      required this.onSelected});
  final List<DateTime> dates;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _days = ['SUN','MON','TUE','WED','THU','FRI','SAT'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final d = dates[i];
          final sel = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              width: 48,
              decoration: BoxDecoration(
                color: sel ? _accent.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(_days[d.weekday % 7],
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sel ? _accent : _textMid,
                        letterSpacing: 0.3)),
                const SizedBox(height: 6),
                Container(
                  width: 34, height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sel ? _accent : Colors.transparent,
                  ),
                  child: Text('${d.day}',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : _textDark)),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _DiaryTabBar extends StatelessWidget {
  const _DiaryTabBar({required this.selectedIndex, required this.onChanged});
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: _chipBg, borderRadius: BorderRadius.circular(24)),
      child: Row(children: [
        _Chip(
            label: 'Public Diaries',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0)),
        _Chip(
            label: 'My Diary',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1)),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _accent : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [BoxShadow(
                    color: _accent.withValues(alpha: 0.35),
                    blurRadius: 8, offset: const Offset(0, 3))]
                : null,
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : _textMid)),
        ),
      ),
    );
  }
}

class _CalendarButton extends StatelessWidget {
  const _CalendarButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _textDark.withValues(alpha: 0.2), width: 1.5),
        ),
        child: const Icon(Icons.calendar_month_rounded,
            color: _accent, size: 22),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: _chipBg, shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
            width: 42, height: 42,
            child: Icon(icon, color: _accent, size: 24)),
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
      width: 58, height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: _accent.withValues(alpha: 0.45),
              blurRadius: 16, offset: const Offset(0, 6))
        ],
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [_accentLight, _accentDark],
        ),
      ),
      child: Material(
        color: Colors.transparent, shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Center(
              child: Icon(Icons.edit_rounded,
                  color: Colors.white, size: 28)),
        ),
      ),
    );
  }
}
