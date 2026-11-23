part of '../view.dart';

class _SavedContent extends StatefulWidget {
  const _SavedContent({required this.cart});

  final Cart cart;

  @override
  State<_SavedContent> createState() => _SavedContentState();
}

class _SavedContentState extends State<_SavedContent> {
  final Set<String> _selectedIds = <String>{};

  @override
  void didUpdateWidget(covariant _SavedContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentIds = widget.cart.savedItems.map((item) => item.product.id).toSet();
    _selectedIds.removeWhere((id) => !currentIds.contains(id));
  }

  void _toggleSelection(String productId, bool selected) {
    setState(() => selected ? _selectedIds.add(productId) : _selectedIds.remove(productId));
  }

  void _moveSelected() {
    context.read<CartBloc>().add(SavedItemsMovedToCart(_selectedIds));
    setState(_selectedIds.clear);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey<String>('saved-scroll-view'),
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
                      child: Text('${widget.cart.savedItemCount} saved', style: context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.65))),
                    ),
                    FilledButton.tonalIcon(onPressed: _selectedIds.isEmpty ? null : _moveSelected, icon: const Icon(Icons.shopping_cart_checkout_rounded), label: const Text('Move selected')),
                  ],
                ),
                SizedBox(height: 12.h),
                for (var index = 0; index < widget.cart.savedItems.length; index++) ...[
                  _SavedItemCard(
                    item: widget.cart.savedItems[index],
                    cart: widget.cart,
                    isSelected: _selectedIds.contains(widget.cart.savedItems[index].product.id),
                    onSelectionChanged: (selected) => _toggleSelection(widget.cart.savedItems[index].product.id, selected),
                    onMoveToCart: () => context.read<CartBloc>().add(SavedItemsMovedToCart([widget.cart.savedItems[index].product.id])),
                  ),
                  if (index != widget.cart.savedItems.length - 1) SizedBox(height: 12.h),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
