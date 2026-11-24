import 'package:material_ui/material_ui.dart';

import '../constants/duration_constants.dart';

/// Show a custom bottom sheet #################################################
Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isDismissible = true,
  bool enableDrag = true,
  bool showDragHandle = true,
  double? borderRadius,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    shape: borderRadius == null ? null : RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius))),
    showDragHandle: showDragHandle,
    useSafeArea: true,
    builder: (context) => child,
  );
}

/// Show a custom alert dialog #################################################
Future<T?> showCustomAlertDialog<T>({required BuildContext context, required WidgetBuilder builder, bool barrierDismissible = true, Color? barrierColor}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    animationStyle: const AnimationStyle(
      curve: Curves.easeOutCubic,
      duration: DurationConstants.dialogTransitionDuration,
      reverseCurve: Curves.easeInCubic,
      reverseDuration: DurationConstants.dialogReverseTransitionDuration,
    ),
    builder: builder,
  );
}
