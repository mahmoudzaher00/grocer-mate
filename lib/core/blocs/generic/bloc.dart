import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'events.dart';
part 'states.dart';

class GenericBloc<T> extends Bloc<GenericEvent<T>, GenericStates<T>> {
  GenericBloc({T? data}) : super(GenericInitial<T>(data: data)) {
    on<GenericUpdated<T>>(_onUpdated);
  }

  void _onUpdated(GenericUpdated<T> event, Emitter<GenericStates<T>> emit) {
    emit(GenericUpdate<T>(
      change: !state.change,
      data: event.data,
    ));
  }
}