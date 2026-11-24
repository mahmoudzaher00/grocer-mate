import 'package:material_ui/material_ui.dart';

import 'app_fonts.dart';

TextStyle _getTextStyle(double fontSize, FontWeight fontWeight, Color color) {
  return TextStyle(fontSize: fontSize, fontFamily: AppFonts.fontFamily, color: color, fontWeight: fontWeight);
}

// regular style

TextStyle getRegularStyle({required Color color, double fontSize = 12}) {
  return _getTextStyle(fontSize, AppFonts.regular, color);
}

// medium style

TextStyle getMediumStyle({required Color color, double fontSize = 14}) {
  return _getTextStyle(fontSize, AppFonts.medium, color);
}

// semi bold style

TextStyle getSemiBoldStyle({required Color color, double fontSize = 16}) {
  return _getTextStyle(fontSize, AppFonts.semiBold, color);
}

// bold style

TextStyle getBoldStyle({required Color color, double fontSize = 16}) {
  return _getTextStyle(fontSize, AppFonts.bold, color);
}
