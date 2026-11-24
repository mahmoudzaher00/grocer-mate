import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'system_ui_styles.dart';

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
    error: kErrorHighContrast,
    onError: kWhite,
    outline: kBorder,
    shadow: kShadowSm,
  );

  return _buildAppTheme(colorScheme: colorScheme, scaffoldBackgroundColor: kBackground, systemOverlayStyle: SystemUiStyles.onLightBackground);
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

  return _buildAppTheme(colorScheme: colorScheme, scaffoldBackgroundColor: kBackgroundDark, systemOverlayStyle: SystemUiStyles.onDarkBackground);
}

ThemeData _buildAppTheme({required ColorScheme colorScheme, required Color scaffoldBackgroundColor, required SystemUiOverlayStyle systemOverlayStyle}) {
  final isDark = colorScheme.brightness == Brightness.dark;
  final textTheme = _buildTextTheme(colorScheme);

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
      titleTextStyle: _textStyle(fontSize: 18.sp, fontWeight: AppFonts.semiBold, color: colorScheme.onSurface),
      titleSpacing: 0,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: _textStyle(fontSize: 15.sp, fontWeight: AppFonts.regular, color: colorScheme.primary),
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
    bottomSheetTheme: _buildBottomSheetTheme(colorScheme),
    dialogTheme: _buildDialogTheme(colorScheme, textTheme),
    textTheme: textTheme,
    inputDecorationTheme: _buildInputDecorationTheme(colorScheme, textTheme),
    textSelectionTheme: TextSelectionThemeData(cursorColor: colorScheme.primary, selectionColor: colorScheme.primary.withValues(alpha: 0.5), selectionHandleColor: colorScheme.primary),
    tabBarTheme: TabBarThemeData(
      overlayColor: WidgetStatePropertyAll(colorScheme.primary.withValues(alpha: 0.12)),
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.65),
      indicatorColor: colorScheme.primary,
    ),
  );
}

BottomSheetThemeData _buildBottomSheetTheme(ColorScheme colorScheme) {
  return BottomSheetThemeData(
    backgroundColor: colorScheme.surface,
    modalBackgroundColor: colorScheme.surface,
    surfaceTintColor: colorScheme.surface,
    dragHandleColor: colorScheme.outline,
    dragHandleSize: const Size(48, 5),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
  );
}

DialogThemeData _buildDialogTheme(ColorScheme colorScheme, TextTheme textTheme) {
  return DialogThemeData(
    alignment: Alignment.center,
    elevation: 6,
    backgroundColor: colorScheme.surfaceContainerHigh,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconColor: colorScheme.secondary,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
    titleTextStyle: textTheme.headlineSmall,
    contentTextStyle: textTheme.bodyMedium,
    actionsPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
    clipBehavior: Clip.none,
  );
}

InputDecorationTheme _buildInputDecorationTheme(ColorScheme colorScheme, TextTheme textTheme) {
  final borderRadius = BorderRadius.circular(14.r);

  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: color),
    );
  }

  return InputDecorationTheme(
    filled: true,
    fillColor: colorScheme.surface,
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.55)),
    labelStyle: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.68)),
    floatingLabelStyle: textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontSize: 14.sp),
    errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error, height: 1.8),
    errorMaxLines: 1,
    prefixIconColor: colorScheme.onSurface.withValues(alpha: 0.65),
    suffixIconColor: colorScheme.primary,
    prefixIconConstraints: const BoxConstraints(minWidth: 40, maxWidth: 40, maxHeight: 50),
    border: border(colorScheme.outline),
    enabledBorder: border(colorScheme.outline),
    focusedBorder: border(colorScheme.primary),
    disabledBorder: border(colorScheme.outline.withValues(alpha: 0.45)),
    errorBorder: border(colorScheme.error),
    focusedErrorBorder: border(colorScheme.error),
  );
}

TextTheme _buildTextTheme(ColorScheme colorScheme) {
  return TextTheme(
    headlineLarge: _textStyle(fontSize: 16.sp, fontWeight: AppFonts.bold, color: colorScheme.onSurface),
    headlineMedium: _textStyle(fontSize: 14.sp, fontWeight: AppFonts.bold, color: colorScheme.onSurface),
    headlineSmall: _textStyle(fontSize: 12.sp, fontWeight: AppFonts.bold, color: colorScheme.primary),
    titleLarge: _textStyle(fontSize: 16.sp, fontWeight: AppFonts.semiBold, color: colorScheme.onSurface),
    titleMedium: _textStyle(fontSize: 14.sp, fontWeight: AppFonts.semiBold, color: colorScheme.onSurface),
    titleSmall: _textStyle(fontSize: 12.sp, fontWeight: AppFonts.semiBold, color: colorScheme.primary),
    bodyLarge: _textStyle(fontSize: 16.sp, fontWeight: AppFonts.regular, color: colorScheme.onSurface),
    bodyMedium: _textStyle(fontSize: 14.sp, fontWeight: AppFonts.regular, color: colorScheme.onSurface),
    bodySmall: _textStyle(fontSize: 12.sp, fontWeight: AppFonts.regular, color: colorScheme.primary),
    labelLarge: _textStyle(fontSize: 16.sp, fontWeight: AppFonts.medium, color: colorScheme.onSurface),
    labelMedium: _textStyle(fontSize: 14.sp, fontWeight: AppFonts.medium, color: colorScheme.onSurface),
    labelSmall: _textStyle(fontSize: 12.sp, fontWeight: AppFonts.medium, color: colorScheme.primary),
  );
}

TextStyle _textStyle({required double fontSize, required FontWeight fontWeight, required Color color}) {
  return TextStyle(fontSize: fontSize, fontFamily: AppFonts.fontFamily, color: color, fontWeight: fontWeight);
}
