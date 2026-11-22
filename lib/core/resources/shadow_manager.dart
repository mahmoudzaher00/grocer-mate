import 'package:material_ui/material_ui.dart';

import 'color_manager.dart';

class ShadowManager {
  static final List<BoxShadow> brandMarkShadow = [BoxShadow(color: kPrimary.withValues(alpha: 0.16), blurRadius: 36, spreadRadius: 8, offset: const Offset(0, 14))];

  static List<BoxShadow> shadow = [const BoxShadow(color: kShadowMd, blurRadius: 6, spreadRadius: 0, offset: Offset(0, 3))];
  static List<BoxShadow> noShadow = [const BoxShadow(color: Colors.transparent, blurRadius: 0, spreadRadius: 0, offset: Offset(0, 0))];
  static List<BoxShadow> checkBoxShadow = [const BoxShadow(color: kShadowSubtle, blurRadius: 2, spreadRadius: 0, offset: Offset(0, 1))];
  static List<BoxShadow> bottomNavBarShadow = [const BoxShadow(color: kShadowSm, blurRadius: 16, spreadRadius: 0, offset: Offset(0, -2))];
  static List<BoxShadow> elevatedShadow = [const BoxShadow(color: kShadowBlue, blurRadius: 10, spreadRadius: 0, offset: Offset(0, 5))];
  static List<BoxShadow> surfaceShadow = [const BoxShadow(color: kShadowLightBlue, blurRadius: 5, spreadRadius: 0, offset: Offset(0, 2))];
  static List<BoxShadow> castShadow = [const BoxShadow(color: kShadowSoft, blurRadius: 6.43, spreadRadius: 0, offset: Offset(-3.21, 6.43))];
  static List<BoxShadow> charShadow = [
    const BoxShadow(color: kChartShadowMedium, blurRadius: 6.25, spreadRadius: 0, offset: Offset(0, 1.85)),
    const BoxShadow(color: kChartShadowSubtle, blurRadius: 1.75, spreadRadius: 0, offset: Offset(0, 05)),
  ];
}
