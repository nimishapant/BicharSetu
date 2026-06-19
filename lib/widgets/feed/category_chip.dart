import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';
import 'feed_layout.dart';

/// Premium category pill — Material 3 chip with optional emoji icon.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.compact = false,
  });

  final String category;
  final bool compact;

  static String _emojiForCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('poetry') || lower.contains('कविता') || lower.contains('गजल')) {
      return '📖';
    }
    if (lower.contains('story') || lower.contains('कथा') || lower.contains('fiction')) {
      return '✍️';
    }
    if (lower.contains('confession') || lower.contains('diary') || lower.contains('डायरी')) {
      return '🎭';
    }
    if (lower.contains('article') || lower.contains('blog') || lower.contains('लेख')) {
      return '📚';
    }
    if (lower.contains('song') || lower.contains('गीत')) {
      return '🎵';
    }
    if (lower.contains('politic') || lower.contains('समाज')) {
      return '🏛️';
    }
    if (lower.contains('religion') || lower.contains('spiritual') || lower.contains('धर्म')) {
      return '🕊️';
    }
    if (lower.contains('science') || lower.contains('विज्ञान')) {
      return '🔬';
    }
    return '✨';
  }

  static String _displayLabel(String category) {
    if (category.length <= 22) return category;
    return '${category.substring(0, 21)}…';
  }

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final isDark = context.isDarkMode;
    final accent = bichar.accent;
    final emoji = _emojiForCategory(category);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(FeedLayout.cardRadius),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.35 : 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: compact ? 12 : 13)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              _displayLabel(category),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w700,
                color: accent,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
