class OrderDetailModel {
  int? orderDetailId;
  int? orderId;
  int? productId;
  int? quantity;

  OrderDetailModel({
    this.orderDetailId,
    this.orderId,
    this.productId,
    this.quantity,
  });

  factory OrderDetailModel.fromMap(Map<String, dynamic> map) {
    return OrderDetailModel(
      orderDetailId: map['order_detail_id'],
      orderId: map['order_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
    );
  }
}
