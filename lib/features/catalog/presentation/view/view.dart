import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/route_names.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/buttons/theme_toggle_button.dart';
import '../../../../core/widgets/status_views/empty_state_widget.dart';
import '../../domain/entities/category.dart';
import '../manager/bloc.dart';

part 'widgets/body.dart';
part 'widgets/category_card.dart';
part 'widgets/categories_grid.dart';
part 'widgets/empty.dart';
part 'widgets/error.dart';
part 'widgets/loading.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(titleSpacing: 16.w, title: const Text('Categories'), actions: const [ThemeToggleButton(), SizedBox(width: 8)]),
      body: const _Body(),
    );
  }
}
