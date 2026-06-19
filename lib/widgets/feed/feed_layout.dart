import 'package:flutter/material.dart';

/// Shared layout constants for the home feed — mirrors settings max-width behavior.
class FeedLayout {
  FeedLayout._();

  static const double cardRadius = 20.0;
  static const double feedMaxWidth = 920.0;

  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 800) return feedMaxWidth;
    return width;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 28;
    if (width >= 800) return 22;
    return 16;
  }

  /// Centers feed content on wide screens with comfortable side margins.
  static Widget constrain({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth(context)),
        child: Padding(
          padding: padding ??
              EdgeInsets.symmetric(horizontal: horizontalPadding(context)),
          child: child,
        ),
      ),
    );
  }
}
