import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../storage/app_preferences.dart';
import '../../utils/logging/app_logger.dart';

part 'events.dart';
part 'states.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(this._appPreferences) : super(ChangeThemeState(themeMode: _appPreferences.getAppThemeMode())) {
    on<ChangeTheme>(_onChangeTheme, transformer: (events, mapper) => events.asyncExpand(mapper));
  }

  final AppPreferences _appPreferences;

  Future<void> _onChangeTheme(ChangeTheme event, Emitter<ThemeState> emit) async {
    if (event.themeMode == state.themeMode) return;

    emit(ChangeThemeState(themeMode: event.themeMode));

    try {
      final isCached = await _appPreferences.cacheThemeMode(event.themeMode);
      if (!isCached) {
        AppLogger.w('The selected theme could not be cached.');
      }
    } catch (error, stackTrace) {
      AppLogger.e('Failed to cache the selected theme.', error: error, stackTrace: stackTrace);
    }
  }
}
