import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static final List<BoxShadow> brandMarkShadow = List<BoxShadow>.unmodifiable([BoxShadow(color: kLogoBlue.withValues(alpha: 0.16), blurRadius: 36, spreadRadius: 8, offset: const Offset(0, 14))]);

  static List<BoxShadow> cardShadow(Color color) => List<BoxShadow>.unmodifiable([BoxShadow(color: color, blurRadius: 8, offset: const Offset(0, 2))]);

  static const List<BoxShadow> defaultShadow = [BoxShadow(color: kImageShadow, blurRadius: 6, spreadRadius: 0, offset: Offset(0, 3))];
  static const List<BoxShadow> bottomNavigationBarShadow = [BoxShadow(color: kSubtleShadow, blurRadius: 16, spreadRadius: 0, offset: Offset(0, -2))];
}
