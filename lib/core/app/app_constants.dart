import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class AppConstants {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static const String baseUrl = '';
  static const Duration defaultTimeout = Duration(seconds: 10);

  static const String empty = '';
  static const int zero = 0;
  static const int taskRichTextContentMaxLength = 3000;
  static const int reopenReasonMaxLength = 500;
  static const int dialogAnimationTime = 400;
  static const Duration attachmentUploadSendTimeout = Duration(seconds: 120);
  static const Duration attachmentUploadReceiveTimeout = Duration(seconds: 60);
  static const animationDuration = Duration(milliseconds: 180);
  static const defaultDebounceDuration = Duration(milliseconds: 600);
  static const themeAnimationDuration = Duration(milliseconds: 200);
  static const themeIconAnimationDuration = Duration(milliseconds: 160);
  static const splashAnimationDuration = Duration(milliseconds: 1400);
  static const splashNavigationDelay = Duration(milliseconds: 2500);

  static const SystemUiOverlayStyle statusBarOnTransparent = SystemUiOverlayStyle(statusBarColor: kTransparent, statusBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.light);
  static const SystemUiOverlayStyle statusBarOnLightBackground = SystemUiOverlayStyle(
    statusBarColor: kWhite,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: kBackground,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
  static const SystemUiOverlayStyle statusBarOnDarkBackground = SystemUiOverlayStyle(
    statusBarColor: kBackgroundDark,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: kBackgroundDark,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static void hideKeyboard(BuildContext context) => FocusScope.of(context).requestFocus(FocusNode());

  static void keyboardBottomInset(BuildContext context) => MediaQuery.viewInsetsOf(context).bottom;
}
