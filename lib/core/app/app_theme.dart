import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'app_constants.dart';
import '../resources/font_manager.dart';
import '../resources/color_manager.dart';
import '../resources/style_manager.dart';

final SkeletonizerConfigData appSkeletonizerConfig = SkeletonizerConfigData(
  effectResolver: (context) => const ShimmerEffect(baseColor: kGrey200, highlightColor: kGrey100, duration: Duration(milliseconds: 1500)),
);

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    primaryColor: kPrimary,
    primaryColorLight: kPrimaryLight,
    primaryColorDark: kPrimaryDark,
    disabledColor: kGrey300,
    splashColor: kPrimaryDark.withValues(alpha: 0.12),
    highlightColor: kPrimaryDark.withValues(alpha: 0.08),
    scaffoldBackgroundColor: kBackground,
    fontFamily: FontConstants.fontFamily,
    appBarTheme: AppBarTheme(
      elevation: 0,
      systemOverlayStyle: AppConstants.statusBarOnTransparent,
      backgroundColor: kWhite,
      surfaceTintColor: kWhite,
      titleTextStyle: getSemiBoldStyle(color: kTextPrimary, fontSize: 18.sp),
      titleSpacing: 0,

      // shadowColor: kWhite,
      iconTheme: const IconThemeData(color: kTextPrimary),
      // foregroundColor: kWhiteColor,
    ),

    textButtonTheme: TextButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: getRegularStyle(color: kPrimaryDark, fontSize: 15),
        backgroundColor: kTransparent,
        foregroundColor: kPrimaryDark,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: kPrimary,
        // visualDensity: VisualDensity.standard,
      ),
    ),

    buttonTheme: const ButtonThemeData(shape: StadiumBorder(), disabledColor: kGrey300, buttonColor: kPrimary, splashColor: kPrimaryLight),

    bottomSheetTheme: const BottomSheetThemeData(surfaceTintColor: kWhite, dragHandleColor: kGreyD2, dragHandleSize: Size(48, 5)),

    textTheme: TextTheme(
      // Headings (Bold)
      headlineLarge: getBoldStyle(color: kTextPrimary, fontSize: 16.sp),
      headlineMedium: getBoldStyle(color: kWhite, fontSize: 14.sp),
      headlineSmall: getBoldStyle(color: kPrimary, fontSize: 12.sp),

      // Titles (SemiBold)
      titleLarge: getSemiBoldStyle(color: kTextPrimary, fontSize: 16.sp),
      titleMedium: getSemiBoldStyle(color: kWhite, fontSize: 14.sp),
      titleSmall: getSemiBoldStyle(color: kPrimary, fontSize: 12.sp),

      // Body (Regular)
      bodyLarge: getRegularStyle(color: kTextPrimary, fontSize: 16.sp),
      bodyMedium: getRegularStyle(color: kWhite, fontSize: 14.sp),
      bodySmall: getRegularStyle(color: kPrimary, fontSize: 12.sp),

      // Labels / Buttons (Medium)
      labelLarge: getMediumStyle(color: kTextPrimary, fontSize: 16.sp),
      labelMedium: getMediumStyle(color: kWhite, fontSize: 14.sp),
      labelSmall: getMediumStyle(color: kPrimary, fontSize: 12.sp),
    ),

    textSelectionTheme: TextSelectionThemeData(selectionColor: kPrimary.withValues(alpha: 0.5), selectionHandleColor: kPrimary),

    tabBarTheme: TabBarThemeData(overlayColor: WidgetStateProperty.all(kPrimaryLight.withValues(alpha: 0.2)), labelColor: kPrimaryDark, unselectedLabelColor: kGrey500, indicatorColor: kPrimary),
  );
}
