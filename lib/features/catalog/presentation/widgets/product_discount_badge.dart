import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

class ProductDiscountBadge extends StatelessWidget {
  const ProductDiscountBadge({required this.percentage, super.key});

  final int percentage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(999.r)),
      child: Text('-$percentage%', style: context.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer)),
    );
  }
}
