import 'package:material_ui/material_ui.dart';

import '../../../../core/resources/color_manager.dart';
import '../../domain/entities/category.dart';

extension CategoryVisualExtension on Category {
  ({IconData icon, Color color}) visual(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (iconName) {
      'produce' => (icon: Icons.eco_rounded, color: kSuccess),
      'dairy' => (icon: Icons.egg_alt_rounded, color: colorScheme.primary),
      'bakery' => (icon: Icons.bakery_dining_rounded, color: kWarning),
      'beverages' => (icon: Icons.local_drink_rounded, color: colorScheme.tertiary),
      'pantry' => (icon: Icons.kitchen_rounded, color: kOrange),
      'household' => (icon: Icons.cleaning_services_rounded, color: colorScheme.onSurface.withValues(alpha: 0.68)),
      'personalCare' => (icon: Icons.sanitizer_rounded, color: kPurple),
      _ => (icon: Icons.category_rounded, color: colorScheme.primary),
    };
  }
}
