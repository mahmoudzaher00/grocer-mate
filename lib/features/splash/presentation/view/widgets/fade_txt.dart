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
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: kGrey600, letterSpacing: 0.2),
      ),
    );
  }
}
