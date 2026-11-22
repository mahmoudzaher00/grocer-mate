part of '../view.dart';

class _Error extends StatelessWidget {
  const _Error({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 44.r, color: kError),
            SizedBox(height: 12.h),
            Text(message, textAlign: TextAlign.center, style: context.textTheme.bodyLarge),
            SizedBox(height: 20.h),
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
    );
  }
}
