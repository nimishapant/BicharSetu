import 'package:flutter/material.dart';
import 'repo/auth_service.dart';

const Color _bg = Color(0xFFF5F5F7);
const Color _textDark = Color(0xFF1D1A29);
const Color _textMid = Color(0xFF8A8699);
const Color _chipBg = Color(0xFFE8E8EC);
const Color _divider = Color(0xFFE2E2E6);

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

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => const CreatePostScreen(),
    );
  }

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _keywordsCtrl = TextEditingController();

  String _displayName = 'User';
  int _selectedCategory = 0;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_onFieldsChanged);
    _bodyCtrl.addListener(_onFieldsChanged);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getCurrentUserModel();
    if (!mounted || user == null) return;
    setState(() => _displayName = user.username);
  }

  void _onFieldsChanged() => setState(() {});

  bool get _canPost =>
      _titleCtrl.text.trim().isNotEmpty || _bodyCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _keywordsCtrl.dispose();
    super.dispose();
  }

  Future<void> _onPost() async {
    if (!_canPost || _isPosting) return;
    setState(() => _isPosting = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isPosting = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1D1A29),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        content: const Text(
          'Post shared successfully!',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: sheetHeight,
            child: Column(
              children: [
                _Header(
                  canPost: _canPost,
                  isPosting: _isPosting,
                  onClose: () => Navigator.of(context).pop(),
                  onPost: _onPost,
                ),
                const Divider(height: 1, thickness: 1, color: _divider),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _UserRow(displayName: _displayName),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _titleCtrl,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                            height: 1.3,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Add a catchy title...',
                            hintStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB8B4C4),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _bodyCtrl,
                          minLines: 4,
                          maxLines: 12,
                          style: const TextStyle(
                            fontSize: 16,
                            color: _textDark,
                            height: 1.45,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Write something...',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFB8B4C4),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _keywordsCtrl,
                          style: const TextStyle(fontSize: 14, color: _textDark),
                          decoration: const InputDecoration(
                            hintText: 'Keywords (tags), separate with commas',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB8B4C4),
                            ),
                            filled: true,
                            fillColor: Color(0xFFEDEDF1),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: _divider),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _divider),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _textMid),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_categories.length, (i) {
                            final selected = _selectedCategory == i;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedCategory = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: selected ? _textDark : _chipBg,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  _categories[i],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: selected ? Colors.white : _textDark,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: _divider),
                _BottomBar(
                  onAddImage: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Photo attachment coming soon'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.canPost,
    required this.isPosting,
    required this.onClose,
    required this.onPost,
  });

  final bool canPost;
  final bool isPosting;
  final VoidCallback onClose;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 12, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, color: _textDark, size: 26),
          ),
          const Expanded(
            child: Text(
              'Create post',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
          ),
          TextButton(
            onPressed: canPost && !isPosting ? onPost : null,
            child: isPosting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Post',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: canPost ? _textDark : const Color(0xFFB8B4C4),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFEDE8FB),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Color(0xFFB0A8CC),
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: const [
                Icon(Icons.public_rounded, size: 14, color: _textMid),
                SizedBox(width: 4),
                Text(
                  'Public',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textMid,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onAddImage});

  final VoidCallback onAddImage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 14, 12),
        child: Row(
          children: [
            const Text(
              'Add to your post',
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
                onTap: onAddImage,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.image_outlined,
                    color: Color(0xFF45BD62),
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
