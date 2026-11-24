import 'package:flutter/services.dart';

import 'app_colors.dart';

abstract final class SystemUiStyles {
  static const onLightBackground = SystemUiOverlayStyle(
    statusBarColor: kWhite,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: kLightCanvas,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const onDarkBackground = SystemUiOverlayStyle(
    statusBarColor: kDarkCanvas,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: kDarkCanvas,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
