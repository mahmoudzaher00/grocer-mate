import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/blocs/connectivity/bloc.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/buttons/theme_toggle_button.dart';
import '../../../../core/widgets/status_views/empty_state_widget.dart';
import '../../../../core/widgets/status_views/error_state_widget.dart';
import '../../../cart/presentation/widgets/cart_button.dart';
import '../../domain/entities/category.dart';
import '../extensions/category_visual_extensions.dart';
import '../manager/bloc.dart';

part 'widgets/body.dart';
part 'widgets/category_card.dart';
part 'widgets/categories_list.dart';
part 'widgets/categories_sliver_app_bar.dart';
part 'widgets/empty.dart';
part 'widgets/error.dart';
part 'widgets/loading.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: _Body()));
  }
}
