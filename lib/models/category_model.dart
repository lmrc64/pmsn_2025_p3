class CategoryModel {
  int? categoryId;
  String? category;

  CategoryModel({this.categoryId, this.category});

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      categoryId: map['category_id'],
      category: map['category'],
    );
  }
}
