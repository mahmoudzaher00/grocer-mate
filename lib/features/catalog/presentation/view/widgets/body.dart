part of '../view.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        return switch (state) {
          CategoriesInitial() || CategoriesLoading() => const _Loading(),
          CategoriesSuccess(:final categories) => _CategoriesGrid(categories: categories),
          CategoriesEmpty() => const _Empty(),
          CategoriesError(:final message) => _Error(message: message),
        };
      },
    );
  }
}
