part of '../view.dart';

class _ProductAppBar extends StatefulWidget {
  const _ProductAppBar({required this.product, required this.images});

  final Product product;
  final List<String> images;

  @override
  State<_ProductAppBar> createState() => _ProductAppBarState();
}

class _ProductAppBarState extends State<_ProductAppBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final expandedHeight = 400.h;
    final collapseRange = expandedHeight - kToolbarHeight;
    final overlayForeground = colorScheme.brightness == Brightness.dark ? colorScheme.onSurface : colorScheme.onPrimary;
    final collapsedForeground = colorScheme.onSurface;
    final collapsedBackground = context.theme.scaffoldBackgroundColor;
    final collapsedOverlayStyle = colorScheme.brightness == Brightness.dark ? AppConstants.statusBarOnDarkBackground : AppConstants.statusBarOnLightBackground;

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final collapseProgress = collapseRange <= 0 ? 1.0 : (constraints.scrollOffset / collapseRange).clamp(0.0, 1.0).toDouble();
        final transitionProgress = Curves.easeInOut.transform(collapseProgress);
        final maximumTransitionRadius = 28.r;
        final edgeDistanceToPinnedAppBar = collapseRange <= 0 ? 0.0 : (collapseRange - constraints.scrollOffset).clamp(0.0, collapseRange).toDouble();
        final edgeFlattenProgress = (1 - (edgeDistanceToPinnedAppBar / maximumTransitionRadius)).clamp(0.0, 1.0).toDouble();
        final transitionRadius = maximumTransitionRadius * (1 - edgeFlattenProgress);
        final foregroundColor = Color.lerp(overlayForeground, collapsedForeground, transitionProgress)!;
        final statusBarStyle = collapseProgress < 0.5 ? AppConstants.statusBarOnDarkBackground : collapsedOverlayStyle;

        return SliverAppBar(
          pinned: true,
          expandedHeight: expandedHeight,
          automaticallyImplyLeading: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: collapsedBackground,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: statusBarStyle.copyWith(statusBarColor: Colors.transparent),
          leadingWidth: 64.w,
          leading: Padding(
            padding: EdgeInsetsDirectional.only(start: 12.w),
            child: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(Icons.arrow_back_rounded, color: foregroundColor, size: 28.r),
            ),
          ),
          titleSpacing: 0,
          title: Opacity(
            opacity: transitionProgress,
            child: Text(
              widget.product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleLarge?.copyWith(color: foregroundColor),
            ),
          ),
          actions: [
            CartButton(color: foregroundColor),
            ThemeToggleButton(color: foregroundColor),
            SizedBox(width: 12.w),
          ],
          flexibleSpace: Stack(
            fit: StackFit.expand,
            children: [
              FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      itemCount: widget.images.length,
                      onPageChanged: (index) => setState(() => _currentIndex = index),
                      itemBuilder: (context, index) {
                        final image = LayoutBuilder(
                          builder: (context, constraints) {
                            return NetworkImageWidget(
                              image: widget.images[index],
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              fit: BoxFit.cover,
                              radius: 0,
                              bgColor: colorScheme.surfaceContainer,
                            );
                          },
                        );

                        if (index != 0) return image;
                        return ProductImageHero(productId: widget.product.id, child: image);
                      },
                    ),
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [colorScheme.scrim.withValues(alpha: 0.42), Colors.transparent, colorScheme.scrim.withValues(alpha: 0.18)],
                            stops: const [0, 0.42, 1],
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: ColoredBox(color: collapsedBackground.withValues(alpha: transitionProgress)),
                    ),
                    if (widget.images.length > 1)
                      Positioned(
                        right: 0,
                        bottom: 42.h,
                        left: 0,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 1 - transitionProgress,
                            child: Center(
                              child: _GalleryIndicator(itemCount: widget.images.length, currentIndex: _currentIndex, foregroundColor: overlayForeground),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: -1,
                left: 0,
                height: 29.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: collapsedBackground,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(transitionRadius)),
                    boxShadow: ShadowManager.cardShadow(Color.lerp(colorScheme.shadow, Colors.transparent, edgeFlattenProgress)!),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GalleryIndicator extends StatelessWidget {
  const _GalleryIndicator({required this.itemCount, required this.currentIndex, required this.foregroundColor});

  final int itemCount;
  final int currentIndex;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(itemCount, (index) {
        final selected = index == currentIndex;
        return AnimatedContainer(
          duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: selected ? 22.w : 8.r,
          height: 8.r,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(color: selected ? foregroundColor : foregroundColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(999.r)),
        );
      }),
    );
  }
}
