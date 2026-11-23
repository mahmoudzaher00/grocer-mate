part of '../../view.dart';

class _FilterOptionsSheet extends StatelessWidget {
  const _FilterOptionsSheet({required this.title, required this.selectedValue, required this.options});

  final String title;
  final String? selectedValue;
  final List<ProductFilterOption> options;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return SizedBox(
      height: context.height * 0.62,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.w, 4.h, 12.w, 16.h),
            child: Row(
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(Icons.tune_rounded, size: 22.r, color: colorScheme.primary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.textTheme.titleLarge?.copyWith(fontSize: 18.sp)),
                      SizedBox(height: 2.h),
                      Text('${options.length} options available', style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton(tooltip: 'Close', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 0, 16.w, 20.h),
              itemCount: options.length,
              separatorBuilder: (_, _) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final option = options[index];

                return _FilterOptionTile(option: option, isSelected: option.value == selectedValue, onTap: () => Navigator.of(context).pop(option));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOptionTile extends StatelessWidget {
  const _FilterOptionTile({required this.option, required this.isSelected, required this.onTap});

  final ProductFilterOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final borderRadius = BorderRadius.circular(14.r);

    return Material(
      color: isSelected ? colorScheme.primary.withValues(alpha: 0.09) : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: isSelected ? colorScheme.primary : colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(color: isSelected ? colorScheme.primary : colorScheme.onSurface),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 24.r,
                height: 24.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.outline),
                ),
                child: isSelected ? Icon(Icons.check_rounded, size: 16.r, color: colorScheme.onPrimary) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
