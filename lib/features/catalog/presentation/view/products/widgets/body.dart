part of '../view.dart';

class _Body extends StatelessWidget {
  const _Body({required this.categoryId, required this.categoryName});

  final String categoryId;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        return _buildScrollView(
          context,
          contentSliver: switch (state) {
            ProductsInitial() || ProductsLoading() => const _Loading(),
            ProductsSuccess(:final products, :final hasNextPage) => _ProductsList(products: products, showEndMessage: !hasNextPage),
            ProductsPageError(:final products) => _ProductsList(products: products),
            ProductsEmpty() => const _Empty(),
            ProductsError(:final message) => _Error(categoryId: categoryId, message: message),
          },
        );
      },
    );
  }

  Widget _buildScrollView(BuildContext context, {required Widget contentSliver}) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical && notification.metrics.extentAfter <= 320.h) {
          context.read<ProductsBloc>().add(const ProductsNextPageRequested());
        }
        return false;
      },
      child: CustomScrollView(
        key: const PageStorageKey<String>('products-scroll-view'),
        slivers: [
          _ProductsSliverAppBar(title: categoryName),
          contentSliver,
          const _PaginationFooter(),
        ],
      ),
    );
  }
}
