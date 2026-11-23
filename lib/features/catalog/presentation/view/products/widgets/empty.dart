part of '../view.dart';

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyStateWidget(title: 'No products yet', message: 'There are no products available in this category.', icon: Icons.inventory_2_outlined),
    );
  }
}
