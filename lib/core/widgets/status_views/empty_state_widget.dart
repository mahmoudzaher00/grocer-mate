import '../../utils/extensions/context_extensions.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../buttons/elevated_button.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    this.btnTxtColor,
    this.btnBgColor,
    this.height,
    this.hasIconBtn = false,
    this.showButton = true,
    this.useScrollView = true,
    this.svgAsset,
    this.icon,
    this.titleText,
    this.contentText,
    this.svgHeight,
    this.iconSize,
    this.btnText,
    this.onPressed,
    this.titleStyle,
    this.contentStyle,
    this.svgColor,
    this.iconColor,
    super.key,
  });
  final String? svgAsset;
  final Color? svgColor;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final String? btnText;
  final String? titleText;
  final TextStyle? titleStyle;
  final String? contentText;
  final TextStyle? contentStyle;
  final double? svgHeight;
  final double? height;
  final VoidCallback? onPressed;
  final bool useScrollView;
  final bool hasIconBtn;
  final bool showButton;
  final Color? btnTxtColor;
  final Color? btnBgColor;

  Widget? _buildIllustration(BuildContext context) {
    if (svgAsset != null) {
      return SvgPicture.asset(svgAsset!, height: svgHeight, colorFilter: svgColor != null ? ColorFilter.mode(svgColor!, BlendMode.srcIn) : null);
    }

    if (icon != null) {
      return Icon(icon, size: iconSize ?? 64.r, color: iconColor ?? context.theme.colorScheme.primary);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final illustration = _buildIllustration(context);

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (illustration != null) ...[illustration, SizedBox(height: 16.h)],
        Text(
          titleText ?? '-',
          style: titleStyle ?? context.textTheme.titleLarge?.copyWith(fontSize: 24.sp, color: colorScheme.primary),
        ),
        if (contentText != null && contentText!.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            contentText!,
            style: contentStyle ?? context.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.68)),
            textAlign: TextAlign.center,
          ),
        ],
        if (showButton) ...[
          SizedBox(height: 24.h),
          ElevatedButtonWidget(
            onPressed: onPressed,
            // width: context.width,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            text: btnText ?? 'Try Again',
            textSize: 14.sp,
            fontWeight: FontWeight.w500,
            radius: 12,
            svgAsset: 'SvgAssets.icPlus',
            svgColor: btnTxtColor ?? colorScheme.onPrimary,
            textColor: btnTxtColor ?? colorScheme.onPrimary,
            backgroundColor: btnBgColor ?? colorScheme.primary,
          ),
        ],
      ],
    );
    return SizedBox(
      width: context.width,
      height: height,
      child: useScrollView ? SingleChildScrollView(child: content) : content,
    );
  }
}
