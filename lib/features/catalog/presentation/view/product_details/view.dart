import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/blocs/connectivity/bloc.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/system_ui_styles.dart';
import '../../../../../core/utils/extensions/context_extensions.dart';
import '../../../../../core/utils/toast_utils.dart';
import '../../../../../core/widgets/buttons/theme_toggle_button.dart';
import '../../../../../core/widgets/images/network_image_widget.dart';
import '../../../../../core/widgets/status_views/error_state_widget.dart';
import '../../../../cart/presentation/manager/bloc.dart';
import '../../../../cart/presentation/view/widgets/cart_button.dart';
import '../../../../cart/presentation/view/widgets/quantity_stepper.dart';
import '../../../../checkout/presentation/manager/outbox/bloc.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_details.dart';
import '../../manager/product_details/bloc.dart';
import '../../widgets/product_discount_badge.dart';
import '../../widgets/product_image_hero.dart';
import '../../widgets/product_price.dart';
import '../../widgets/product_stock_badge.dart';

part 'widgets/body.dart';
part 'widgets/cart_action_bar.dart';
part 'widgets/details_section.dart';
part 'widgets/error.dart';
part 'widgets/product_app_bar.dart';
part 'widgets/loading.dart';
part 'widgets/product_info.dart';

class ProductDetailsView extends StatelessWidget {
  const ProductDetailsView({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Body(product: product),
      bottomNavigationBar: _ProductCartBar(fallbackProduct: product),
    );
  }
}
