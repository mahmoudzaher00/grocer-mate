part of '../view.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listenWhen: (previous, current) => previous is ConnectivityOffline && current is ConnectivityOnline,
      listener: (context, state) {
        final productsBloc = context.read<ProductsBloc>();
        if (productsBloc.state is ProductsPageError) {
          productsBloc.add(const ProductsPageRetried());
        } else if (productsBloc.state is ProductsError) {
          productsBloc.add(const ProductsRetried());
        }
      },
      child: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          return _buildScrollView(
            context,
            filters: state.filters,
            contentSliver: switch (state) {
              ProductsInitial() || ProductsLoading() => const _Loading(),
              ProductsSuccess(:final products, :final hasNextPage) => _ProductsList(products: products, showEndMessage: !hasNextPage),
              ProductsPageError(:final products) => _ProductsList(products: products),
              ProductsEmpty() => _Empty(hasActiveFilters: state.filters.hasActiveFilters),
              ProductsError(:final message) => _Error(message: message),
            },
          );
        },
      ),
    );
  }

  Widget _buildScrollView(BuildContext context, {required ProductsFilters filters, required Widget contentSliver}) {
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
          const _ProductsSliverAppBar(title: 'Products'),
          _ProductControls(filters: filters),
          contentSliver,
          const _PaginationFooter(),
        ],
      ),
    );
  }
}
