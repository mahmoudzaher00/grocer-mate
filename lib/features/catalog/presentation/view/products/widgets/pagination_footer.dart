part of '../view.dart';

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        final content = switch (state) {
          ProductsSuccess(isLoadingNextPage: true) => const Skeletonizer(child: _ProductLoadingCard()),
          ProductsPageError(:final message) => _PaginationError(message: message),
          _ => null,
        };

        if (content == null) {
          if (state case ProductsSuccess(hasNextPage: true)) {
            return SliverToBoxAdapter(child: SizedBox(height: 12.h));
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverPadding(
          padding: EdgeInsetsDirectional.fromSTEB(16.w, 0, 16.w, 24.h),
          sliver: SliverToBoxAdapter(child: content),
        );
      },
    );
  }
}

class _PaginationError extends StatelessWidget {
  const _PaginationError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: colorScheme.errorContainer, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
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
}

class _PaginationEndMessage extends StatelessWidget {
  const _PaginationEndMessage();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            children: [
              Expanded(child: Divider(color: colorScheme.outlineVariant)),
              SizedBox(width: 10.w),
              Icon(Icons.check_circle_outline_rounded, size: 18.r, color: colorScheme.secondary),
              SizedBox(width: 6.w),
              Text("You're all caught up", style: context.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.68))),
              SizedBox(width: 10.w),
              Expanded(child: Divider(color: colorScheme.outlineVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
