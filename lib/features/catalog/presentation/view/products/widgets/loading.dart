part of '../view.dart';

class _Loading extends StatelessWidget {
  const _Loading();

  static const _placeholderCount = 5;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.sliver(
      child: SliverPadding(
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 24.h),
        sliver: SliverList.separated(
          itemCount: _placeholderCount,
          itemBuilder: (context, index) => const _ProductLoadingCard(),
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
        ),
      ),
    );
  }
}

class _ProductLoadingCard extends StatelessWidget {
  const _ProductLoadingCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: AppShadows.cardShadow(colorScheme.shadow),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone(width: 104.r, height: 112.r, uniRadius: 12.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Bone.text(width: 140.w, style: context.textTheme.titleMedium),
                        ),
                        SizedBox(width: 8.w),
                        Bone(width: 40.w, height: 20.h, uniRadius: 10.r),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Bone.text(width: 72.w, style: context.textTheme.bodySmall),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Bone.text(width: 64.w, style: context.textTheme.titleMedium),
                        SizedBox(width: 8.w),
                        Bone.text(width: 52.w, style: context.textTheme.bodySmall),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Bone(width: 64.w, height: 24.h, uniRadius: 12.r),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
