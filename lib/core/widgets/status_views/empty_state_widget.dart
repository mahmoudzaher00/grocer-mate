import '../../utils/extensions/context_extensions.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../resources/asset_manager.dart';
import '../../resources/color_manager.dart';
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
    this.titleText,
    this.contentText,
    this.svgHeight,
    this.btnText,
    this.onPressed,
    this.titleStyle,
    this.contentStyle,
    this.svgColor,
    super.key,
  });
  final String? svgAsset;
  final Color? svgColor;
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

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(svgAsset ??' SvgAssets.emptyTasks', height: svgHeight,colorFilter: svgColor!=null?ColorFilter.mode(svgColor!, BlendMode.srcIn) : null,),
        SizedBox(height: 8.h),
        Text(
          titleText ?? '-',
          style: titleStyle??context.textTheme.titleLarge?.copyWith(
            fontSize: 24.sp,
            color: kPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          contentText ?? '',
          style: contentStyle??context.textTheme.bodyLarge?.copyWith(color: kGrey6C),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
        if (showButton)
          ElevatedButtonWidget(
            onPressed: onPressed,
            // width: context.width,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            text: btnText ?? 'Try Again',
            textSize: 14.sp,
            fontWeight: FontWeight.w500,
            radius: 12,
            svgAsset: 'SvgAssets.icPlus',
            svgColor: btnTxtColor ?? kWhite,
            textColor: btnTxtColor ?? kWhite,
            backgroundColor: btnBgColor ?? kPrimary,
          ),
      ],
    );
    return SizedBox(
      width: context.width,
      height: height,
      child: useScrollView ? SingleChildScrollView(child: content) : content,
    );
  }
}
