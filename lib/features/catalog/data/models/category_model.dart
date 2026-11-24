import '../../domain/entities/category.dart';

final class CategoryModel extends Category {
  const CategoryModel({required super.id, required super.name, required super.iconName});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    try {
      return CategoryModel(id: json['id'] as String, name: json['name'] as String, iconName: json['iconName'] as String);
    } on TypeError catch (error) {
      throw FormatException('Category has an invalid structure.', error);
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name, 'iconName': iconName};
  }
}
