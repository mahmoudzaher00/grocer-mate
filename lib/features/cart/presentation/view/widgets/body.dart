part of '../view.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listenWhen: (previous, current) => current is CartActionFailure && previous != current,
      listener: (context, state) {
        if (state case CartActionFailure(:final message)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        return switch (state) {
          CartInitial() || CartLoading() => const Center(child: CircularProgressIndicator()),
          CartError(:final message) => ErrorStateWidget(title: 'Your cart could not be loaded', message: message, onRetry: () => context.read<CartBloc>().add(const CartRetried())),
          CartEmpty() => EmptyStateWidget(
            icon: Icons.shopping_cart_outlined,
            title: 'Your cart is empty',
            message: 'Add products to see quantities and totals here.',
            actionLabel: Navigator.of(context).canPop() ? 'Continue shopping' : null,
            onAction: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
          ),
          CartReady() || CartActionFailure() => _CartContent(cart: state.cart!),
        };
      },
    );
  }
}
