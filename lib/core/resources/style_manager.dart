import 'package:material_ui/material_ui.dart';

import 'font_manager.dart';

TextStyle _getTextStyle(double fontSize, FontWeight fontWeight, Color color) {
  return TextStyle(fontSize: fontSize, fontFamily: FontConstants.fontFamily, color: color, fontWeight: fontWeight);
}

// regular style

TextStyle getRegularStyle({required Color color, double fontSize = 12}) {
  return _getTextStyle(fontSize, FontWeightManager.regular, color);
}

// medium style

TextStyle getMediumStyle({required Color color, double fontSize = 14}) {
  return _getTextStyle(fontSize, FontWeightManager.medium, color);
}

// semi bold style

TextStyle getSemiBoldStyle({required Color color, double fontSize = 16}) {
  return _getTextStyle(fontSize, FontWeightManager.semiBold, color);
}

// bold style

TextStyle getBoldStyle({required Color color, double fontSize = 16}) {
  return _getTextStyle(fontSize, FontWeightManager.bold, color);
}
