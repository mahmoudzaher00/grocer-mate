import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/resources/route_names.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../manager/bloc.dart';

class CartButton extends StatelessWidget {
  const CartButton({this.color, super.key});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CartBloc, CartState, int>(
      selector: (state) => state.cart?.itemCount ?? 0,
      builder: (context, itemCount) {
        final resolvedColor = color ?? context.theme.colorScheme.primary;
        final badgeLabel = itemCount > 99 ? '99+' : itemCount.toString();

        return Semantics(
          button: true,
          label: itemCount == 0 ? 'Open empty cart' : 'Open cart with $itemCount items',
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
                    decoration: BoxDecoration(color: context.theme.colorScheme.error, borderRadius: BorderRadius.circular(999.r)),
                    child: Text(
                      badgeLabel,
                      style: context.textTheme.labelSmall?.copyWith(color: context.theme.colorScheme.onError, fontSize: 10.sp, height: 1),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
