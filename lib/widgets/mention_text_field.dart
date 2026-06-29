import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../repo/auth_service.dart';
import '../theme/bichar_theme_extension.dart';

/// A TextField that shows a followers suggestion list when the user types @.
/// Drop-in replacement — exposes the same controller / focusNode pattern.
class MentionTextField extends StatefulWidget {
  const MentionTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hintText = 'Write something…',
    this.style,
    this.minLines = 1,
    this.maxLines = 8,
    this.textInputAction = TextInputAction.newline,
    this.textCapitalization = TextCapitalization.sentences,
    this.onChanged,
    this.decoration,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final TextStyle? style;
  final int minLines;
  final int maxLines;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;

  @override
  State<MentionTextField> createState() => _MentionTextFieldState();
}

class _MentionTextFieldState extends State<MentionTextField> {
  // Loaded once — current user's followers
  List<UserModel> _followers = [];
  bool _followersLoaded = false;

  // Active mention query — null means picker is hidden
  String? _mentionQuery;

  List<UserModel> get _suggestions {
    if (_mentionQuery == null) return [];
    final q = _mentionQuery!.toLowerCase();
    if (q.isEmpty) return _followers.take(6).toList();
    return _followers
        .where((u) => u.username.toLowerCase().startsWith(q))
        .take(6)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _loadFollowers();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  Future<void> _loadFollowers() async {
    if (_followersLoaded) return;
    try {
      final me = await AuthService().getCurrentUserModel();
      if (me == null || !mounted) return;
      // Fetch each follower's UserModel
      final futures = me.followers
          .map((uid) => AuthService()
              .userModelStream(uid)
              .first
              .catchError((_) => null as UserModel?))
          .toList();
      final results = await Future.wait(futures);
      if (!mounted) return;
      setState(() {
        _followers = results.whereType<UserModel>().toList();
        _followersLoaded = true;
      });
    } catch (_) {}
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    if (!selection.isValid) return;

    // Find the word being typed at cursor
    final cursor = selection.baseOffset.clamp(0, text.length);
    final before = text.substring(0, cursor);

    // Check if there's an @ that starts a mention (not preceded by a letter)
    final mentionMatch =
        RegExp(r'(?:^|(?<=\s))@(\w*)$').firstMatch(before);

    if (mentionMatch != null) {
      final query = mentionMatch.group(1) ?? '';
      if (!_followersLoaded) _loadFollowers();
      setState(() => _mentionQuery = query);
    } else {
      if (_mentionQuery != null) setState(() => _mentionQuery = null);
    }

    widget.onChanged?.call(text);
  }

  void _insertMention(UserModel user) {
    final text = widget.controller.text;
    final cursor =
        widget.controller.selection.baseOffset.clamp(0, text.length);
    final before = text.substring(0, cursor);
    final after = text.substring(cursor);

    // Replace the partial @mention with the full @username + space
    final replaced = before.replaceFirstMapped(
      RegExp(r'@(\w*)$'),
      (_) => '@${user.username} ',
    );

    widget.controller.value = TextEditingValue(
      text: replaced + after,
      selection: TextSelection.collapsed(offset: replaced.length),
    );

    setState(() => _mentionQuery = null);
    widget.focusNode.requestFocus();
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF7C4DFF),
      Color(0xFF00897B),
      Color(0xFFE91E8C),
      Color(0xFF1565C0),
      Color(0xFF6A3DE8),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final suggestions = _suggestions;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Mention suggestions list ──────────────────────────────────────
        if (suggestions.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(maxHeight: 220),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: bichar.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: bichar.border.withValues(alpha: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: suggestions.length,
              itemBuilder: (context, i) {
                final user = suggestions[i];
                return InkWell(
                  onTap: () => _insertMention(user),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(children: [
                      // Avatar
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _avatarColor(user.username),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: user.profilePhoto.isNotEmpty
                            ? Image.network(
                                user.profilePhoto,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Center(
                                  child: Text(
                                    user.username.isNotEmpty
                                        ? user.username[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  user.username.isNotEmpty
                                      ? user.username[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username.isNotEmpty
                                  ? user.username[0].toUpperCase() +
                                      user.username.substring(1)
                                  : user.username,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: bichar.textPrimary,
                              ),
                            ),
                            Text(
                              '@${user.username}',
                              style: TextStyle(
                                fontSize: 12,
                                color: bichar.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.alternate_email_rounded,
                          size: 16, color: bichar.accent),
                    ]),
                  ),
                );
              },
            ),
          ),

        // ── Text field ────────────────────────────────────────────────────
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          style: widget.style ??
              TextStyle(fontSize: 15, color: bichar.textPrimary),
          decoration: widget.decoration ??
              InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                    TextStyle(color: bichar.textSecondary, fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
          onChanged: (_) {
            // listener handles it — just trigger rebuild for send-button state
            setState(() {});
          },
        ),
      ],
    );
  }
}
