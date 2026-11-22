import '../../domain/entities/product_page.dart';
import 'product_model.dart';

final class ProductPageModel extends ProductPage {
  ProductPageModel({required List<ProductModel> products, required super.page, required super.pageSize, required super.total}) : super(products: products);
}
