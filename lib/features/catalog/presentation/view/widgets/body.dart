part of '../view.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        return CustomScrollView(
          key: const PageStorageKey<String>('categories-scroll-view'),
          slivers: [
            const _CategoriesSliverAppBar(),
            switch (state) {
              CategoriesInitial() || CategoriesLoading() => const _Loading(),
              CategoriesSuccess(:final categories) => _CategoriesList(categories: categories),
              CategoriesEmpty() => const _Empty(),
              CategoriesError(:final message) => _Error(message: message),
            },
          ],
        );
      },
    );
  }
}
