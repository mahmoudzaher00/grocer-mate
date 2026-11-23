import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/resources/route_names.dart';
import '../../../../core/resources/shadow_manager.dart';
import '../../../../core/blocs/connectivity/bloc.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/value_extensions.dart';
import '../../../../core/widgets/buttons/theme_toggle_button.dart';
import '../../../../core/widgets/display/network_image.dart';
import '../../../../core/widgets/status_views/empty_state_widget.dart';
import '../../../../core/widgets/status_views/error_state_widget.dart';
import '../../../checkout/presentation/view/view.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../manager/bloc.dart';
import '../widgets/quantity_stepper.dart';

part 'widgets/body.dart';
part 'widgets/cart_content.dart';
part 'widgets/cart_tab_bar.dart';
part 'widgets/cart_item_card.dart';
part 'widgets/order_summary.dart';
part 'widgets/saved_content.dart';
part 'widgets/saved_item_card.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final systemOverlayStyle = (theme.appBarTheme.systemOverlayStyle ?? const SystemUiOverlayStyle()).copyWith(statusBarColor: backgroundColor);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            bottom: false,
            child: NestedScrollView(
              headerSliverBuilder: (_, _) => [
                SliverAppBar(
                  primary: false,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: backgroundColor,
                  surfaceTintColor: Colors.transparent,
                  title: const Text('Shopping Lists'),
                  actions: const [ThemeToggleButton(), SizedBox(width: 8)],
                ),
                const _CartTabBar(),
              ],
              body: const SafeArea(top: false, left: false, right: false, child: _Body()),
            ),
          ),
        ),
      ),
    );
  }
}
