import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/app/app_constants.dart';
import '../../../../core/blocs/connectivity/bloc.dart';
import '../../../../core/routing/app_router.dart';
import '../../../cart/presentation/manager/bloc.dart';
import '../manager/outbox/bloc.dart';
import '../view/view.dart';

class QueuedCheckoutCoordinator extends StatefulWidget {
  const QueuedCheckoutCoordinator({required this.child, super.key});

  final Widget child;

  @override
  State<QueuedCheckoutCoordinator> createState() => _QueuedCheckoutCoordinatorState();
}

class _QueuedCheckoutCoordinatorState extends State<QueuedCheckoutCoordinator> with WidgetsBindingObserver {
  bool _initialized = false;
  bool _isPresentingCheckout = false;
  bool _isShowingConfirmation = false;
  bool _isAppActive = false;
  OutboxState? _previousOutboxState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    routeObserver.currentRouteName.addListener(_onRouteChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    _isAppActive = WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _previousOutboxState = context.read<OutboxBloc>().state;
    context.read<OutboxBloc>().add(OutboxAppActivityChanged(_isAppActive));
    final connectivityState = context.read<ConnectivityBloc>().state;
    context.read<OutboxBloc>().add(OutboxConnectivityChanged(connectivityState is ConnectivityOnline));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppActive = state == AppLifecycleState.resumed;
    context.read<OutboxBloc>().add(OutboxAppActivityChanged(_isAppActive));
    if (_isAppActive) {
      _tryPresentCheckout();
      _tryShowConfirmation();
    }
  }

  void _onRouteChanged() {
    _tryPresentCheckout();
    _tryShowConfirmation();
  }

  bool get _isNavigationReady {
    final routeName = routeObserver.currentRouteName.value;
    return routeName != null && routeName != splashRoute && AppConstants.navigatorKey.currentState != null;
  }

  void _tryPresentCheckout() {
    if (!mounted || !_isAppActive || !_isNavigationReady || _isPresentingCheckout || _isShowingConfirmation) return;
    if (context.read<OutboxBloc>().state is! OutboxReadyForCheckout) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isAppActive || !_isNavigationReady || _isPresentingCheckout || _isShowingConfirmation) return;
      final state = context.read<OutboxBloc>().state;
      if (state is OutboxReadyForCheckout) _presentCheckout(state);
    });
  }

  Future<void> _presentCheckout(OutboxReadyForCheckout state) async {
    final navigatorContext = AppConstants.navigatorKey.currentContext;
    if (navigatorContext == null) return;

    _isPresentingCheckout = true;
    context.read<OutboxBloc>().add(const OutboxCheckoutOpened());
    try {
      final outcome = await showCheckoutSheet(context: navigatorContext, cart: state.purchase.cart, idempotencyKey: state.purchase.idempotencyKey);
      if (!mounted) return;
      if (outcome == null) {
        context.read<OutboxBloc>().add(const OutboxCheckoutClosed());
      } else {
        context.read<OutboxBloc>().add(OutboxCheckoutSucceeded(orderId: outcome.orderId, finalTotal: outcome.finalTotal, currencySymbol: state.purchase.cart.pricing.currencySymbol));
      }
    } finally {
      _isPresentingCheckout = false;
    }
  }

  void _tryShowConfirmation() {
    if (!mounted || !_isAppActive || !_isNavigationReady || _isPresentingCheckout || _isShowingConfirmation) return;
    if (context.read<OutboxBloc>().state is! OutboxCompleted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isAppActive || !_isNavigationReady || _isPresentingCheckout || _isShowingConfirmation) return;
      final state = context.read<OutboxBloc>().state;
      if (state is OutboxCompleted) _showConfirmation(state);
    });
  }

  Future<void> _showConfirmation(OutboxCompleted state) async {
    final navigatorContext = AppConstants.navigatorKey.currentContext;
    if (navigatorContext == null) return;

    _isShowingConfirmation = true;
    try {
      await showOrderConfirmationDialog(context: navigatorContext, orderId: state.orderId, totalLabel: '${state.currencySymbol}${state.finalTotal.toStringAsFixed(2)}');
      if (mounted) context.read<OutboxBloc>().add(const OutboxCompletionAcknowledged());
    } finally {
      _isShowingConfirmation = false;
    }
  }

  void _onOutboxStateChanged(BuildContext context, OutboxState state) {
    final previousState = _previousOutboxState;
    _previousOutboxState = state;
    final didFinishCartRecovery =
        (previousState is OutboxQueueing || previousState is OutboxRecovering || previousState is OutboxRecoveryFailure) &&
        (state is OutboxQueued || state is OutboxReadyForCheckout || state is OutboxEmpty);
    if (didFinishCartRecovery) context.read<CartBloc>().add(const CartRequested());
    if (state is OutboxReadyForCheckout) _tryPresentCheckout();
    if (state is OutboxCompleted) _tryShowConfirmation();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ConnectivityBloc, ConnectivityState>(listener: (context, state) => context.read<OutboxBloc>().add(OutboxConnectivityChanged(state is ConnectivityOnline))),
        BlocListener<OutboxBloc, OutboxState>(listener: _onOutboxStateChanged),
      ],
      child: widget.child,
    );
  }

  @override
  void dispose() {
    routeObserver.currentRouteName.removeListener(_onRouteChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
