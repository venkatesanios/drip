import '../enums.dart';

const int mobileBreakpoint = 600;
const int tabletBreakpoint = 900;
const int desktopBreakpoint = 1200;

class ScreenHelper {
  static ScreenType getScreenType(double width) {
    if (width >= desktopBreakpoint) return ScreenType.web;
    if (width >= tabletBreakpoint) return ScreenType.desktop;
    if (width >= mobileBreakpoint) return ScreenType.tablet;
    return ScreenType.mobile;
  }
}