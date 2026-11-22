import 'package:material_ui/material_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../resources/color_manager.dart';

enum ToastStates {
  success,
  error,
  warning,
  info,
  general
}

Color chooseToastColor(ToastStates state) {
  Color color;

  switch (state) {
    case ToastStates.success:
      color =kSuccess;
      break;
    case ToastStates.error:
      color = kError;
      break;
    case ToastStates.warning:
      color =kWarning;
      break;
    case ToastStates.info:
      color = kGrey600;
      break;
    case ToastStates.general:
      color = kGrey7B;
      break;
  }

  return color;
}

void showToast({required String message, required ToastStates state, Color? textColor, ToastGravity? gravity}) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: gravity ?? ToastGravity.BOTTOM,
    backgroundColor: chooseToastColor(state),
    textColor: textColor ??  kWhite,
    fontSize: 16.0,
    fontAsset: 'assets/fonts/Nunito-Medium.ttf'
  );
}
