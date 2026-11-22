part of 'bloc.dart';

sealed class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

final class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

final class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

final class CategoriesSuccess extends CategoriesState {
  CategoriesSuccess(List<Category> categories) : categories = List<Category>.unmodifiable(categories);

  final List<Category> categories;

  @override
  List<Object?> get props => [categories];
}

final class CategoriesEmpty extends CategoriesState {
  const CategoriesEmpty();
}

final class CategoriesError extends CategoriesState {
  const CategoriesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
