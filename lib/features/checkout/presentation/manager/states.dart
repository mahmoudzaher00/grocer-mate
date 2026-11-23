part of 'bloc.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState({this.request});

  final PurchaseRequest? request;

  @override
  List<Object?> get props => [request];
}

final class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

final class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting(PurchaseRequest request) : super(request: request);
}

final class CheckoutReviewRequired extends CheckoutState {
  const CheckoutReviewRequired({required PurchaseRequest request, required this.review}) : super(request: request);

  @override
  PurchaseRequest get request => super.request!;

  final PurchaseReview review;

  bool get canResubmit => review.isResolved && !request.cart.isEmpty;

  @override
  List<Object?> get props => [...super.props, review];
}

final class CheckoutFailure extends CheckoutState {
  const CheckoutFailure({required PurchaseRequest request, required this.message}) : super(request: request);

  @override
  PurchaseRequest get request => super.request!;

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}

final class CheckoutSucceeded extends CheckoutState {
  CheckoutSucceeded({required this.purchase, required List<String> processedProductIds}) : processedProductIds = List<String>.unmodifiable(processedProductIds), super();

  final PurchaseSuccess purchase;
  final List<String> processedProductIds;

  @override
  List<Object?> get props => [purchase, processedProductIds];
}
