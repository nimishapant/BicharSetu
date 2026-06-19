import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';

/// Material 3 search field aligned with the drawer’s rounded, elevated inputs.
class SettingsSearchField extends StatefulWidget {
  const SettingsSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  State<SettingsSearchField> createState() => _SettingsSearchFieldState();
}

class _SettingsSearchFieldState extends State<SettingsSearchField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: bichar.accent.withValues(alpha: isDark ? 0.22 : 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: bichar.cardBackground,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          textInputAction: TextInputAction.search,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: bichar.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search settings',
            hintStyle: TextStyle(
              color: bichar.textSecondary.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _focused ? bichar.accent : bichar.mutedIcon,
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Clear',
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged('');
                    widget.onClear?.call();
                  },
                );
              },
            ),
            filled: true,
            fillColor: bichar.cardBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: bichar.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: bichar.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: bichar.accent.withValues(alpha: 0.65),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
