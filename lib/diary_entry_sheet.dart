import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'model/diary_entry_model.dart';
import 'repo/auth_service.dart';

const Color _accent      = Color(0xFF6A3DE8);
const Color _accentLight = Color(0xFF8B6EFF);
const Color _bg          = Color(0xFFF7F7FB);
const Color _surface     = Colors.white;
const Color _textDark    = Color(0xFF1D1A29);
const Color _textMid     = Color(0xFF7A7690);
const Color _border      = Color(0xFFE8E4F4);
const Color _chipBg      = Color(0xFFF0EDF8);

class DiaryEntrySheet extends StatefulWidget {
  const DiaryEntrySheet({super.key, this.existing, this.initialDate});

  /// Non-null when editing an existing entry.
  final DiaryEntryModel? existing;

  /// Pre-filled date (e.g. when tapping a day in the calendar).
  final DateTime? initialDate;

  static Future<void> show(BuildContext context,
      {DiaryEntryModel? existing, DateTime? initialDate}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => DiaryEntrySheet(
          existing: existing, initialDate: initialDate),
    );
  }

  @override
  State<DiaryEntrySheet> createState() => _DiaryEntrySheetState();
}

class _DiaryEntrySheetState extends State<DiaryEntrySheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late DateTime _entryDate;
  late DiaryMood _mood;
  late bool _isPublic;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl  = TextEditingController(text: e?.title ?? '');
    _bodyCtrl   = TextEditingController(text: e?.body ?? '');
    _entryDate  = e?.entryDate ?? widget.initialDate ?? DateTime.now();
    _mood       = e?.mood ?? DiaryMood.neutral;
    _isPublic   = e?.isPublic ?? false;
    _titleCtrl.addListener(() => setState(() {}));
    _bodyCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _titleCtrl.text.trim().isNotEmpty || _bodyCtrl.text.trim().isNotEmpty;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
    if (picked != null && mounted) setState(() => _entryDate = picked);
  }

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);
    try {
      final uid = AuthService().currentUid;
      if (uid == null) return;

      if (widget.existing != null) {
        await AuthService().updateDiaryEntry(
          DiaryEntryModel(
            entryId:   widget.existing!.entryId,
            uid:       uid,
            title:     _titleCtrl.text.trim(),
            body:      _bodyCtrl.text.trim(),
            mood:      _mood,
            isPublic:  _isPublic,
            entryDate: _entryDate,
            createdAt: widget.existing!.createdAt,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        await AuthService().createDiaryEntry(
          DiaryEntryModel(
            entryId:   const Uuid().v4(),
            uid:       uid,
            title:     _titleCtrl.text.trim(),
            body:      _bodyCtrl.text.trim(),
            mood:      _mood,
            isPublic:  _isPublic,
            entryDate: _entryDate,
            createdAt: DateTime.now(),
          ),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text('Failed to save: $e'),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final height = MediaQuery.sizeOf(context).height * 0.92;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: _bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: height,
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 10, 12, 10),
                  child: Row(children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded,
                          color: _textDark, size: 26),
                    ),
                    Expanded(
                      child: Text(
                        widget.existing != null
                            ? 'Edit Entry'
                            : 'New Entry',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _canSave && !_saving ? _save : null,
                      child: _saving
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2))
                          : Text('Save',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _canSave
                                    ? _accent
                                    : const Color(0xFFB8B4C4),
                              )),
                    ),
                  ]),
                ),
                const Divider(height: 1, color: _border),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Date pill ──────────────────────────────────
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _chipBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _accent.withValues(alpha: 0.3)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min,
                                children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 15, color: _accent),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(_entryDate),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _accent,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.edit_rounded,
                                  size: 13, color: _accent),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Mood picker ─────────────────────────────────
                        const Text('How are you feeling?',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _textMid)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: DiaryMood.values.map((m) {
                            final selected = _mood == m;
                            return GestureDetector(
                              onTap: () => setState(() => _mood = m),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? _accent.withValues(alpha: 0.12)
                                      : _surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected
                                        ? _accent.withValues(alpha: 0.45)
                                        : _border,
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                  Text(m.emoji,
                                      style:
                                          const TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  Text(m.label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selected
                                            ? _accent
                                            : _textMid,
                                      )),
                                ]),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // ── Title ──────────────────────────────────────
                        TextField(
                          controller: _titleCtrl,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                              height: 1.3),
                          decoration: const InputDecoration(
                            hintText: 'Title…',
                            hintStyle: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB8B4C4)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: _border),
                        const SizedBox(height: 10),

                        // ── Body ───────────────────────────────────────
                        TextField(
                          controller: _bodyCtrl,
                          minLines: 8,
                          maxLines: null,
                          style: const TextStyle(
                              fontSize: 16,
                              color: _textDark,
                              height: 1.6),
                          decoration: const InputDecoration(
                            hintText:
                                'Write your thoughts for today…',
                            hintStyle: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFB8B4C4),
                                height: 1.6),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 20),

                        // ── Public toggle ──────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _border),
                          ),
                          child: Row(children: [
                            Icon(
                              _isPublic
                                  ? Icons.public_rounded
                                  : Icons.lock_outline_rounded,
                              color: _accent, size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('Make Public',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _textDark)),
                                  Text(
                                    _isPublic
                                        ? 'Visible in Public Diaries'
                                        : 'Only you can see this',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: _textMid),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _isPublic,
                              onChanged: (v) =>
                                  setState(() => _isPublic = v),
                              activeThumbColor: _accent,
                              activeTrackColor: _accent.withValues(alpha: 0.4),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const m = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    const w = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    return '${w[d.weekday % 7]}, ${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}
