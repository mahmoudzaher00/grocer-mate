import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({required this.quantity, required this.onStep, required this.maximum, this.minimum = 1, this.compact = false, super.key});

  final int quantity;
  final int minimum;
  final int maximum;
  final ValueChanged<int> onStep;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final canDecrease = quantity > minimum;
    final canIncrease = quantity < maximum;
    final controlSize = compact ? 34.r : 44.r;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QuantityButton(tooltip: 'Decrease quantity', icon: Icons.remove_rounded, size: controlSize, onPressed: canDecrease ? () => onStep(-1) : null),
        SizedBox(
          width: compact ? 38.w : 44.w,
          child: Text(
            quantity.toString(),
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.copyWith(fontSize: compact ? 15.sp : 17.sp),
          ),
        ),
        _QuantityButton(tooltip: 'Increase quantity', icon: Icons.add_rounded, size: controlSize, onPressed: canIncrease ? () => onStep(1) : null),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.tooltip, required this.icon, required this.size, this.onPressed});

  final String tooltip;
  final IconData icon;
  final double size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final isEnabled = onPressed != null;

    return SizedBox.square(
      dimension: size,
      child: IconButton.filledTonal(
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.primary.withValues(alpha: isEnabled ? 0.11 : 0.05),
          foregroundColor: isEnabled ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.3),
          disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        icon: Icon(icon, size: 21.r),
      ),
    );
  }
}
