part of '../view.dart';

class _Error extends StatelessWidget {
  const _Error({required this.product, required this.message});

  final Product product;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _ProductDetailsSection(
      child: SizedBox(
        height: 360.h,
        child: ErrorStateWidget(title: 'Product details could not be loaded', message: message, onRetry: () => context.read<ProductDetailsBloc>().add(ProductDetailsRequested(product.id))),
      ),
    );
  }
}
