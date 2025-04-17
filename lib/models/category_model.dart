class CategoryModel {
  int? categoryId;
  String? category;
  String? image;

  CategoryModel({this.categoryId, this.category, this.image});

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
        categoryId: map['category_id'],
        category: map['category'],
        image: map['image']);
  }
}
