part of '../view.dart';

class _Loading extends StatelessWidget {
  const _Loading();

  static const _placeholderCount = 7;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.withFormFactor(onMobile: 2, onTablet: 4, onDesktop: 6),
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.18,
        ),
        itemCount: _placeholderCount,
        itemBuilder: (context, index) {
          return _CategoryCardFrame(
            visual: Bone.circle(size: 48.r),
            label: Bone.text(words: 2, style: context.textTheme.titleLarge?.copyWith(fontSize: 15.sp, height: 1.2)),
          );
        },
      ),
    );
  }
}
