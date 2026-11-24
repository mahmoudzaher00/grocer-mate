import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/app/app_di.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/modal_utils.dart';
import '../../../../core/widgets/status_views/error_state_widget.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/purchase.dart';
import '../manager/bloc.dart';
import '../manager/outbox/bloc.dart';

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
    isDismissible: true,
    enableDrag: false,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => instance<CheckoutBloc>()..add(CheckoutStarted(cart, idempotencyKey: idempotencyKey)),
      child: const CheckoutView(),
    ),
  );
}

Future<void> showOrderConfirmationDialog({required BuildContext context, required String orderId, required String totalLabel}) {
  return showCustomAlertDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final colorScheme = dialogContext.theme.colorScheme;
      return AlertDialog(
        icon: Icon(Icons.check_circle_rounded, size: 48.r),
        title: const Text('Order confirmed', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order $orderId was placed successfully.', textAlign: TextAlign.center, style: dialogContext.textTheme.bodyLarge),
            SizedBox(height: 12.h),
            Text(
              totalLabel,
              style: dialogContext.textTheme.headlineSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [FilledButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Done'))],
      );
    },
  );
}

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  bool _isDismissalLocked = false;
  bool _isDismissing = false;

  bool _canDismiss(CheckoutState state) {
    return !_isDismissalLocked && (state is CheckoutReviewRequired || state is CheckoutFailure);
  }

  void _lockDismissal() {
    if (!_isDismissalLocked) setState(() => _isDismissalLocked = true);
  }

  void _dismissIfAllowed() {
    if (_isDismissing || !mounted || ModalRoute.of(context)?.isCurrent != true) return;
    if (context.read<OutboxBloc>().state is! OutboxClearing && _canDismiss(context.read<CheckoutBloc>().state)) {
      _isDismissing = true;
      Navigator.of(context).pop();
    }
  }

  void _onCheckoutStateChanged(BuildContext context, CheckoutState state) {
    final isLocked = state is CheckoutSubmitting || state is CheckoutSucceeded;
    if (isLocked != _isDismissalLocked && mounted) setState(() => _isDismissalLocked = isLocked);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final isClearing = context.select((OutboxBloc bloc) => bloc.state is OutboxClearing);

    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: _onCheckoutStateChanged,
      child: PopScope<CheckoutOutcome>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _dismissIfAllowed();
        },
        child: Material(
          color: colorScheme.surface,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          child: SizedBox(
            height: context.screenHeight * 0.88,
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
                      BlocBuilder<CheckoutBloc, CheckoutState>(
                        builder: (context, state) =>
                            IconButton(tooltip: 'Close checkout', onPressed: !isClearing && _canDismiss(state) ? _dismissIfAllowed : null, icon: const Icon(Icons.close_rounded)),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                Expanded(child: _Body(onSubmissionRequested: _lockDismissal)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
