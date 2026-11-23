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
    final colorScheme = context.theme.colorScheme;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        return BaseTextField(
          controller: _controller,
          onChangedFunction: (query) => context.read<ProductsBloc>().add(ProductsSearchChanged(query)),
          textInputAction: TextInputAction.search,
          inputTextStyle: context.textTheme.bodyLarge,
          hintText: 'Search products',
          hintStyle: context.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.55)),
          prefixIconWidget: Icon(Icons.search_rounded, color: colorScheme.onSurface.withValues(alpha: 0.65)),
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
          filledColorTextFiled: true,
          fillColorTextFiled: colorScheme.surface,
          contentHorizontalPadding: 14.w,
          contentVerticalPadding: 12.h,
          enabledBorderColor: colorScheme.outline,
          focusedBorderColor: colorScheme.primary,
          enabledBorderRadius: 14.r,
          focusedBorderRadius: 14.r,
          cursorColor: colorScheme.primary,
          // closeKeyboardOnTapOutside: false,
        );
      },
    );
  }
}
