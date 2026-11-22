part of '../view.dart';

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(icon: Icons.category_outlined, titleText: 'No categories available.', showButton: false, useScrollView: false);
  }
}
