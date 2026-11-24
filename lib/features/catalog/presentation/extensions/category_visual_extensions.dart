import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category.dart';

extension CategoryVisualExtension on Category {
  ({IconData icon, Color color}) visual(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (iconName) {
      'produce' => (icon: Icons.eco_rounded, color: colorScheme.primary),
      'dairy' => (icon: Icons.egg_alt_rounded, color: colorScheme.secondary),
      'bakery' => (icon: Icons.bakery_dining_rounded, color: colorScheme.tertiary),
      'beverages' => (icon: Icons.local_drink_rounded, color: colorScheme.secondary),
      'pantry' => (icon: Icons.kitchen_rounded, color: kPantryOrange),
      'household' => (icon: Icons.cleaning_services_rounded, color: colorScheme.onSurfaceVariant),
      'personalCare' => (icon: Icons.sanitizer_rounded, color: kPersonalCarePurple),
      _ => (icon: Icons.category_rounded, color: colorScheme.primary),
    };
  }
}
