import 'package:material_ui/material_ui.dart';

extension ContextExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get height => MediaQuery.sizeOf(this).height;
  double get width => MediaQuery.sizeOf(this).width;
  double get shortestSide => MediaQuery.sizeOf(this).shortestSide;
  double get longestSide => MediaQuery.sizeOf(this).longestSide;
  Orientation get orientation => MediaQuery.orientationOf(this);
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  void get hideKeyBoard => FocusScope.of(this).requestFocus(FocusNode());
}
enum FormFactor { desktop, tablet, mobile }
extension AdaptiveGridViewCount on BuildContext {
  T withFormFactor<T>({
    required T onMobile,
    required T onTablet,
    required T onDesktop,
    bool followDeviceOrientation = true,
  }) {
    final width = followDeviceOrientation
        ? mediaQuery.size.width
        : mediaQuery.size.shortestSide;

    if (width > ScreenWidthBreakpoints.desktop) return onDesktop;
    if (width > ScreenWidthBreakpoints.tablet) return onTablet;
    return onMobile;
  }
}


class ScreenWidthBreakpoints {
  static const double desktop = 900;
  static const double tablet = 600;
  static const double mobile = 300;
}

extension FormFactorHelpers on FormFactor {
  bool get isDesktop => this == FormFactor.desktop;
  bool get isTablet => this == FormFactor.tablet;
  bool get isMobile => this == FormFactor.mobile;
}


