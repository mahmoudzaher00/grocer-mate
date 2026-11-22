import 'package:flutter_svg/svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../resources/color_manager.dart';

class ElevatedButtonWidget extends StatelessWidget {
  const ElevatedButtonWidget({
    super.key,
    this.onPressed,
    this.child,
    this.text,
    this.textColor,
    this.textSize,
    this.fontWeight,
    this.width,
    this.height = 50.0,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.surfaceTintColor,
    this.shadowColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.radius,
    this.isGradient = false,
    this.gradient,
    this.circleShape = false,
    this.isDisabled = false,
    this.isLoading = false,
    this.loadingColor,
    this.loadingSize,
    this.svgAsset,
    this.svgColor,
    this.btnStyle,
  });

  // Size / spacing
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  // Content
  final VoidCallback? onPressed;
  final Widget? child;

  // Text
  final String? text;
  final Color? textColor;
  final double? textSize;
  final FontWeight? fontWeight;

  // Icon (SVG)
  final String? svgAsset;
  final Color? svgColor;

  // Visuals
  final double? elevation;
  final Color? backgroundColor;
  final Color? surfaceTintColor;
  final Color? shadowColor;
  final Color? foregroundColor;

  // Border / shape
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadiusGeometry? borderRadius;
  final double? radius;
  final bool circleShape;

  // Gradient
  final bool isGradient;
  final Gradient? gradient;

  // State
  final bool isDisabled;
  final bool isLoading;

  // Loading
  final Color? loadingColor;
  final double? loadingSize;

  // Overrides
  final ButtonStyle? btnStyle;

  bool get _hasIcon => svgAsset != null;

  VoidCallback? get _effectiveOnPressed {
    if (isDisabled || isLoading) return null;
    return onPressed;
  }

  BorderRadiusGeometry get _effectiveBorderRadius => borderRadius ?? BorderRadius.circular(radius ?? 8);

  ButtonStyle _buildStyle(BorderRadiusGeometry br) {
    final Color resolvedBg = isGradient ? Colors.transparent : (backgroundColor ?? kPrimary);

    return btnStyle ??
        ElevatedButton.styleFrom(
          backgroundColor: resolvedBg,
          surfaceTintColor: surfaceTintColor ?? kTransparent,
          shadowColor: shadowColor ?? kTransparent,
          foregroundColor: foregroundColor ?? kPrimaryDark.withValues(alpha: 0.8),
          elevation: elevation ?? 0,
          padding: padding ?? EdgeInsets.zero,
          alignment: Alignment.center,
          shape: circleShape
              ? const CircleBorder()
              : RoundedRectangleBorder(
                  borderRadius: br,
                  side: BorderSide(color: borderColor ?? kTransparent, width: borderWidth ?? 1),
                ),
        );
  }

  Widget _buildLoading() {
    return SizedBox(
      width: loadingSize ?? 24,
      height: loadingSize ?? 24,
      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(loadingColor ?? kWhite), strokeWidth: 2.5),
    );
  }

  Widget _buildLabel(BuildContext context) {
    if (child != null) return child!;

    return Text(
      text ?? '',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: textSize ?? 18.sp, fontWeight: fontWeight ?? FontWeight.w700, color: textColor ?? kWhite),
    );
  }

  Widget _buildIcon() {
    if (!_hasIcon) return const SizedBox.shrink();
    return SvgPicture.asset(svgAsset!, colorFilter: ColorFilter.mode(svgColor ?? kWhite, BlendMode.srcIn));
  }

  @override
  Widget build(BuildContext context) {
    final br = _effectiveBorderRadius;

    final Widget buttonChild = isLoading ? _buildLoading() : _buildLabel(context);

    final buttonStyle = _buildStyle(br);

    final Widget button = _hasIcon && !isLoading
        ? ElevatedButton.icon(onPressed: _effectiveOnPressed, style: buttonStyle, icon: _buildIcon(), label: buttonChild)
        : ElevatedButton(onPressed: _effectiveOnPressed, style: buttonStyle, child: buttonChild);

    return Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.zero,
      decoration: isGradient
          ? BoxDecoration(
              gradient: gradient ?? const LinearGradient(begin: AlignmentDirectional.centerStart, end: AlignmentDirectional.centerEnd, tileMode: TileMode.clamp, colors: [kPrimaryDark, kPrimaryLight]),
              borderRadius: circleShape ? null : br,
              shape: circleShape ? BoxShape.circle : BoxShape.rectangle,
            )
          : null,
      child: button,
    );
  }
}
