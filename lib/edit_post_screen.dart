import 'package:flutter/material.dart';
import 'model/post_model.dart';
import 'repo/auth_service.dart';
import 'widgets/mention_text_field.dart';
import 'widgets/post_backgrounds.dart';

const Color _bg       = Color(0xFFF5F5F7);
const Color _textDark = Color(0xFF1D1A29);
const Color _textMid  = Color(0xFF8A8699);
const Color _chipBg   = Color(0xFFE8E8EC);
const Color _divider  = Color(0xFFE2E2E6);

const List<String> _categories = [
  'कविता / Poetry',
  'कविता, लघुकथा, विचार लेख',
  'जीवन दर्शन, रचनात्मक लेखन, प्रेम, डायरी',
  'गजल, स्क्रिप्ट लेखन, जीवन अनुभव',
  'समसामयिक लेख, AI र भविष्य, दृश्य लेखन',
  'गद्य साहित्य / Prose',
  'विज्ञान कथा',
  'गीत / गीतिकाविता',
  'समाज र राजनीति / Society & Politics',
  'धर्म र अध्यात्म / Religion & Spirituality',
  'व्यक्तिगत ब्लग / Personal Blog',
  'विविध / Others',
];

class EditPostSheet extends StatefulWidget {
  const EditPostSheet({super.key, required this.post});

  final PostModel post;

  /// Show the edit sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context, PostModel post) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => EditPostSheet(post: post),
    );
  }

  @override
  State<EditPostSheet> createState() => _EditPostSheetState();
}

class _EditPostSheetState extends State<EditPostSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _keywordsCtrl;
  final _titleFocus = FocusNode();
  final _bodyFocus  = FocusNode();

  late int _selectedCategory;
  late int _selectedBackground;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl        = TextEditingController(text: widget.post.title);
    _bodyCtrl         = TextEditingController(text: widget.post.body);
    _keywordsCtrl     = TextEditingController(
        text: widget.post.keywords.join(', '));
    _selectedCategory = _categories.indexOf(widget.post.category);
    if (_selectedCategory < 0) _selectedCategory = 0;
    _selectedBackground = widget.post.backgroundIndex;

    _titleCtrl.addListener(() => setState(() {}));
    _bodyCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _keywordsCtrl.dispose();
    _titleFocus.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  bool get _hasChanges =>
      _titleCtrl.text.trim() != widget.post.title ||
      _bodyCtrl.text.trim() != widget.post.body ||
      _selectedCategory != _categories.indexOf(widget.post.category) ||
      _selectedBackground != widget.post.backgroundIndex ||
      _keywordsCtrl.text.trim() !=
          widget.post.keywords.join(', ');

  Future<void> _onSave() async {
    if (_isSaving || !_hasChanges) return;
    setState(() => _isSaving = true);

    try {
      final keywordsRaw = _keywordsCtrl.text.trim();
      final keywords = keywordsRaw.isEmpty
          ? <String>[]
          : keywordsRaw
              .split(',')
              .map((k) => k.trim())
              .where((k) => k.isNotEmpty)
              .toList();

      await AuthService().updatePost(
        postId: widget.post.postId,
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        keywords: keywords,
        category: _categories[_selectedCategory],
        backgroundIndex: _selectedBackground,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1D1A29),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          content: const Text('Post updated!',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          content: Text('$e',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.92;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: _bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: sheetHeight,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 10, 12, 10),
                  child: Row(children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded,
                          color: _textDark, size: 26),
                    ),
                    const Expanded(
                      child: Text('Edit post',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _textDark)),
                    ),
                    TextButton(
                      onPressed:
                          (_hasChanges && !_isSaving) ? _onSave : null,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2))
                          : Text('Save',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _hasChanges
                                    ? _textDark
                                    : const Color(0xFFB8B4C4),
                              )),
                    ),
                  ]),
                ),
                const Divider(height: 1, thickness: 1, color: _divider),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 24h warning banner
                        if (widget.post.createdAt != null)
                          _EditWindowBanner(
                              createdAt: widget.post.createdAt!),
                        const SizedBox(height: 14),

                        // Title
                        MentionTextField(
                          controller: _titleCtrl,
                          focusNode: _titleFocus,
                          hintText: 'Title...',
                          minLines: 1,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                              height: 1.3),
                          decoration: const InputDecoration(
                            hintText: 'Title...',
                            hintStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB8B4C4)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 8),

                        // Body
                        MentionTextField(
                          controller: _bodyCtrl,
                          focusNode: _bodyFocus,
                          hintText: 'Write something...',
                          minLines: 4,
                          maxLines: 12,
                          style: const TextStyle(
                              fontSize: 16,
                              color: _textDark,
                              height: 1.45),
                          decoration: const InputDecoration(
                            hintText: 'Write something...',
                            hintStyle: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFB8B4C4)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),

                        // Background picker
                        const Text('Post Background',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _textMid,
                                letterSpacing: 0.3)),
                        const SizedBox(height: 10),
                        PostBackgroundPicker(
                          selectedIndex: _selectedBackground,
                          onSelected: (i) =>
                              setState(() => _selectedBackground = i),
                        ),

                        // Live background preview
                        if (_selectedBackground > 0 &&
                            (_titleCtrl.text.trim().isNotEmpty ||
                                _bodyCtrl.text.trim().isNotEmpty)) ...[
                          const SizedBox(height: 14),
                          _BgPreview(
                            text: _titleCtrl.text.trim().isNotEmpty
                                ? _titleCtrl.text.trim()
                                : _bodyCtrl.text.trim(),
                            backgroundIndex: _selectedBackground,
                          ),
                        ],
                        const SizedBox(height: 12),

                        // Keywords
                        TextField(
                          controller: _keywordsCtrl,
                          style: const TextStyle(
                              fontSize: 14, color: _textDark),
                          decoration: const InputDecoration(
                            hintText:
                                'Keywords (tags), separate with commas',
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFB8B4C4)),
                            filled: true,
                            fillColor: Color(0xFFEDEDF1),
                            border: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: _divider)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: _divider)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: _textMid)),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Category
                        const Text('Category',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _textDark)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_categories.length,
                              (i) {
                            final selected = _selectedCategory == i;
                            return GestureDetector(
                              onTap: () => setState(
                                  () => _selectedCategory = i),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 180),
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: selected ? _textDark : _chipBg,
                                  borderRadius:
                                      BorderRadius.circular(24),
                                ),
                                child: Text(_categories[i],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: selected
                                          ? Colors.white
                                          : _textDark,
                                      height: 1.25,
                                    )),
                              ),
                            );
                          }),
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
}

// ── How much edit time is left ────────────────────────────────────────────────

class _EditWindowBanner extends StatelessWidget {
  const _EditWindowBanner({required this.createdAt});
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final hoursLeft =
        24 - DateTime.now().difference(createdAt).inHours;
    final mins = 60 -
        (DateTime.now().difference(createdAt).inMinutes % 60);

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFFFCC02).withValues(alpha: 0.6)),
      ),
      child: Row(children: [
        const Icon(Icons.schedule_rounded,
            size: 18, color: Color(0xFFF59E0B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hoursLeft > 0
                ? 'You can edit this post for ${hoursLeft}h ${mins}m more.'
                : 'Less than an hour left to edit.',
            style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w500),
          ),
        ),
      ]),
    );
  }
}

class _BgPreview extends StatelessWidget {
  const _BgPreview(
      {required this.text, required this.backgroundIndex});
  final String text;
  final int backgroundIndex;

  @override
  Widget build(BuildContext context) {
    final gradient = PostBackground.gradientFor(backgroundIndex);
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 100),
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
          gradient: gradient, borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.4,
              shadows: [
                Shadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4)
              ],
            )),
      ),
    );
  }
}
