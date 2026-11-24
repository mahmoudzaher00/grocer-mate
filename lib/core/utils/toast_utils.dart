import 'package:material_ui/material_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../theme/app_colors.dart';

enum ToastStates { success, error, warning, info, general }

Color _toastColorFor(ToastStates state) {
  return switch (state) {
    ToastStates.success => kSuccess,
    ToastStates.error => kError,
    ToastStates.warning => kWarning,
    ToastStates.info => kGrey600,
    ToastStates.general => kGrey7B,
  };
}

Color _toastTextColorFor(ToastStates state) {
  return switch (state) {
    ToastStates.error || ToastStates.warning => kTextPrimary,
    _ => kWhite,
  };
}

void showToast({required String message, required ToastStates state, Color? textColor, ToastGravity? gravity}) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: gravity ?? ToastGravity.BOTTOM,
    backgroundColor: _toastColorFor(state),
    textColor: textColor ?? _toastTextColorFor(state),
    fontSize: 16.0,
    fontAsset: 'assets/fonts/Nunito-Medium.ttf',
  );
}
