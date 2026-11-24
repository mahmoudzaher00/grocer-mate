part of '../view.dart';

class _ProductSearchField extends StatelessWidget {
  const _ProductSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextFormField(
          controller: controller,
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
                      controller.clear();
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
