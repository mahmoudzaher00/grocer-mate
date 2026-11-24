import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/assets/asset_paths.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

part 'widgets/body.dart';
part 'widgets/background_accent.dart';
part 'widgets/sliding_logo.dart';
part 'widgets/sliding_txt_group.dart';
part 'widgets/fade_txt.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: context.theme.scaffoldBackgroundColor, body: const _Body());
  }
}
