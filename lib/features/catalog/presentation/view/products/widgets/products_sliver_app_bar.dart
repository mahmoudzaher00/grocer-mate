part of '../view.dart';

class _ProductsSliverAppBar extends StatelessWidget {
  const _ProductsSliverAppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      primary: false,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      title: Text(title),
      actions: const [CartButton(), ThemeToggleButton(), SizedBox(width: 8)],
    );
  }
}
