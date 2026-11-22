part of '../view.dart';

class _Error extends StatelessWidget {
  const _Error({required this.categoryId, required this.message});

  final String categoryId;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 56.r, color: colorScheme.error),
            SizedBox(height: 16.h),
            Text('Products could not be loaded', style: context.textTheme.titleLarge, textAlign: TextAlign.center),
            SizedBox(height: 8.h),
            Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.68)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            FilledButton.icon(onPressed: () => context.read<ProductsBloc>().add(ProductsRequested(categoryId)), icon: const Icon(Icons.refresh_rounded), label: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
