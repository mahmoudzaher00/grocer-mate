import 'package:material_ui/material_ui.dart';

class ProductImageHero extends StatelessWidget {
  const ProductImageHero({required this.productId, required this.child, super.key});

  final String productId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'product-image-$productId',
      transitionOnUserGestures: true,
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
