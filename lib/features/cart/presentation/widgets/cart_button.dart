import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../checkout/presentation/manager/outbox/bloc.dart';
import '../manager/bloc.dart';

class CartButton extends StatelessWidget {
  const CartButton({this.color, super.key});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OutboxBloc, OutboxState>(
      buildWhen: (previous, current) => previous.hasPendingPurchase != current.hasPendingPurchase,
      builder: (context, outboxState) => BlocSelector<CartBloc, CartState, int>(
        selector: (state) => state.cart?.itemCount ?? 0,
        builder: (context, itemCount) {
          final hasPendingPurchase = outboxState.hasPendingPurchase;
          final colorScheme = context.theme.colorScheme;
          final resolvedColor = color ?? colorScheme.primary;
          final badgeLabel = itemCount > 99 ? '99+' : itemCount.toString();

          return Semantics(
            button: true,
            label: hasPendingPurchase && itemCount == 0
                ? 'Open cart with a pending purchase'
                : itemCount == 0
                ? 'Open empty cart'
                : 'Open cart with $itemCount items',
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Cart',
                  onPressed: () => Navigator.of(context).pushNamed(cartRoute),
                  icon: Icon(Icons.shopping_cart_outlined, color: resolvedColor),
                ),
                if (itemCount > 0)
                  PositionedDirectional(
                    top: 2.h,
                    end: 1.w,
                    child: Container(
                      constraints: BoxConstraints(minWidth: 18.r, minHeight: 18.r),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(999.r)),
                      child: Text(
                        badgeLabel,
                        style: context.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary, fontSize: 10.sp, height: 1),
                      ),
                    ),
                  ),
                if (itemCount == 0 && hasPendingPurchase)
                  PositionedDirectional(
                    top: 2.h,
                    end: 1.w,
                    child: Container(
                      width: 18.r,
                      height: 18.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: colorScheme.tertiary, borderRadius: BorderRadius.circular(999.r)),
                      child: Icon(Icons.schedule_rounded, size: 11.r, color: colorScheme.onTertiary),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
