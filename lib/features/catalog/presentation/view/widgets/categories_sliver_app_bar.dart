part of '../view.dart';

class _CategoriesSliverAppBar extends StatelessWidget {
  const _CategoriesSliverAppBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final brandColor = colorScheme.secondary;

    return SliverAppBar(
      primary: false,
      pinned: false,
      floating: true,
      toolbarHeight: 110.h,
      titleSpacing: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      title: Padding(
        padding: EdgeInsetsDirectional.only(start: 20.w, top: 12.h, end: 12.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: brandColor.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12.r)),
                  child: Text(
                    'G',
                    style: context.textTheme.titleLarge?.copyWith(color: brandColor, fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'GrocerMate',
                    style: context.textTheme.titleLarge?.copyWith(color: brandColor, fontSize: 19.sp),
                  ),
                ),
                const CartButton(),
                const ThemeToggleButton(),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'Categories',
              style: context.textTheme.headlineLarge?.copyWith(color: brandColor, fontSize: 34.sp, height: 1.1),
            ),
          ],
        ),
      ),
    );
  }
}
