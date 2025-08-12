// lib/Widgets/Responsive.dart (example path)

import 'package:flutter/widgets.dart';
import '../Viewmodels/constants.dart'; // Import constants

class Responsive extends StatelessWidget {
  const Responsive({
    super.key,
    required this.mobile,
    required this.desktop,
    required this.tablet,
  });
  final Widget mobile;
  final Widget desktop;
  final Widget tablet;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < kTabletBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= kTabletBreakpoint &&
        MediaQuery.of(context).size.width < kDesktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= kDesktopBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return desktop;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return mobile;
    }
  }
}