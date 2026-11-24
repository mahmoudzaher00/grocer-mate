part of '../view.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OutboxBloc, OutboxState>(
      listenWhen: (previous, current) => current is OutboxQueueFailure && previous != current,
      listener: (context, state) {
        if (state case OutboxQueueFailure(:final message)) {
          showToast(message: message, state: ToastStates.error);
        }
      },
      builder: (context, outboxState) {
        if (outboxState case OutboxRecoveryFailure(:final message)) {
          return ErrorStateWidget(
            title: 'Queued purchase needs recovery',
            message: '$message Your Cart is protected until recovery succeeds.',
            onRetry: () => context.read<OutboxBloc>().add(const OutboxRecoveryRetried()),
          );
        }
        if (outboxState is OutboxQueueing || outboxState is OutboxRecovering) {
          return const _CartRecoveryLoading();
        }

        return BlocConsumer<CartBloc, CartState>(
          listenWhen: (previous, current) => (current is CartActionFailure || current is CartActionNotice) && previous != current,
          listener: (context, state) {
            final message = switch (state) {
              CartActionFailure(:final message) || CartActionNotice(:final message) => message,
              _ => null,
            };
            if (message != null) {
              final toastState = state is CartActionFailure ? ToastStates.error : ToastStates.warning;
              showToast(message: message, state: toastState);
            }
          },
          builder: (context, state) {
            return switch (state) {
              CartInitial() || CartLoading() => Center(
                child: SpinKitFadingCircle(color: context.colorScheme.primary, size: 48.r),
              ),
              CartError(:final message) => ErrorStateWidget(title: 'Your shopping lists could not be loaded', message: message, onRetry: () => context.read<CartBloc>().add(const CartRetried())),
              CartEmpty() || CartReady() || CartActionFailure() || CartActionNotice() => _ShoppingListsContent(cart: state.cart!),
            };
          },
        );
      },
    );
  }
}
