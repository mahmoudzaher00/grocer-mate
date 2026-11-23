part of '../view.dart';

class _CartTabBar extends StatelessWidget {
  const _CartTabBar();

  @override
  Widget build(BuildContext context) {
    const tabBar = TabBar(
      tabs: [
        Tab(icon: Icon(Icons.shopping_cart_outlined), text: 'Cart'),
        Tab(icon: Icon(Icons.bookmark_outline_rounded), text: 'Saved'),
      ],
    );

    return SliverPersistentHeader(
      pinned: true,
      delegate: _CartTabBarDelegate(tabBar: tabBar, backgroundColor: context.theme.scaffoldBackgroundColor),
    );
  }
}

class _CartTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _CartTabBarDelegate({required this.tabBar, required this.backgroundColor});

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _CartTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar || backgroundColor != oldDelegate.backgroundColor;
  }
}
