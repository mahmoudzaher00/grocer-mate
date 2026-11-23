import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../utils/extensions/context_extensions.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({required this.title, this.icon = Icons.grid_view_rounded, this.message, this.accentColor, this.actionLabel, this.onAction, super.key});

  final String title;
  final IconData icon;
  final String? message;
  final Color? accentColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final resolvedAccentColor = accentColor ?? colorScheme.secondary;

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
              decoration: BoxDecoration(color: resolvedAccentColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20.r)),
              child: Icon(icon, size: 28.r, color: resolvedAccentColor),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(color: resolvedAccentColor, fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            if (message != null && message!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.68)),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[SizedBox(height: 24.h), FilledButton.icon(onPressed: onAction, icon: const Icon(Icons.restart_alt_rounded), label: Text(actionLabel!))],
          ],
        ),
      ),
    );
  }
}
