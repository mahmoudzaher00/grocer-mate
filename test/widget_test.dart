import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocer_mate/core/app/app_di.dart';
import 'package:grocer_mate/core/app/app_entry.dart';
import 'package:grocer_mate/core/constants/duration_constants.dart';
import 'package:grocer_mate/core/network/network_manager.dart';
import 'package:grocer_mate/features/catalog/data/data_sources/catalog_cache_data_source.dart';
import 'package:grocer_mate/features/catalog/data/models/category_model.dart';
import 'package:grocer_mate/features/splash/presentation/view/view.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('offline startup opens the cached catalog after the splash screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(instance.reset);
    await initializeDependencies();
    instance.pushNewScope(
      init: (scope) {
        scope.registerSingleton<NetworkManager>(NetworkManager(connectionChecker: _OfflineChecker()));
      },
    );
    await instance<CatalogCacheDataSource>().saveCategories(const [CategoryModel(id: 'c_fruit', name: 'Fruits', iconName: 'produce')]);

    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AppEntry());
    expect(find.byType(SplashView), findsOneWidget);
    await tester.pump(DurationConstants.splashNavigationDelay);
    await tester.pumpAndSettle();

    expect(find.byType(SplashView), findsNothing);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Fruits'), findsOneWidget);
    expect(find.text('You are offline. Showing saved content.'), findsOneWidget);
  });
}

class _OfflineChecker extends Fake implements InternetConnectionChecker {
  @override
  Future<bool> get hasConnection async => false;

  @override
  Stream<InternetConnectionStatus> get onStatusChange => const Stream.empty();
}
