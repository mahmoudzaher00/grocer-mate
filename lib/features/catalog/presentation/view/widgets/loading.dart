part of '../view.dart';

class _Loading extends StatelessWidget {
  const _Loading();

  static const _placeholderCount = 7;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Skeletonizer.sliver(
      child: SliverPadding(
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 24.h),
        sliver: SliverList.separated(
          itemCount: _placeholderCount,
          itemBuilder: (context, index) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: colorScheme.outlineVariant),
                    boxShadow: AppShadows.cardShadow(colorScheme.shadow),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                      minTileHeight: 80.h,
                      minLeadingWidth: 48.r,
                      horizontalTitleGap: 16.w,
                      leading: Bone.square(size: 48.r, uniRadius: 14.r),
                      title: Bone.text(
                        width: 112.w,
                        style: context.textTheme.titleLarge?.copyWith(fontSize: 17.sp, height: 1.2),
                      ),
                      trailing: Bone.icon(size: 26.r),
                    ),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 14.h),
        ),
      ),
    );
  }
}
