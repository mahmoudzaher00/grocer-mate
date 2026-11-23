part of '../view.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listenWhen: (previous, current) => previous is ConnectivityOffline && current is ConnectivityOnline,
      listener: (context, state) {
        if (context.read<CategoriesBloc>().state is CategoriesError) {
          context.read<CategoriesBloc>().add(const CategoriesRequested());
        }
      },
      child: BlocBuilder<CategoriesBloc, CategoriesState>(
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
      ),
    );
  }
}
