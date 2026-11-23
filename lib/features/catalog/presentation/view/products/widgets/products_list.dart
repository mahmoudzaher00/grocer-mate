part of '../view.dart';

class _ProductsList extends StatelessWidget {
  const _ProductsList({required this.products, this.showEndMessage = false});

  final List<Product> products;
  final bool showEndMessage;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 0),
      sliver: SliverList.builder(
        itemCount: products.length + (showEndMessage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == products.length) {
            return const _PaginationEndMessage();
          }

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: _ProductCard(
                  product: products[index],
                  onTap: () => Navigator.of(context).pushNamed(productDetailsRoute, arguments: products[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
