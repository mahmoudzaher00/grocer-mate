part of '../view.dart';

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(category.iconName);
    final visualColor = _resolveVisualColor(context, visual.color);

    return _CategoryCardFrame(
      onTap: onTap,
      visual: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(color: visualColor.withValues(alpha: 0.12), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(visual.icon, size: 24.r, color: visualColor),
      ),
      label: Text(
        category.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: context.textTheme.titleLarge?.copyWith(fontSize: 15.sp, height: 1.2),
      ),
    );
  }

  _CategoryVisual _visualFor(String iconName) {
    return switch (iconName) {
      'produce' => const _CategoryVisual(icon: Icons.eco_rounded, color: kSuccess),
      'dairy' => const _CategoryVisual(icon: Icons.egg_alt_rounded, color: kPrimary),
      'bakery' => const _CategoryVisual(icon: Icons.bakery_dining_rounded, color: kWarning),
      'beverages' => const _CategoryVisual(icon: Icons.local_drink_rounded, color: kPrimaryDark),
      'pantry' => const _CategoryVisual(icon: Icons.kitchen_rounded, color: kOrange),
      'household' => const _CategoryVisual(icon: Icons.cleaning_services_rounded, color: kGrey600),
      'personalCare' => const _CategoryVisual(icon: Icons.sanitizer_rounded, color: kPurple),
      _ => const _CategoryVisual(icon: Icons.category_rounded, color: kPrimary),
    };
  }

  Color _resolveVisualColor(BuildContext context, Color color) {
    if (color == kPrimary) return context.theme.colorScheme.primary;
    if (color == kPrimaryDark) return context.theme.colorScheme.tertiary;
    if (color == kGrey600) return context.theme.colorScheme.onSurface.withValues(alpha: 0.68);
    return color;
  }
}

class _CategoryCardFrame extends StatelessWidget {
  const _CategoryCardFrame({required this.visual, required this.label, this.onTap});

  final Widget visual;
  final Widget label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [BoxShadow(color: colorScheme.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                visual,
                SizedBox(height: 12.h),
                label,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryVisual {
  const _CategoryVisual({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}
