part of '../view.dart';

class _FadeText extends StatelessWidget {
  const _FadeText({required this.opacity});

  final Animation<double> opacity;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: Text(
        'Fresh choices. Simple shopping.',
        textAlign: TextAlign.center,
        style: context.textTheme.bodyLarge?.copyWith(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.68), letterSpacing: 0.2),
      ),
    );
  }
}
