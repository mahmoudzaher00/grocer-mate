import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../app/app_constants.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'text_styles.dart';

final SkeletonizerConfigData appSkeletonizerConfig = SkeletonizerConfigData(
  effectResolver: (brightness) {
    final isDark = brightness == Brightness.dark;
    return ShimmerEffect(baseColor: isDark ? kGrey800 : kGrey200, highlightColor: isDark ? kGrey700 : kGrey100, duration: const Duration(milliseconds: 1500));
  },
);

ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: kGreen, brightness: Brightness.light).copyWith(
    primary: kGreen,
    onPrimary: kWhite,
    secondary: kGreen,
    tertiary: kPrimaryDark,
    surface: kWhite,
    surfaceContainer: kLightBlueEA,
    onSurface: kTextPrimary,
    error: kError,
    onError: kWhite,
    outline: kBorder,
    shadow: kShadowSm,
  );

  return _buildAppTheme(colorScheme: colorScheme, scaffoldBackgroundColor: kBackground, systemOverlayStyle: AppConstants.statusBarOnLightBackground);
}

ThemeData buildDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: kPeriwinkle, brightness: Brightness.dark).copyWith(
    primary: kPeriwinkle,
    onPrimary: kGrey900,
    secondary: kPeriwinkle,
    tertiary: kPrimaryLight,
    surface: kSurfaceDark,
    surfaceContainer: kGrey900,
    onSurface: kGrey100,
    error: kErrorLight,
    onError: kGrey900,
    outline: kGrey600,
    shadow: kTransparent,
  );

  return _buildAppTheme(colorScheme: colorScheme, scaffoldBackgroundColor: kBackgroundDark, systemOverlayStyle: AppConstants.statusBarOnDarkBackground);
}

ThemeData _buildAppTheme({required ColorScheme colorScheme, required Color scaffoldBackgroundColor, required SystemUiOverlayStyle systemOverlayStyle}) {
  final isDark = colorScheme.brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    primaryColor: colorScheme.primary,
    primaryColorLight: kPrimaryLight,
    primaryColorDark: kPrimaryDark,
    disabledColor: isDark ? kGrey600 : kGrey300,
    splashColor: colorScheme.primary.withValues(alpha: 0.12),
    highlightColor: colorScheme.primary.withValues(alpha: 0.08),
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    fontFamily: AppFonts.fontFamily,
    appBarTheme: AppBarTheme(
      elevation: 0,
      systemOverlayStyle: systemOverlayStyle,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surface,
      titleTextStyle: getSemiBoldStyle(color: colorScheme.onSurface, fontSize: 18.sp),
      titleSpacing: 0,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: getRegularStyle(color: colorScheme.primary, fontSize: 15),
        foregroundColor: colorScheme.primary,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: colorScheme.primary)),
    buttonTheme: ButtonThemeData(shape: const StadiumBorder(), disabledColor: isDark ? kGrey600 : kGrey300, buttonColor: colorScheme.primary, splashColor: colorScheme.primary.withValues(alpha: 0.12)),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: colorScheme.surface, surfaceTintColor: colorScheme.surface, dragHandleColor: colorScheme.outline, dragHandleSize: const Size(48, 5)),
    textTheme: _buildTextTheme(colorScheme),
    textSelectionTheme: TextSelectionThemeData(selectionColor: colorScheme.primary.withValues(alpha: 0.5), selectionHandleColor: colorScheme.primary),
    tabBarTheme: TabBarThemeData(
      overlayColor: WidgetStatePropertyAll(colorScheme.primary.withValues(alpha: 0.12)),
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.65),
      indicatorColor: colorScheme.primary,
    ),
  );
}

TextTheme _buildTextTheme(ColorScheme colorScheme) {
  return TextTheme(
    headlineLarge: getBoldStyle(color: colorScheme.onSurface, fontSize: 16.sp),
    headlineMedium: getBoldStyle(color: colorScheme.onSurface, fontSize: 14.sp),
    headlineSmall: getBoldStyle(color: colorScheme.primary, fontSize: 12.sp),
    titleLarge: getSemiBoldStyle(color: colorScheme.onSurface, fontSize: 16.sp),
    titleMedium: getSemiBoldStyle(color: colorScheme.onSurface, fontSize: 14.sp),
    titleSmall: getSemiBoldStyle(color: colorScheme.primary, fontSize: 12.sp),
    bodyLarge: getRegularStyle(color: colorScheme.onSurface, fontSize: 16.sp),
    bodyMedium: getRegularStyle(color: colorScheme.onSurface, fontSize: 14.sp),
    bodySmall: getRegularStyle(color: colorScheme.primary, fontSize: 12.sp),
    labelLarge: getMediumStyle(color: colorScheme.onSurface, fontSize: 16.sp),
    labelMedium: getMediumStyle(color: colorScheme.onSurface, fontSize: 14.sp),
    labelSmall: getMediumStyle(color: colorScheme.primary, fontSize: 12.sp),
  );
}
