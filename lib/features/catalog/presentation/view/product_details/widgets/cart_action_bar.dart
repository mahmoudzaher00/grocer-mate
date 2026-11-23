part of '../view.dart';

class _ProductCartBar extends StatelessWidget {
  const _ProductCartBar({required this.fallbackProduct});

  final Product fallbackProduct;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
      buildWhen: (previous, current) => current is ProductDetailsSuccess,
      builder: (context, state) {
        final product = switch (state) {
          ProductDetailsSuccess(:final productDetails) => productDetails.product,
          _ => fallbackProduct,
        };
        return _CartActionBar(key: ValueKey(product.id), product: product);
      },
    );
  }
}

class _CartActionBar extends StatefulWidget {
  const _CartActionBar({required this.product, super.key});

  final Product product;

  @override
  State<_CartActionBar> createState() => _CartActionBarState();
}

class _CartActionBarState extends State<_CartActionBar> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

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
        final inCartQuantity = state.cart?.quantityFor(widget.product.id) ?? 0;
        final remainingStock = (widget.product.stock - inCartQuantity).clamp(0, widget.product.stock).toInt();
        final effectiveQuantity = remainingStock == 0 ? 1 : _quantity.clamp(1, remainingStock).toInt();
        final isAvailable = !widget.product.isOutOfStock && remainingStock > 0;
        final buttonLabel = widget.product.isOutOfStock
            ? 'Out of stock'
            : remainingStock == 0
            ? 'Max in cart'
            : 'Add to Cart';

        return DecoratedBox(
          decoration: BoxDecoration(color: colorScheme.surface, boxShadow: ShadowManager.bottomNavBarShadow),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 16.w, 12.h),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Row(
                    children: [
                      QuantityStepper(quantity: effectiveQuantity, maximum: isAvailable ? remainingStock : 1, onChanged: (quantity) => setState(() => _quantity = quantity)),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: isAvailable ? () => context.read<CartBloc>().add(CartProductAdded(product: widget.product, quantity: effectiveQuantity)) : null,
                          style: FilledButton.styleFrom(
                            minimumSize: Size(0, 52.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            textStyle: context.textTheme.titleMedium,
                          ),
                          icon: Icon(Icons.add_shopping_cart_rounded, size: 22.r),
                          label: Text(buttonLabel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
