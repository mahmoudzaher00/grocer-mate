part of '../view.dart';

class _Error extends StatelessWidget {
  const _Error({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

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
                decoration: BoxDecoration(color: colorScheme.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20.r)),
                child: Icon(Icons.error_outline_rounded, size: 32.r, color: colorScheme.error),
              ),
              SizedBox(height: 20.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge?.copyWith(color: colorScheme.error, fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24.h),
              FilledButton.icon(
                onPressed: () {
                  context.read<CategoriesBloc>().add(const CategoriesRequested());
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
