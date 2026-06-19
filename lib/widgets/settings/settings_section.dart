import 'package:flutter/material.dart';
import '../../theme/bichar_theme_extension.dart';
import 'premium_card.dart';

/// Groups related settings under a labeled section with drawer-matching typography.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.highlighted = false,
  });

  final String title;
  final List<Widget> children;
  final IconData? icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 15,
                    color: bichar.accent.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 7),
                ],
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.35,
                    color: bichar.textSecondary.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          bichar.border,
                          bichar.border.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          PremiumCard(
            highlighted: highlighted,
            child: Column(
              children: _intersperseDividers(children, bichar.border),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _intersperseDividers(List<Widget> tiles, Color border) {
    if (tiles.length <= 1) return tiles;
    final result = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      result.add(tiles[i]);
      if (i < tiles.length - 1) {
        result.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Divider(
              height: 1,
              thickness: 1,
              color: border.withValues(alpha: 0.85),
            ),
          ),
        );
      }
    }
    return result;
  }
}
