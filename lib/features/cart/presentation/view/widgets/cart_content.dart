part of '../view.dart';

class _CartContent extends StatelessWidget {
  const _CartContent({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey<String>('cart-scroll-view'),
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 24.h),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'}', style: context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.65))),
                SizedBox(height: 12.h),
                for (var index = 0; index < cart.items.length; index++) ...[_CartItemCard(item: cart.items[index], cart: cart), if (index != cart.items.length - 1) SizedBox(height: 12.h)],
                SizedBox(height: 20.h),
                _OrderSummary(cart: cart),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
