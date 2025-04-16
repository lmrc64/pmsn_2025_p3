class OrderModel {
  int? orderId;
  String? date;
  String? dueDate;
  int? stateId;

  OrderModel({this.orderId, this.date, this.dueDate, this.stateId});

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['order_id'],
      date: map['date'],
      dueDate: map['due_date'],
      stateId: map['state_id'],
    );
  }
}
