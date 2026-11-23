part of '../view.dart';

class _CartContent extends StatefulWidget {
  const _CartContent({required this.cart});

  final Cart cart;

  @override
  State<_CartContent> createState() => _CartContentState();
}

class _CartContentState extends State<_CartContent> {
  final Set<String> _selectedIds = <String>{};

  @override
  void didUpdateWidget(covariant _CartContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentIds = widget.cart.items.map((item) => item.product.id).toSet();
    _selectedIds.removeWhere((id) => !currentIds.contains(id));
  }

  void _toggleSelection(String productId, bool selected) {
    setState(() => selected ? _selectedIds.add(productId) : _selectedIds.remove(productId));
  }

  void _moveSelected() {
    context.read<CartBloc>().add(CartItemsMovedToSaved(_selectedIds));
    setState(_selectedIds.clear);
  }

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${widget.cart.itemCount} ${widget.cart.itemCount == 1 ? 'item' : 'items'}',
                        style: context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.65)),
                      ),
                    ),
                    FilledButton.tonalIcon(onPressed: _selectedIds.isEmpty ? null : _moveSelected, icon: const Icon(Icons.bookmark_add_outlined), label: const Text('Save selected')),
                  ],
                ),
                SizedBox(height: 12.h),
                for (var index = 0; index < widget.cart.items.length; index++) ...[
                  _CartItemCard(
                    item: widget.cart.items[index],
                    cart: widget.cart,
                    isSelected: _selectedIds.contains(widget.cart.items[index].product.id),
                    onSelectionChanged: (selected) => _toggleSelection(widget.cart.items[index].product.id, selected),
                    onSaveForLater: () => context.read<CartBloc>().add(CartItemsMovedToSaved([widget.cart.items[index].product.id])),
                  ),
                  if (index != widget.cart.items.length - 1) SizedBox(height: 12.h),
                ],
                SizedBox(height: 20.h),
                _OrderSummary(cart: widget.cart),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
