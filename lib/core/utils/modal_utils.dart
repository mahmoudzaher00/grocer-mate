import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

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
Future<T?> showCustomAlertDialog<T>({required BuildContext context, required WidgetBuilder builder, bool barrierDismissible = true, Color? barrierColor}) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    animationStyle: reduceMotion
        ? AnimationStyle.noAnimation
        : const AnimationStyle(curve: Curves.easeOutCubic, duration: Duration(milliseconds: 180), reverseCurve: Curves.easeInCubic, reverseDuration: Duration(milliseconds: 120)),
    builder: builder,
  );
}
