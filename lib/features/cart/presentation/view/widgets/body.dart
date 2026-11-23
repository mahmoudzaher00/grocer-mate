part of '../view.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listenWhen: (previous, current) => (current is CartActionFailure || current is CartActionNotice) && previous != current,
      listener: (context, state) {
        final message = switch (state) {
          CartActionFailure(:final message) || CartActionNotice(:final message) => message,
          _ => null,
        };
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        return switch (state) {
          CartInitial() || CartLoading() => const Center(child: CircularProgressIndicator()),
          CartError(:final message) => ErrorStateWidget(title: 'Your shopping lists could not be loaded', message: message, onRetry: () => context.read<CartBloc>().add(const CartRetried())),
          CartEmpty() || CartReady() || CartActionFailure() || CartActionNotice() => _ShoppingListsContent(cart: state.cart!),
        };
      },
    );
  }
}

class _ShoppingListsContent extends StatelessWidget {
  const _ShoppingListsContent({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return TabBarView(
      children: [
        cart.isEmpty
            ? EmptyStateWidget(
                icon: Icons.shopping_cart_outlined,
                title: 'Your cart is empty',
                message: 'Add products or move Saved items back to Cart.',
                actionLabel: canPop ? 'Continue shopping' : null,
                onAction: canPop ? () => Navigator.of(context).pop() : null,
              )
            : _CartContent(cart: cart),
        cart.savedItems.isEmpty
            ? const EmptyStateWidget(icon: Icons.bookmark_outline_rounded, title: 'Nothing saved yet', message: 'Move Cart items here to keep them for later.')
            : _SavedContent(cart: cart),
      ],
    );
  }
}
