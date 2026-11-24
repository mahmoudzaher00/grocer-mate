import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/app_shadows.dart';

class NetworkImageWidget extends StatelessWidget {
  const NetworkImageWidget({
    required this.image,
    this.isAvatar = false,
    this.width = 100,
    this.height = 100,
    this.bgColor,
    this.borderWidth,
    this.borderColor,
    this.fit = BoxFit.fill,
    this.isNetwork = true,
    this.radius = 6,
    this.borderRadius,
    this.isShadow = false,
    this.isCircular = false,
    this.horizontal = 0,
    this.vertical = 0,
    this.radiusCircleAvatar,
    this.isAsset = false,
    this.errorImageHeight,
    this.errorImageWidth,
    this.errorImageFit,
    this.circleBorderColor,
    this.circleColor,
    this.circlePadding,
    this.onTap,
    this.effectColor,
    this.svgAsset,
    this.semanticLabel,
    super.key,
  });

  final String image;
  final double width;
  final double horizontal;
  final double vertical;
  final double? circlePadding;
  final double height;
  final double? borderWidth;
  final bool isShadow;
  final bool isCircular;
  final Color? borderColor;
  final Color? circleBorderColor;
  final Color? bgColor;
  final bool isNetwork;
  final bool isAsset;
  final double radius;
  final double? errorImageHeight;
  final double? errorImageWidth;
  final BoxFit? errorImageFit;
  final double? radiusCircleAvatar;
  final Color? circleColor;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final VoidCallback? onTap;
  final bool isAvatar;
  final Color? effectColor;
  final String? svgAsset;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final resolvedBorderRadius = borderRadius ?? BorderRadius.circular(radius);
    final fallback = _ImageFallback(svgAsset: svgAsset, height: errorImageHeight ?? height, width: errorImageWidth ?? width, fit: errorImageFit ?? BoxFit.contain, isAvatar: isAvatar);
    final imageContent = switch ((image.isEmpty, isAsset || !isNetwork)) {
      (true, _) => fallback,
      (false, true) => _buildAssetImage(context, resolvedBorderRadius),
      (false, false) => _buildNetworkImage(context, fallback, resolvedBorderRadius),
    };
    final borderedContent = isCircular ? imageContent : _addBorder(imageContent, resolvedBorderRadius);
    final tappableContent = _addTapBehavior(borderedContent, resolvedBorderRadius);
    final result = DecoratedBox(
      decoration: BoxDecoration(borderRadius: resolvedBorderRadius, color: bgColor, boxShadow: isShadow ? AppShadows.defaultShadow : const []),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        child: ClipRRect(borderRadius: resolvedBorderRadius, child: tappableContent),
      ),
    );

    final label = semanticLabel?.trim();
    if (label == null || label.isEmpty) return result;

    return Semantics(label: label, image: true, button: onTap != null, onTap: onTap, excludeSemantics: true, child: result);
  }

  Widget _buildAssetImage(BuildContext context, BorderRadius resolvedBorderRadius) {
    if (isCircular) {
      return _CircularImageFrame(
        padding: circlePadding ?? 1,
        color: circleColor,
        borderColor: circleBorderColor,
        borderWidth: borderWidth ?? 1,
        child: CircleAvatar(radius: radiusCircleAvatar, backgroundColor: circleColor ?? Theme.of(context).colorScheme.surface, backgroundImage: AssetImage(image)),
      );
    }

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: resolvedBorderRadius,
        image: DecorationImage(image: AssetImage(image), fit: fit),
      ),
    );
  }

  Widget _buildNetworkImage(BuildContext context, Widget fallback, BorderRadius resolvedBorderRadius) {
    final cachedImage = CachedNetworkImage(
      imageUrl: image,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, _) => _buildLoadingPlaceholder(context),
      errorWidget: (_, _, _) => fallback,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircular ? null : resolvedBorderRadius,
          image: DecorationImage(image: imageProvider, fit: fit),
        ),
      ),
    );

    if (!isCircular) return cachedImage;

    return _CircularImageFrame(
      padding: circlePadding ?? 1,
      color: circleColor,
      borderColor: circleBorderColor,
      borderWidth: borderWidth ?? 2,
      child: CircleAvatar(radius: radiusCircleAvatar, backgroundColor: bgColor ?? Theme.of(context).colorScheme.surface, child: cachedImage),
    );
  }

  Widget _addBorder(Widget child, BorderRadius resolvedBorderRadius) {
    if (borderColor == null && borderWidth == null) return child;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: resolvedBorderRadius,
        border: Border.all(color: borderColor ?? Colors.transparent, width: borderWidth ?? 2),
      ),
      child: child,
    );
  }

  Widget _addTapBehavior(Widget child, BorderRadius resolvedBorderRadius) {
    if (onTap == null) return child;

    final useCircularTapShape = isCircular || isAvatar;
    return InkWell(
      onTap: onTap,
      splashColor: effectColor,
      highlightColor: effectColor,
      hoverColor: effectColor,
      customBorder: useCircularTapShape ? const CircleBorder() : null,
      borderRadius: useCircularTapShape ? null : resolvedBorderRadius,
      child: child,
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SpinKitRipple(color: colorScheme.primary, size: 50);
  }
}

final class _CircularImageFrame extends StatelessWidget {
  const _CircularImageFrame({required this.padding, required this.borderWidth, required this.child, this.color, this.borderColor});

  final double padding;
  final double borderWidth;
  final Widget child;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color ?? colorScheme.surface,
        border: Border.all(color: borderColor ?? colorScheme.surface, width: borderWidth),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}

final class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.height, required this.width, required this.fit, required this.isAvatar, this.svgAsset});

  final double height;
  final double width;
  final BoxFit fit;
  final bool isAvatar;
  final String? svgAsset;

  @override
  Widget build(BuildContext context) {
    final fallback = svgAsset != null
        ? SvgPicture.asset(svgAsset!, height: height, width: width, fit: fit)
        : Icon(isAvatar ? Icons.person_outline_rounded : Icons.image_not_supported_outlined, size: 32, color: Theme.of(context).colorScheme.onSurfaceVariant);

    return SizedBox(
      height: height,
      width: width,
      child: Center(child: fallback),
    );
  }
}
