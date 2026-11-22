part of '../view.dart';

class _ProductsList extends StatelessWidget {
  const _ProductsList({required this.products, required this.hasNextPage, this.isLoadingNextPage = false, this.pageErrorMessage});

  final List<Product> products;
  final bool hasNextPage;
  final bool isLoadingNextPage;
  final String? pageErrorMessage;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical && notification.metrics.extentAfter <= 320.h) {
          context.read<ProductsBloc>().add(const ProductsNextPageRequested());
        }
        return false;
      },
      child: ListView.builder(
        key: const PageStorageKey<String>('products-list'),
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 24.h),
        itemCount: products.length + 1,
        itemBuilder: (context, index) {
          if (index == products.length) {
            return _PaginationFooter(hasNextPage: hasNextPage, isLoading: isLoadingNextPage, errorMessage: pageErrorMessage);
          }

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: _ProductCard(product: products[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
