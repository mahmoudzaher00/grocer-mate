part of '../view.dart';

class _QueuedPurchaseCard extends StatelessWidget {
  const _QueuedPurchaseCard({required this.state});

  final OutboxState state;

  String _createdLabel(DateTime createdAt) {
    final local = createdAt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day}/${local.month}/${local.year} at $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final purchase = state.purchase!;
    final colorScheme = context.theme.colorScheme;
    final isOnline = context.watch<ConnectivityBloc>().state is ConnectivityOnline;
    final isBusy = state is OutboxReadyForCheckout || state is OutboxCheckoutActive || state is OutboxClearing;
    final status = switch (state) {
      OutboxDeferred() => 'Waiting for your review',
      OutboxClearFailure() => 'Order confirmed - cleanup required',
      OutboxReadyForCheckout() || OutboxCheckoutActive() => 'Revalidating prices and stock',
      OutboxClearing() => 'Finishing your order',
      _ when isOnline => 'Ready to revalidate',
      _ => 'Queued - waiting for connection',
    };

    final VoidCallback? onAction;
    final String actionLabel;
    if (state is OutboxClearFailure) {
      actionLabel = 'Retry cleanup';
      onAction = () => context.read<OutboxBloc>().add(const OutboxClearRetried());
    } else {
      actionLabel = 'Review purchase';
      onAction = isOnline && !isBusy ? () => context.read<OutboxBloc>().add(const OutboxManualReviewRequested()) : null;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.24)),
        boxShadow: AppShadows.cardShadow(colorScheme.shadow),
      ),
      child: Padding(
        padding: EdgeInsets.all(18.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14.r)),
                  child: Icon(Icons.schedule_send_rounded, color: colorScheme.primary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending purchase',
                        style: context.textTheme.titleMedium?.copyWith(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2.h),
                      Text(status, style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimaryContainer.withValues(alpha: 0.72))),
                    ],
                  ),
                ),
                if (isBusy) SpinKitFadingCircle(color: colorScheme.onPrimaryContainer, size: 20.r),
              ],
            ),
            SizedBox(height: 14.h),
            Text(
              '${purchase.itemCount} ${purchase.itemCount == 1 ? 'item' : 'items'} · ${purchase.cart.total.formatCurrency(currencySymbol: purchase.cart.pricing.currencySymbol)}',
              style: context.textTheme.titleSmall?.copyWith(color: colorScheme.onPrimaryContainer),
            ),
            SizedBox(height: 4.h),
            Text('Queued ${_createdLabel(purchase.createdAt)}', style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimaryContainer.withValues(alpha: 0.68))),
            if (state case OutboxClearFailure(:final message)) ...[SizedBox(height: 10.h), Text(message, style: context.textTheme.bodySmall?.copyWith(color: colorScheme.error))],
            SizedBox(height: 14.h),
            FilledButton.tonalIcon(onPressed: onAction, icon: Icon(state is OutboxClearFailure ? Icons.refresh_rounded : Icons.receipt_long_outlined), label: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
