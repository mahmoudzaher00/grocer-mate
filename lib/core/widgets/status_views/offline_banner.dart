import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../blocs/connectivity/bloc.dart';
import '../../constants/duration_constants.dart';
import '../../utils/extensions/context_extensions.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  static const _message = 'You are offline. Showing saved content.';

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ConnectivityBloc, ConnectivityState, bool>(
      selector: (state) => state.isOffline,
      builder: (context, isOffline) {
        final colorScheme = context.theme.colorScheme;

        return AnimatedSwitcher(
          duration: DurationConstants.offlineBannerAnimationDuration,
          child: isOffline
              ? Semantics(
                  key: const ValueKey<String>('offline-banner'),
                  container: true,
                  liveRegion: true,
                  label: _message,
                  excludeSemantics: true,
                  child: Material(
                    color: colorScheme.tertiaryContainer,
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off_rounded, size: 18.r, color: colorScheme.onTertiaryContainer),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              _message,
                              textAlign: TextAlign.center,
                              style: context.textTheme.labelLarge?.copyWith(color: colorScheme.onTertiaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey<String>('online-banner')),
        );
      },
    );
  }
}
class OfflineBannerLayout extends StatelessWidget {
  const OfflineBannerLayout({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ConnectivityBloc, ConnectivityState, bool>(
      selector: (state) => state.isOffline,
      builder: (context, isOffline) {
        final topInset = MediaQuery.paddingOf(context).top;
        final bannerHeight = 44.h;

        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Stack(
            children: [
              Positioned.fill(
                top: isOffline ? topInset + bannerHeight : 0,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: isOffline,
                  child: child,
                ),
              ),
              if (isOffline)
                PositionedDirectional(
                  top: topInset,
                  start: 0,
                  end: 0,
                  height: bannerHeight,
                  child: const IgnorePointer(
                    child: OfflineBanner(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
