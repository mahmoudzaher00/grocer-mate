part of '../view.dart';

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = category.visual(context);
    final colorScheme = context.theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline),
        boxShadow: ShadowManager.cardShadow(colorScheme.shadow),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
          minTileHeight: 80.h,
          minLeadingWidth: 48.r,
          horizontalTitleGap: 16.w,
          leading: Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(color: visual.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14.r)),
            alignment: Alignment.center,
            child: Icon(visual.icon, size: 25.r, color: visual.color),
          ),
          title: Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleLarge?.copyWith(fontSize: 17.sp, height: 1.2),
          ),
          trailing: Icon(Icons.chevron_right_rounded, size: 26.r, color: colorScheme.primary),
        ),
      ),
    );
  }
}
