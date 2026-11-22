import 'package:material_ui/material_ui.dart';

import '../../resources/color_manager.dart';

class PopupMenuButtonWidget<T> extends StatelessWidget {
  const PopupMenuButtonWidget({
    required this.child,
    required this.menuItems,
    required this.onSelected,
    super.key,
    this.backgroundColor,
    this.offset,
    this.showPopupMenuShape = true,
    this.constraints,
    this.enabled = true,
    this.tooltip,
  });

  final Widget child;
  final List<PopupMenuEntry<T>> menuItems;
  final ValueChanged<T> onSelected;
  final Color? backgroundColor;
  final Offset? offset;
  final bool showPopupMenuShape;
  final BoxConstraints? constraints;
  final bool enabled;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      enabled: enabled,
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: (context) => menuItems,
      color: backgroundColor ?? kWhite,
      surfaceTintColor: backgroundColor ?? kWhite,
      offset: offset ?? const Offset(0, 40),
      constraints: constraints,
      menuPadding: EdgeInsets.only(top: showPopupMenuShape ? 20 : 0, bottom: 10),
      shape: showPopupMenuShape
          ? const CustomPopupMenuShape(radius: 16, arrowStartPadding: 20)
          : RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class CustomPopupMenuShape extends ShapeBorder {
  const CustomPopupMenuShape({
    this.radius = 14,
    this.arrowWidth = 18,
    this.arrowHeight = 10,
    this.arrowRadius = 4,
    this.arrowStartPadding = 20,
  });

  final double radius;
  final double arrowWidth;
  final double arrowHeight;
  final double arrowRadius;
  final double arrowStartPadding;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(top: arrowHeight);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final isRTL = textDirection == TextDirection.rtl;

    final body = Rect.fromLTWH(
      rect.left,
      rect.top + arrowHeight,
      rect.width,
      rect.height - arrowHeight,
    );

    final safeRadius = radius.clamp(0.0, body.width / 2).toDouble();
    final halfArrow = (arrowWidth / 2).clamp(0.0, body.width / 2).toDouble();

    final arrowCenterX = isRTL
        ? body.left + arrowStartPadding
        : body.right - arrowStartPadding;

    final minX = body.left + safeRadius;
    final maxX = body.right - safeRadius;

    final safeArrowCenterX = minX <= maxX
        ? arrowCenterX.clamp(minX, maxX).toDouble()
        : body.center.dx;

    final leftBase = safeArrowCenterX - halfArrow;
    final rightBase = safeArrowCenterX + halfArrow;

    final path = Path()
      ..moveTo(body.left + safeRadius, body.top)
      ..lineTo(leftBase, body.top)
      ..quadraticBezierTo(
        safeArrowCenterX - arrowRadius,
        body.top,
        safeArrowCenterX,
        body.top - arrowHeight,
      )
      ..quadraticBezierTo(
        safeArrowCenterX + arrowRadius,
        body.top,
        rightBase,
        body.top,
      )
      ..lineTo(body.right - safeRadius, body.top)
      ..arcToPoint(
        Offset(body.right, body.top + safeRadius),
        radius: Radius.circular(safeRadius),
      )
      ..lineTo(body.right, body.bottom - safeRadius)
      ..arcToPoint(
        Offset(body.right - safeRadius, body.bottom),
        radius: Radius.circular(safeRadius),
      )
      ..lineTo(body.left + safeRadius, body.bottom)
      ..arcToPoint(
        Offset(body.left, body.bottom - safeRadius),
        radius: Radius.circular(safeRadius),
      )
      ..lineTo(body.left, body.top + safeRadius)
      ..arcToPoint(
        Offset(body.left + safeRadius, body.top),
        radius: Radius.circular(safeRadius),
      )
      ..close();

    return path;
  }
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
