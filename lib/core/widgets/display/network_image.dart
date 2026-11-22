import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../resources/shadow_manager.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../resources/asset_manager.dart';
import '../../resources/color_manager.dart';




class NetworkImageWidget extends StatelessWidget {
  const NetworkImageWidget({
    required this.image,
    this.isAvatar=false,
    this.width = 100,
    this.height = 100,
    this.bgColor,
    this.borderWidth = 0,
    this.borderColor,
    this.trBackground = false,
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
    this.effectColor, this.svgAsset,
    super.key,
  });

  final String image;
  final double width;
  final double horizontal;
  final double vertical;
  final double? circlePadding;
  final double height;
  final double borderWidth;
  final bool isShadow;
  final bool isCircular;
  final Color? borderColor;
  final Color? circleBorderColor;
  final Color? bgColor;
  final bool trBackground;
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
  final Function? onTap;
  final bool isAvatar;
  final Color? effectColor;
  final String? svgAsset;



  @override
  Widget build(BuildContext context) {
    final errorImage = BlankImageWidget(
      svgAsset: svgAsset,
      isAvatar: isAvatar,
      height: height,
      width: width,
      fit: errorImageFit??BoxFit.contain,
      onTap: onTap,
      radius: radius,
    );
    if (image.isEmpty) {
      // Provide a default fallback image or handle the case according to your application logic
      return errorImage;
    }

    Widget content;
    if (isAsset) {
      content = isCircular ?
      Container(
        padding: EdgeInsets.all(circlePadding ?? 1),
        decoration: BoxDecoration(
          color: circleColor ??  kWhite,
          border: Border.all(color: circleBorderColor ??  kWhite),
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: radiusCircleAvatar,
          backgroundColor: circleColor ??  kWhite,
          backgroundImage: AssetImage(image),
        ),
      ) :
      Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
          image: DecorationImage(image: AssetImage(image), fit: fit),
        ),
      );
    }
    else if (isNetwork) {
      content = isCircular ?
      image.isEmpty?  errorImage:
      InkWell(
        onTap: onTap == null ? null : () => onTap?.call(),
        borderRadius: borderRadius ?? BorderRadius.circular(radius),
        child: Container(
          padding: EdgeInsets.all(circlePadding ?? 1),
          decoration: BoxDecoration(
            color: circleColor ??  kWhite,
            border: Border.all(
                color: circleBorderColor ??  kWhite,width: 2),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: radiusCircleAvatar,
            backgroundColor: bgColor??kWhite,
            child: CachedNetworkImage(
              imageUrl: image,
              height: height,
              width: width,
              fit: fit,
              placeholder: (context, url) => const SpinKitRipple(
                color: kPrimary,
                size: 50.0,
              ),
              errorWidget: (context, url, error) => errorImage,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: imageProvider, fit: fit),
                ),
              ),
            ),
          ),
        ),
      ) :
      InkWell(
        onTap: ()=>onTap?.call(),
        splashColor: effectColor,
        highlightColor: effectColor,
        hoverColor: effectColor,
        borderRadius: borderRadius ?? BorderRadius.circular(radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(radius),
            border: Border.all(
                color: borderColor ??  kTransparent,width: 2),
          ),
          child: CachedNetworkImage(
            imageUrl: image,
            height: height,
            width: width,
            fit:fit,

            placeholder: (context, url) => const SpinKitRipple(
              color: kPrimary,
              size: 50.0,
            ),
            errorWidget: (context, url, error) => errorImage,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius ?? BorderRadius.circular(radius),
                image: DecorationImage(image: imageProvider, fit: fit),
              ),
            ),
          ),
        ),
      );
    }
    else {
      content = Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
          image: DecorationImage(image: AssetImage(image), fit: fit),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(radius),
        color: bgColor,
        boxShadow:isShadow?ShadowManager.shadow :[],

      ),
      child: Padding(
        padding:
        EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
          child: content,
        ),
      ),
    );
  }
}

class BlankImageWidget extends StatelessWidget {

  const BlankImageWidget({super.key, this.height, this.width, this.fit, this.isAvatar=false, this.isCircular=false, this.svgAsset, this.onTap, this.radius});
  final bool isAvatar;
  final String? svgAsset;
  final double? radius;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool isCircular;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {

    if(isAvatar) {
      return InkWell(
          onTap: ()=>onTap?.call(),
          customBorder: const CircleBorder(),
          child: SvgPicture.asset(svgAsset??'SvgAssets.avatar',  height: height, width: width,));
    } else {
      return InkWell(
        onTap: ()=>onTap?.call(),
        borderRadius:  BorderRadius.circular(radius!),
        child: Center(
        child: Image.asset(
         ' ImageAssets.avatar',
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
        ),
            ),
      );
    }
  }
}
