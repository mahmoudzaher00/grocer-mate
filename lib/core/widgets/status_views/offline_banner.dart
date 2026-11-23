import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../blocs/connectivity/bloc.dart';
import '../../utils/extensions/context_extensions.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ConnectivityBloc, ConnectivityState, bool>(
      selector: (state) => state.isOffline,
      builder: (context, isOffline) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isOffline
              ? Material(
                  key: const ValueKey<String>('offline-banner'),
                  color: context.theme.colorScheme.tertiaryContainer,
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off_rounded, size: 18.r, color: context.theme.colorScheme.onTertiaryContainer),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            'You are offline. Showing saved content.',
                            textAlign: TextAlign.center,
                            style: context.textTheme.labelLarge?.copyWith(color: context.theme.colorScheme.onTertiaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey<String>('online-banner')),
        );
      },
    );
  }
}
