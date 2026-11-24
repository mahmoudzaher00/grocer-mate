part of '../view.dart';

class _ProductControls extends StatelessWidget {
  const _ProductControls({required this.filters, required this.searchController, required this.onClear});

  final ProductsFilters filters;
  final TextEditingController searchController;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ColoredBox(
        color: context.theme.scaffoldBackgroundColor,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductSearchField(controller: searchController),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: _FilterButton(label: filters.categoryLabel, isActive: filters.categoryId != null, onPressed: filters.categories.isEmpty ? null : () => _openCategoryFilter(context)),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: _FilterButton(label: filters.brandLabel, isActive: filters.brand != null, onPressed: filters.brands.isEmpty ? null : () => _openBrandFilter(context)),
                        ),
                      ],
                    ),
                  ),
                  if (filters.hasActiveFilters) ...[SizedBox(width: 4.w), TextButton(onPressed: onClear, child: const Text('Clear'))],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCategoryFilter(BuildContext context) async {
    final selection = await _showFilterSheet(context, title: 'Choose category', selectedValue: filters.categoryId, options: filters.categoryOptions);
    if (!context.mounted || selection == null) return;

    context.read<ProductsBloc>().add(ProductsCategoryChanged(selection.value));
  }

  Future<void> _openBrandFilter(BuildContext context) async {
    final selection = await _showFilterSheet(context, title: 'Choose brand', selectedValue: filters.brand, options: filters.brandOptions);
    if (!context.mounted || selection == null) return;

    context.read<ProductsBloc>().add(ProductsBrandChanged(selection.value));
  }

  Future<ProductFilterOption?> _showFilterSheet(BuildContext context, {required String title, required String? selectedValue, required List<ProductFilterOption> options}) {
    return showCustomBottomSheet<ProductFilterOption>(
      context: context,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      child: _FilterOptionsSheet(title: title, selectedValue: selectedValue, options: options),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.label, required this.isActive, required this.onPressed});

  final String label;
  final bool isActive;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
        backgroundColor: isActive ? colorScheme.primary.withValues(alpha: 0.06) : colorScheme.surface,
        side: BorderSide(color: isActive ? colorScheme.primary : colorScheme.outlineVariant),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999.r)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
          SizedBox(width: 2.w),
          Icon(Icons.arrow_drop_down_rounded, size: 18.r),
        ],
      ),
    );
  }
}
