import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/resources/asset_manager.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/route_names.dart';
import '../../../../core/resources/shadow_manager.dart';
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
    return const Scaffold(backgroundColor: kPrimary, body: _Body());
  }
}
