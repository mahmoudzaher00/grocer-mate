import 'package:flutter_svg/svg.dart';
import '../../resources/asset_manager.dart';
import '../../resources/color_manager.dart';
import '../../utils/extensions/context_extensions.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../buttons/elevated_button.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({required this.message, this.topHeight = 60, this.onRetry, this.svgHeight, this.showBorder = true, super.key});

  final String message;
  final VoidCallback? onRetry;
  final double? svgHeight;
  final bool showBorder;
  final double topHeight;

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsetsDirectional.only(start: 24.w, end: 24.w, bottom: 30.h),
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      decoration: showBorder
          ? BoxDecoration(
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: topHeight.h),
          SvgPicture.asset('SvgAssets.emptyTasks', height: svgHeight),
          SizedBox(height: 8.h),
          Text(
            'Something went wrong!',
            style: context.textTheme.titleLarge?.copyWith(fontSize: 24.sp, color: kPrimary),
          ),
          Text(
            message,
            style: context.textTheme.bodyLarge?.copyWith(color: kGrey6C),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          if (onRetry != null)
            ElevatedButtonWidget(
              onPressed: onRetry,
              // width: context.width,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              text:'Try Again',
              textSize: 14.sp,
              fontWeight: FontWeight.w500,
              radius: 12,
              svgAsset:' SvgAssets.icRefresh',

              backgroundColor: kPrimary,
            ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }


}
