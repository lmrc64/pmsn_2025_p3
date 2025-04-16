class ProductModel {
  int? productId;
  String? product;
  String? description;
  double? price;
  String? image;
  int? categoryId;

  ProductModel({
    this.productId,
    this.product,
    this.description,
    this.price,
    this.image,
    this.categoryId,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['product_id'],
      product: map['product'],
      description: map['description'],
      price: map['price'],
      image: map['image'],
      categoryId: map['category_id'],
    );
  }
}
