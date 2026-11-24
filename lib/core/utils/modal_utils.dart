import 'dart:ui';

import '../theme/app_colors.dart';
import 'extensions/context_extensions.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app/app_constants.dart';

/// Show a custom bottom sheet #################################################
Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isDismissible = true,
  bool enableDrag = true,
  bool showDragHandle = true,
  double borderRadius = 32.0,
  Color backgroundColor = kWhite,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius))),
    showDragHandle: showDragHandle,
    useSafeArea: true,
    builder: (context) => child,
  );
}

/// Show a custom alert dialog #################################################
void showCustomAlertDialog({
  required BuildContext context,
  Color? barrierColor,
  Color? dialogShadowColor,
  Color? titleTextColor,
  Color? dialogBackGroundColor,
  Color? dialogSurfaceTintColor,
  double? alertDialogHeight,
  double? alertDialogWidth,
  double? blurSigmaX,
  double? dialogElevation,
  double? blurSigmaY,
  EdgeInsetsGeometry? blurOutSidePadding,
  Widget? contentTextWidget,
  Widget? customWidget,
  EdgeInsetsGeometry? contentTextPadding,
  EdgeInsetsGeometry? customWidgetPadding,
  AlignmentGeometry? dialogAlignment,
  EdgeInsets? dialogInsetsPadding,
  ShapeBorder? dialogShape,
  bool? contentScroll = false,
  EdgeInsetsGeometry? dialogContentPadding,
}) {
  showGeneralDialog(
    barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.5),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigmaX ?? 5.0, sigmaY: blurSigmaY ?? 5.0),
          child: AlertDialog(
            alignment: dialogAlignment ?? Alignment.bottomCenter,
            backgroundColor: dialogBackGroundColor ?? kWhite,
            surfaceTintColor: dialogSurfaceTintColor ?? kTransparent,
            shadowColor: dialogShadowColor ?? kTransparent,
            elevation: dialogElevation ?? 0,

            insetPadding: dialogInsetsPadding ?? const EdgeInsets.symmetric(horizontal: 0),
            contentPadding: dialogContentPadding ?? EdgeInsets.symmetric(horizontal: 16.w),
            shape: dialogShape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            buttonPadding: EdgeInsets.zero,
            content: Material(
              elevation: dialogElevation ?? 0,
              shape: dialogShape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              color: dialogBackGroundColor ?? kWhite,
              surfaceTintColor: dialogSurfaceTintColor ?? kTransparent,
              child: SizedBox(
                height: alertDialogHeight ?? 265,
                width: alertDialogWidth ?? context.width,
                child: contentScroll!
                    ? Stack(
                        children: [
                          Padding(
                            padding: customWidgetPadding ?? const EdgeInsets.only(top: 20),
                            child: ListView(padding: EdgeInsets.zero, children: [customWidget ?? const SizedBox()]),
                          ),
                          Padding(padding: contentTextPadding ?? const EdgeInsets.only(top: 18), child: contentTextWidget ?? const SizedBox()),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(padding: contentTextPadding ?? const EdgeInsets.only(top: 18), child: contentTextWidget ?? const SizedBox()),
                          Padding(padding: customWidgetPadding ?? const EdgeInsets.only(top: 20), child: customWidget ?? const SizedBox()),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: AppConstants.dialogAnimationTime),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const SizedBox();
    },
  );
}

Future<T?> showAlertDialog<T>({required BuildContext context, required Widget widgetContent, bool? barrierDismissible}) {
  return showGeneralDialog(
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curvedAnimation),
          child: AlertDialog(
            alignment: Alignment.center,
            backgroundColor: kWhite,
            surfaceTintColor: kTransparent,
            shadowColor: kTransparent,
            elevation: 4,
            insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            buttonPadding: EdgeInsets.zero,
            content: widgetContent,
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: AppConstants.dialogAnimationTime),
    barrierDismissible: barrierDismissible ?? true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const SizedBox();
    },
  );
}
