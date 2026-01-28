import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;
  
  static double getCalendarGridSize(BuildContext context) {
    if (isDesktop(context)) return 60;
    if (isTablet(context)) return 50;
    return 40;
  }
  
  static int getCalendarCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) return 7;
    return 7;
  }
  
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) return const EdgeInsets.all(24);
    if (isTablet(context)) return const EdgeInsets.all(16);
    return const EdgeInsets.all(12);
  }
}