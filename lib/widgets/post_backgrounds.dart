import 'package:flutter/material.dart';

/// The palette of coloured post backgrounds.
/// Index 0 = no background (plain card).
/// Indices 1–12 = coloured gradients.
class PostBackground {
  const PostBackground._();

  /// All background options. Index matches [PostModel.backgroundIndex].
  static const List<_BgOption> options = [
    _BgOption(label: 'None', colors: []),
    _BgOption(label: 'Sunset', colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
    _BgOption(label: 'Ocean', colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)]),
    _BgOption(label: 'Forest', colors: [Color(0xFF56ab2f), Color(0xFFa8e063)]),
    _BgOption(label: 'Lavender', colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
    _BgOption(label: 'Rose', colors: [Color(0xFFf953c6), Color(0xFFb91d73)]),
    _BgOption(label: 'Midnight', colors: [Color(0xFF232526), Color(0xFF414345)]),
    _BgOption(label: 'Gold', colors: [Color(0xFFf7971e), Color(0xFFffd200)]),
    _BgOption(label: 'Teal', colors: [Color(0xFF11998e), Color(0xFF38ef7d)]),
    _BgOption(label: 'Cherry', colors: [Color(0xFFeb3349), Color(0xFFf45c43)]),
    _BgOption(label: 'Sky', colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)]),
    _BgOption(label: 'Peach', colors: [Color(0xFFFFB347), Color(0xFFFFCC33)]),
    _BgOption(label: 'Plum', colors: [Color(0xFF4B134F), Color(0xFFC94B4B)]),
  ];

  /// Returns the gradient for a given index, or null for index 0.
  static LinearGradient? gradientFor(int index) {
    if (index <= 0 || index >= options.length) return null;
    final colors = options[index].colors;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  /// True if the given index uses a dark background (white text needed).
  static bool isDark(int index) {
    if (index <= 0) return false;
    const darkIndices = {4, 5, 6, 12};
    return darkIndices.contains(index);
  }
}

class _BgOption {
  final String label;
  final List<Color> colors;
  const _BgOption({required this.label, required this.colors});
}

/// Horizontal scrollable palette strip shown in CreatePostScreen.
class PostBackgroundPicker extends StatelessWidget {
  const PostBackgroundPicker({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: PostBackground.options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = PostBackground.options[index];
          final isSelected = selectedIndex == index;

          Widget circle;
          if (index == 0) {
            // "No background" — white circle with a slash
            circle = Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.black54 : Colors.grey.shade300,
                  width: isSelected ? 2.5 : 1.5,
                ),
              ),
              child: Icon(Icons.format_color_reset_rounded,
                  size: 18, color: Colors.grey.shade500),
            );
          } else {
            circle = Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: option.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: option.colors.first.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 18, color: Colors.white)
                  : null,
            );
          }

          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 180),
              child: circle,
            ),
          );
        },
      ),
    );
  }
}
