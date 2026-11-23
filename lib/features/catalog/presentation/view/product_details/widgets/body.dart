part of '../view.dart';

class _Body extends StatelessWidget {
  const _Body({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listenWhen: (previous, current) => previous is ConnectivityOffline && current is ConnectivityOnline,
      listener: (context, state) {
        if (context.read<ProductDetailsBloc>().state is ProductDetailsError) {
          context.read<ProductDetailsBloc>().add(ProductDetailsRequested(product.id));
        }
      },
      child: BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
        builder: (context, state) {
          final loadedDetails = switch (state) {
            ProductDetailsSuccess(:final productDetails) => productDetails,
            _ => null,
          };
          final displayedProduct = loadedDetails?.product ?? product;
          final images = loadedDetails?.images ?? <String>[product.imageUrl];

          return CustomScrollView(
            slivers: [
              _ProductAppBar(product: displayedProduct, images: images),
              switch (state) {
                ProductDetailsSuccess(:final productDetails) => _ProductInfo(productDetails: productDetails),
                ProductDetailsError(:final message) => _Error(product: product, message: message),
                ProductDetailsInitial() || ProductDetailsLoading() => _Loading(product: product),
              },
            ],
          );
        },
      ),
    );
  }
}
