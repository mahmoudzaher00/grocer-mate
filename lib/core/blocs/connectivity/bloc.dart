import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/network_manager.dart';

part 'events.dart';
part 'states.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc(this._networkManager) : super(const ConnectivityInitial()) {
    on<ConnectivityStarted>(_onStarted);
  }

  final NetworkManager _networkManager;

  Future<void> _onStarted(ConnectivityStarted event, Emitter<ConnectivityState> emit) async {
    final isConnected = await _networkManager.isConnected;
    emit(isConnected ? const ConnectivityOnline() : const ConnectivityOffline());

    await emit.forEach<bool>(_networkManager.statusChanges, onData: (isOnline) => isOnline ? const ConnectivityOnline() : const ConnectivityOffline(), onError: (_, _) => const ConnectivityOffline());
  }
}
