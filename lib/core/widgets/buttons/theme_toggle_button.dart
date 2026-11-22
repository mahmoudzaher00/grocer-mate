import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_constants.dart';
import '../../blocs/theme/bloc.dart';
import '../../resources/theme_manager.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return IconButton(
      tooltip: isDark ? 'Use light theme' : 'Use dark theme',
      onPressed: () {
        context.read<ThemeBloc>().add(ChangeTheme(themeMode: ThemeManager.oppositeOf(brightness)));
      },
      icon: AnimatedSwitcher(
        duration: reduceMotion ? Duration.zero : AppConstants.themeIconAnimationDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.72, end: 1).animate(animation),
              child: RotationTransition(turns: Tween<double>(begin: -0.08, end: 0).animate(animation), child: child),
            ),
          );
        },
        child: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, key: ValueKey(isDark)),
      ),
    );
  }
}
