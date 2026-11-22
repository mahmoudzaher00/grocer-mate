part of 'bloc.dart';

sealed class ThemeState extends Equatable {
  const ThemeState({required this.themeMode});

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

final class ChangeThemeState extends ThemeState {
  const ChangeThemeState({required super.themeMode});
}
