part of '../view.dart';

class _Body extends StatelessWidget {
  const _Body({required this.onSubmissionRequested});

  final VoidCallback onSubmissionRequested;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listenWhen: (_, current) => current is CheckoutSucceeded,
      listener: (context, state) {
        if (state case CheckoutSucceeded(:final purchase, :final purchasedCart)) {
          if (!context.mounted || ModalRoute.of(context)?.isCurrent != true) return;
          Navigator.of(context).pop(CheckoutOutcome(orderId: purchase.orderId, finalTotal: purchase.finalTotal, purchasedCart: purchasedCart));
        }
      },
      builder: (context, state) {
        return switch (state) {
          CheckoutInitial() || CheckoutSubmitting() || CheckoutSucceeded() => const _CheckoutLoading(),
          CheckoutReviewRequired() => _ReviewContent(state: state, onSubmissionRequested: onSubmissionRequested),
          CheckoutFailure(:final message) => ErrorStateWidget(
            title: 'Checkout could not be completed',
            message: message,
            onRetry: state.request.cart.isEmpty
                ? null
                : () {
                    onSubmissionRequested();
                    context.read<CheckoutBloc>().add(const CheckoutRetried());
                  },
          ),
        };
      },
    );
  }
}

class _CheckoutLoading extends StatelessWidget {
  const _CheckoutLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitFadingCircle(color: context.colorScheme.primary, size: 48.r),
            SizedBox(height: 20.h),
            Text('Checking the latest prices and stock...', textAlign: TextAlign.center, style: context.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
