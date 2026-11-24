import 'dart:async';

import 'package:dartz/dartz.dart' show Either, Right;
import 'package:flutter_test/flutter_test.dart';
import 'package:grocer_mate/core/errors/failures.dart';
import 'package:grocer_mate/features/catalog/domain/entities/category.dart';
import 'package:grocer_mate/features/catalog/domain/entities/product_page.dart';
import 'package:grocer_mate/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:grocer_mate/features/catalog/domain/use_cases/get_brands.dart';
import 'package:grocer_mate/features/catalog/domain/use_cases/get_categories.dart';
import 'package:grocer_mate/features/catalog/domain/use_cases/get_products.dart';
import 'package:grocer_mate/features/catalog/presentation/manager/products/bloc.dart';

const fruit = Category(id: 'fruit', name: 'Fruits', iconName: '');
const dairy = Category(id: 'dairy', name: 'Dairy', iconName: '');

class _ControlledCatalogRepository extends Fake implements CatalogRepository {
  Completer<void>? categoriesGate;
  Completer<void>? dairyBrandsGate;
  final queries = <String>[];
  final brandRequests = <String?>[];
  int categoryRequests = 0;

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    categoryRequests++;
    await categoriesGate?.future;
    return const Right([fruit, dairy]);
  }

  @override
  Future<Either<Failure, List<String>>> getBrands({String? categoryId}) async {
    brandRequests.add(categoryId);
    if (categoryId == 'dairy') {
      await dairyBrandsGate?.future;
    }
    return Right([categoryId == 'dairy' ? 'MilkWay' : 'FreshFarm']);
  }

  @override
  Future<Either<Failure, ProductPage>> getProducts({required int page, required int pageSize, String? categoryId, String? brand, String searchQuery = ''}) async {
    queries.add(searchQuery);
    return Right(ProductPage(products: [], page: page, pageSize: pageSize, total: 0));
  }
}

ProductsBloc _createBloc(_ControlledCatalogRepository repository) {
  final bloc = ProductsBloc(GetProducts(repository), GetCategories(repository), GetBrands(repository));
  addTearDown(bloc.close);
  return bloc;
}

void main() {
  const debounce = Duration(milliseconds: 400);

  testWidgets('search supersedes category bootstrap', (tester) async {
    final repository = _ControlledCatalogRepository()..categoriesGate = Completer<void>();
    final bloc = _createBloc(repository);

    bloc.add(const ProductsRequested(fruit));
    await tester.pump();
    bloc.add(const ProductsSearchChanged('apple'));
    await tester.pump();
    await tester.pump(debounce);

    expect(repository.categoryRequests, 2);
    repository.categoriesGate!.complete();
    await tester.pump();

    expect(bloc.state, isA<ProductsEmpty>());
    expect(bloc.state.filters.categories, [fruit, dairy]);
    expect(bloc.state.filters.brands, ['FreshFarm']);
    expect(repository.queries, ['apple']);
  });

  testWidgets('search supersedes Dairy brand load', (tester) async {
    final repository = _ControlledCatalogRepository()..dairyBrandsGate = Completer<void>();
    final bloc = _createBloc(repository);

    bloc.add(const ProductsRequested(fruit));
    await tester.pump();
    bloc.add(const ProductsCategoryChanged('dairy'));
    await tester.pump();
    expect(bloc.state.filters.brands, isEmpty);

    bloc.add(const ProductsSearchChanged('milk'));
    await tester.pump();
    await tester.pump(debounce);

    expect(repository.brandRequests, [fruit.id, dairy.id, dairy.id]);
    repository.dairyBrandsGate!.complete();
    await tester.pump();

    expect(bloc.state, isA<ProductsEmpty>());
    expect(bloc.state.filters.brands, ['MilkWay']);
    expect(repository.queries, ['', 'milk']);
  });

  testWidgets('Clear cancels pending search', (tester) async {
    final repository = _ControlledCatalogRepository();
    final bloc = _createBloc(repository);

    bloc.add(const ProductsRequested(fruit));
    await tester.pump();
    bloc.add(const ProductsSearchChanged('apple'));
    await tester.pump();
    bloc.add(const ProductsFiltersCleared());
    await tester.pump();
    await tester.pump(debounce);

    expect(bloc.state, isA<ProductsEmpty>());
    expect(bloc.state.filters.hasActiveFilters, isFalse);
    expect(repository.queries, ['', '']);
  });
}
