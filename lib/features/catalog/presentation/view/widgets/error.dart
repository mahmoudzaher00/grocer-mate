part of '../view.dart';

class _Error extends StatelessWidget {
  const _Error({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorStateWidget(
        message: message,
        onRetry: () {
          context.read<CategoriesBloc>().add(const CategoriesRequested());
        },
      ),
    );
  }
}
