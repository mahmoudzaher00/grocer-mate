import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../core/utils/extensions/context_extensions.dart';
import '../../../../../core/widgets/buttons/theme_toggle_button.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';
import '../../manager/products/bloc.dart';

part 'widgets/body.dart';
part 'widgets/empty.dart';
part 'widgets/error.dart';
part 'widgets/loading.dart';
part 'widgets/pagination_footer.dart';
part 'widgets/product_card.dart';
part 'widgets/products_list.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({required this.category, super.key});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.name), actions: const [ThemeToggleButton(), SizedBox(width: 8)]),
      body: _Body(categoryId: category.id),
    );
  }
}
