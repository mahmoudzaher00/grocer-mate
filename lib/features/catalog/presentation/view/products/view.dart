import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/resources/shadow_manager.dart';
import '../../../../../core/utils/extensions/context_extensions.dart';
import '../../../../../core/widgets/buttons/theme_toggle_button.dart';
import '../../../../../core/widgets/display/network_image.dart';
import '../../../../../core/widgets/status_views/empty_state_widget.dart';
import '../../../../../core/widgets/status_views/error_state_widget.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';
import '../../manager/products/bloc.dart';

part 'widgets/body.dart';
part 'widgets/empty.dart';
part 'widgets/error.dart';
part 'widgets/loading.dart';
part 'widgets/pagination_footer.dart';
part 'widgets/product_card.dart';
part 'widgets/products_sliver_app_bar.dart';
part 'widgets/products_list.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({required this.category, super.key});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _Body(categoryId: category.id, categoryName: category.name),
      ),
    );
  }
}
