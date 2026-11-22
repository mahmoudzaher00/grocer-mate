part of '../view.dart';

class _SlidingTextGroup extends StatelessWidget {
  const _SlidingTextGroup({required this.opacity, required this.offset});

  final Animation<double> opacity;
  final Animation<Offset> offset;

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.headlineLarge?.copyWith(fontSize: (context.width * 0.1).clamp(34.0, 44.0), letterSpacing: -1.2);

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: offset,
        child: Text.rich(
          TextSpan(
            style: titleStyle?.copyWith(color: kPrimaryDark),
            children: [
              const TextSpan(text: 'Grocer'),
              TextSpan(
                text: 'Mate',
                style: titleStyle?.copyWith(color: kPrimary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
