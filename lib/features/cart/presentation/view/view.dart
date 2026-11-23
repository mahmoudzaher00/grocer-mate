import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/resources/route_names.dart';
import '../../../../core/resources/shadow_manager.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/buttons/theme_toggle_button.dart';
import '../../../../core/widgets/display/network_image.dart';
import '../../../../core/widgets/status_views/empty_state_widget.dart';
import '../../../../core/widgets/status_views/error_state_widget.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../manager/bloc.dart';
import '../widgets/quantity_stepper.dart';

part 'widgets/body.dart';
part 'widgets/cart_content.dart';
part 'widgets/cart_item_card.dart';
part 'widgets/order_summary.dart';

String _formatMoney(Cart cart, double amount) {
  return '${cart.pricing.currencySymbol}${amount.toStringAsFixed(2)}';
}

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart'), actions: const [ThemeToggleButton(), SizedBox(width: 8)]),
      body: const SafeArea(top: false, child: _Body()),
    );
  }
}
