part of '../view.dart';

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 56.r, color: colorScheme.primary),
            SizedBox(height: 16.h),
            Text('No products yet', style: context.textTheme.titleLarge, textAlign: TextAlign.center),
            SizedBox(height: 8.h),
            Text(
              'There are no products available in this category.',
              style: context.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.68)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
