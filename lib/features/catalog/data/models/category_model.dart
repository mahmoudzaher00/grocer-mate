import '../../domain/entities/category.dart';

final class CategoryModel extends Category {
  const CategoryModel({required super.id, required super.name, required super.iconName});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final iconName = json['iconName'];

    if (id is! String || id.trim().isEmpty) {
      throw const FormatException('Category id must be a non-empty string.');
    }
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Category name must be a non-empty string.');
    }
    if (iconName is! String || iconName.trim().isEmpty) {
      throw const FormatException('Category iconName must be a non-empty string.');
    }

    return CategoryModel(id: id.trim(), name: name.trim(), iconName: iconName.trim());
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name, 'iconName': iconName};
  }
}
