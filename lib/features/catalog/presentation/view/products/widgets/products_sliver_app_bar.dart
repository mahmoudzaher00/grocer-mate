part of '../view.dart';

class _ProductsSliverAppBar extends StatelessWidget {
  const _ProductsSliverAppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return SliverAppBar(
      primary: false,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: Text(title),
      actions: const [ThemeToggleButton(), SizedBox(width: 8)],
    );
  }
}
