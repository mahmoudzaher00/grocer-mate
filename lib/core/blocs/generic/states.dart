part of 'bloc.dart';

sealed class GenericStates<T> extends Equatable {
  const GenericStates({required this.change, required this.data});

  final bool change;
  final T? data;

  @override
  List<Object?> get props => [change, data];
}

final class GenericInitial<T> extends GenericStates<T> {
  const GenericInitial({super.data}) : super(change: false);
}

final class GenericUpdate<T> extends GenericStates<T> {
  const GenericUpdate({required super.change, required T super.data});
}
