import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/app/app_di.dart';
import '../../../../core/resources/shadow_manager.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/status_views/error_state_widget.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/purchase.dart';
import '../manager/bloc.dart';

part 'widgets/body.dart';
part 'widgets/review_content.dart';
part 'widgets/review_item_card.dart';

final class CheckoutOutcome {
  CheckoutOutcome({required this.orderId, required this.finalTotal, required List<String> processedProductIds}) : processedProductIds = List<String>.unmodifiable(processedProductIds);

  final String orderId;
  final double finalTotal;
  final List<String> processedProductIds;
}

Future<CheckoutOutcome?> showCheckoutSheet({required BuildContext context, required Cart cart, String? idempotencyKey}) {
  return showModalBottomSheet<CheckoutOutcome>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => instance<CheckoutBloc>()..add(CheckoutStarted(cart, idempotencyKey: idempotencyKey)),
      child: const CheckoutView(),
    ),
  );
}

Future<void> showOrderConfirmationDialog({required BuildContext context, required String orderId, required String totalLabel}) {
  final colorScheme = context.theme.colorScheme;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(Icons.check_circle_rounded, color: colorScheme.secondary, size: 48.r),
      title: const Text('Order confirmed', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Order $orderId was placed successfully.', textAlign: TextAlign.center, style: context.textTheme.bodyLarge),
          SizedBox(height: 12.h),
          Text(
            totalLabel,
            style: context.textTheme.headlineSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [FilledButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Done'))],
    ),
  );
}

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      child: SizedBox(
        height: context.height * 0.88,
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(999.r)),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 10.h, 8.w, 8.h),
              child: Row(
                children: [
                  Expanded(child: Text('Review checkout', style: context.textTheme.titleLarge)),
                  IconButton(tooltip: 'Close checkout', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            const Expanded(child: _Body()),
          ],
        ),
      ),
    );
  }
}
