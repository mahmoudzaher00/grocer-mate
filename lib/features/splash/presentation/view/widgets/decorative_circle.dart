part of '../view.dart';

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.alignment, required this.size, required this.color});

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.07)),
      ),
    );
  }
}
