import 'package:flutter/material.dart';

/// Material 3 window size classes.
///
/// compact  < 600   → phone: bottom navigation, single pane
/// medium   600-1024 → small tablet: navigation rail, single centered pane
/// expanded ≥ 1024  → desktop/large tablet: rail + calendar + details panel
enum WindowSize { compact, medium, expanded }

class ResponsiveHelper {
  const ResponsiveHelper._();

  static WindowSize windowSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return WindowSize.compact;
    if (width < 1024) return WindowSize.medium;
    return WindowSize.expanded;
  }

  static bool isCompact(BuildContext context) =>
      windowSize(context) == WindowSize.compact;

  static bool isMedium(BuildContext context) =>
      windowSize(context) == WindowSize.medium;

  static bool isExpanded(BuildContext context) =>
      windowSize(context) == WindowSize.expanded;

  // Kept for existing call sites.
  static bool isMobile(BuildContext context) => isCompact(context);
  static bool isTablet(BuildContext context) => isMedium(context);
  static bool isDesktop(BuildContext context) => isExpanded(context);

  /// Width of the details side panel on expanded layouts.
  static const double detailsPanelWidth = 360;

  /// Max readable width for list-style pages (settings, tools, events…).
  static const double contentMaxWidth = 720;

  static EdgeInsets getScreenPadding(BuildContext context) {
    switch (windowSize(context)) {
      case WindowSize.expanded:
        return const EdgeInsets.all(24);
      case WindowSize.medium:
        return const EdgeInsets.all(16);
      case WindowSize.compact:
        return const EdgeInsets.all(12);
    }
  }
}

/// Centers list-style page content at a readable width on wide screens.
/// On compact windows it is a no-op.
class AdaptiveContent extends StatelessWidget {
  const AdaptiveContent({Key? key, required this.child, this.maxWidth})
      : super(key: key);

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isCompact(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveHelper.contentMaxWidth,
        ),
        child: child,
      ),
    );
  }
}
