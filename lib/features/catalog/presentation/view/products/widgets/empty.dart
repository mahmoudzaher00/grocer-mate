part of '../view.dart';

class _Empty extends StatelessWidget {
  const _Empty({required this.hasActiveFilters, required this.onClear});

  final bool hasActiveFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyStateWidget(
        title: hasActiveFilters ? 'No matching products' : 'No products yet',
        message: hasActiveFilters ? 'Try another search or clear the active filters.' : 'There are no products available yet.',
        icon: hasActiveFilters ? Icons.search_off_rounded : Icons.inventory_2_outlined,
        actionLabel: hasActiveFilters ? 'Clear all' : null,
        onAction: hasActiveFilters ? onClear : null,
      ),
    );
  }
}
