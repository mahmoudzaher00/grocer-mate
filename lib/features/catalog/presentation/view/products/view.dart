import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/resources/shadow_manager.dart';
import '../../../../../core/resources/route_names.dart';
import '../../../../../core/utils/dialog_utils.dart';
import '../../../../../core/utils/extensions/context_extensions.dart';
import '../../../../../core/widgets/buttons/theme_toggle_button.dart';
import '../../../../../core/widgets/display/network_image.dart';
import '../../../../../core/widgets/forms/text_field.dart';
import '../../../../../core/widgets/status_views/empty_state_widget.dart';
import '../../../../../core/widgets/status_views/error_state_widget.dart';
import '../../../../cart/presentation/widgets/cart_button.dart';
import '../../../domain/entities/product.dart';
import '../../manager/products/bloc.dart';
import '../../widgets/product_discount_badge.dart';
import '../../widgets/product_image_hero.dart';
import '../../widgets/product_price.dart';
import '../../widgets/product_stock_badge.dart';

part 'widgets/body.dart';
part 'widgets/empty.dart';
part 'widgets/error.dart';
part 'widgets/loading.dart';
part 'widgets/pagination_footer.dart';
part 'widgets/product_card.dart';
part 'widgets/product_controls.dart';
part 'widgets/product_search_field.dart';
part 'widgets/products_sliver_app_bar.dart';
part 'widgets/products_list.dart';
part 'widgets/sheets/filter_options_sheet.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: _Body()));
  }
}
