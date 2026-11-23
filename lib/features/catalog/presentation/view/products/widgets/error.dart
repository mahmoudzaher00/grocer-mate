part of '../view.dart';

class _Error extends StatelessWidget {
  const _Error({required this.categoryId, required this.message});

  final String categoryId;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorStateWidget(
        title: 'Products could not be loaded',
        message: message,
        onRetry: () {
          context.read<ProductsBloc>().add(ProductsRequested(categoryId));
        },
      ),
    );
  }
}
