part of '../view.dart';

class _ProductSearchField extends StatefulWidget {
  const _ProductSearchField({required this.query});

  final String query;

  @override
  State<_ProductSearchField> createState() => _ProductSearchFieldState();
}

class _ProductSearchFieldState extends State<_ProductSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ProductSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query == oldWidget.query || _controller.text == widget.query) return;

    _controller.value = TextEditingValue(
      text: widget.query,
      selection: TextSelection.collapsed(offset: widget.query.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        return TextFormField(
          controller: _controller,
          onChanged: (query) => context.read<ProductsBloc>().add(ProductsSearchChanged(query)),
          textInputAction: TextInputAction.search,
          style: context.textTheme.bodyLarge,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          decoration: InputDecoration(
            hintText: 'Search products',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _controller.clear();
                      context.read<ProductsBloc>().add(const ProductsSearchChanged(''));
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        );
      },
    );
  }
}
