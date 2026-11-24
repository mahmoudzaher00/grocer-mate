part of '../view.dart';

class _SlidingLogo extends StatelessWidget {
  const _SlidingLogo({required this.opacity, required this.scale});

  final Animation<double> opacity;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: ScaleTransition(scale: scale, child: const _BrandMark()),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(color: kWhite, shape: BoxShape.circle, boxShadow: AppShadows.brandMarkShadow),
      padding: const EdgeInsets.all(10),
      child: ClipOval(child: SvgPicture.asset(SvgAssets.logo, fit: BoxFit.cover)),
    );
  }
}
