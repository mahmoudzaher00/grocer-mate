import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../utils/extensions/context_extensions.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({required this.message, this.onRetry, this.title = 'Something went wrong', super.key});

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: colorScheme.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20.r)),
              child: Icon(Icons.error_outline_rounded, size: 32.r, color: colorScheme.error),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(color: colorScheme.error, fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.68)),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              FilledButton.icon(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  minimumSize: Size(0, 48.h),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  textStyle: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                icon: Icon(Icons.refresh_rounded, size: 20.r),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
