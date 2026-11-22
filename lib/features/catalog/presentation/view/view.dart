import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Hi', style: context.textTheme.headlineLarge)),
    );
  }
}
