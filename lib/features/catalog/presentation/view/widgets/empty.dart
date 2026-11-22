part of '../view.dart';

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final accentColor = colorScheme.secondary;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.r,
                height: 72.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20.r)),
                child: Icon(Icons.grid_view_rounded, size: 28.r, color: accentColor),
              ),
              SizedBox(height: 20.h),
              Text(
                'No categories available',
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge?.copyWith(color: accentColor, fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
