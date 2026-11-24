import 'package:flutter/services.dart';

import 'app_colors.dart';

abstract final class SystemUiStyles {
  static const onLightBackground = SystemUiOverlayStyle(
    statusBarColor: kWhite,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: kBackground,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const onDarkBackground = SystemUiOverlayStyle(
    statusBarColor: kBackgroundDark,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: kBackgroundDark,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
