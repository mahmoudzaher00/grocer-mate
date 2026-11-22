part of 'bloc.dart';

sealed class GenericEvent<T> extends Equatable {
  const GenericEvent();

  @override
  List<Object?> get props => [];
}

final class GenericUpdated<T> extends GenericEvent<T> {
  const GenericUpdated(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}
