import 'package:flutter/material.dart';

/// Layout constants for the profile screen — centered column on wide screens.
class ProfileLayout {
  ProfileLayout._();

  static const double cardRadius = 20.0;
  static const double profileMaxWidth = 720.0;

  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 600) return profileMaxWidth;
    return width;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 32;
    if (width >= 800) return 24;
    return 16;
  }

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
