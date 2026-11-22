part of '../view.dart';

class _CategoriesList extends StatelessWidget {
  const _CategoriesList({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 24.h),
      sliver: SliverList.separated(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: _CategoryCard(
                category: category,
                onTap: () => Navigator.of(context).pushNamed(productsRoute, arguments: category),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 14.h),
      ),
    );
  }
}
