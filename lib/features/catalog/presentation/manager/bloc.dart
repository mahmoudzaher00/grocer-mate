import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category.dart';
import '../../domain/use_cases/get_categories.dart';

part 'events.dart';
part 'states.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  /// Listener *****************************************************************

  CategoriesBloc(this._getCategories) : super(const CategoriesInitial()) {
    on<CategoriesRequested>(_onCategoriesRequested,);
  }

  /// Data *********************************************************************

  final GetCategories _getCategories;

  /// Logic ********************************************************************

  void _emitCategories(List<Category> categories, Emitter<CategoriesState> emit) {
    if (categories.isEmpty) {
      emit(const CategoriesEmpty());
      return;
    }
    emit(CategoriesSuccess(categories));
  }

  /// Api & Request ************************************************************

  Future<void> _onCategoriesRequested(CategoriesRequested event, Emitter<CategoriesState> emit) async {
    emit(const CategoriesLoading());

    // Simulates a slow request during development so the loading UI can be reviewed.
    await Future<void>.delayed(const Duration(seconds: 2));

    final result = await _getCategories();
    result.fold((failure) => emit(CategoriesError(failure.errMessage)), (categories) => _emitCategories(categories, emit));
  }
}
