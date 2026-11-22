part of '../view.dart';

class _Body extends StatelessWidget {
  const _Body({required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        return switch (state) {
          ProductsInitial() || ProductsLoading() => const _Loading(),
          ProductsSuccess(:final products, :final hasNextPage, :final isLoadingNextPage) => _ProductsList(products: products, hasNextPage: hasNextPage, isLoadingNextPage: isLoadingNextPage),
          ProductsPageError(:final products, :final message) => _ProductsList(products: products, hasNextPage: true, pageErrorMessage: message),
          ProductsEmpty() => const _Empty(),
          ProductsError(:final message) => _Error(categoryId: categoryId, message: message),
        };
      },
    );
  }
}
