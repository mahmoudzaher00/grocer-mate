import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static final List<BoxShadow> brandMarkShadow = List<BoxShadow>.unmodifiable([BoxShadow(color: kPrimary.withValues(alpha: 0.16), blurRadius: 36, spreadRadius: 8, offset: const Offset(0, 14))]);

  static List<BoxShadow> cardShadow(Color color) => List<BoxShadow>.unmodifiable([BoxShadow(color: color, blurRadius: 8, offset: const Offset(0, 2))]);

  static const List<BoxShadow> defaultShadow = [BoxShadow(color: kShadowMd, blurRadius: 6, spreadRadius: 0, offset: Offset(0, 3))];
  static const List<BoxShadow> noShadow = [BoxShadow(color: Colors.transparent, blurRadius: 0, spreadRadius: 0, offset: Offset(0, 0))];
  static const List<BoxShadow> checkboxShadow = [BoxShadow(color: kShadowSubtle, blurRadius: 2, spreadRadius: 0, offset: Offset(0, 1))];
  static const List<BoxShadow> bottomNavigationBarShadow = [BoxShadow(color: kShadowSm, blurRadius: 16, spreadRadius: 0, offset: Offset(0, -2))];
  static const List<BoxShadow> elevatedShadow = [BoxShadow(color: kShadowBlue, blurRadius: 10, spreadRadius: 0, offset: Offset(0, 5))];
  static const List<BoxShadow> surfaceShadow = [BoxShadow(color: kShadowLightBlue, blurRadius: 5, spreadRadius: 0, offset: Offset(0, 2))];
  static const List<BoxShadow> castShadow = [BoxShadow(color: kShadowSoft, blurRadius: 6.43, spreadRadius: 0, offset: Offset(-3.21, 6.43))];
  static const List<BoxShadow> chartShadow = [
    BoxShadow(color: kChartShadowMedium, blurRadius: 6.25, spreadRadius: 0, offset: Offset(0, 1.85)),
    BoxShadow(color: kChartShadowSubtle, blurRadius: 1.75, spreadRadius: 0, offset: Offset(0, 05)),
  ];
}
