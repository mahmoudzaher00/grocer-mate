part of '../view.dart';

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.hasNextPage, required this.isLoading, this.errorMessage});

  final bool hasNextPage;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Container(
        margin: EdgeInsets.only(top: 4.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(color: colorScheme.errorContainer, borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          children: [
            Text(
              errorMessage!,
              style: context.textTheme.bodyMedium?.copyWith(color: colorScheme.onErrorContainer),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            TextButton.icon(
              onPressed: () => context.read<ProductsBloc>().add(const ProductsPageRetried()),
              style: TextButton.styleFrom(foregroundColor: colorScheme.onErrorContainer),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry page'),
            ),
          ],
        ),
      );
    }

    if (hasNextPage) return SizedBox(height: 48.h);

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Text(
        'You have reached the end.',
        style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
