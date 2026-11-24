part of '../view.dart';

class _SavedContent extends StatefulWidget {
  const _SavedContent({required this.cart});

  final Cart cart;

  @override
  State<_SavedContent> createState() => _SavedContentState();
}

class _SavedContentState extends State<_SavedContent> {
  final _selection = _ItemSelection();

  @override
  void didUpdateWidget(covariant _SavedContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.cart.savedItems, oldWidget.cart.savedItems)) {
      _selection.retainItems(widget.cart.savedItems);
    }
  }

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  void _moveSelected() {
    context.read<CartBloc>().add(SavedItemsMovedToCart(_selection.selectedIds));
    _selection.clear();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.cart.savedItems;
    return ListView.builder(
      key: const PageStorageKey<String>('saved-scroll-view'),
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 24.h),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        final Widget row;
        if (index == 0) {
          final header = _SelectionHeader(
            countLabel: '${widget.cart.savedItemCount} saved',
            selection: _selection,
            onPressed: _moveSelected,
            icon: Icons.shopping_cart_checkout_rounded,
            actionLabel: 'Move selected',
          );
          row = Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: header,
          );
        } else {
          final item = items[index - 1];
          final id = item.product.id;
          row = Padding(
            padding: EdgeInsets.only(bottom: index == items.length ? 0 : 12.h),
            child: _SavedItemCard(item: item, cart: widget.cart, selectionControl: _selection.checkboxFor(id), onMoveToCart: () => context.read<CartBloc>().add(SavedItemsMovedToCart([id]))),
          );
        }
        return Center(child: SizedBox(width: 760, child: row));
      },
    );
  }
}
