import 'package:flutter/material.dart';
import 'package:pmsn_2025_p3/database/sales_database.dart';
import 'package:pmsn_2025_p3/models/order_detail_model.dart';
import 'package:pmsn_2025_p3/models/product_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  SalesDatabase? database;

  @override
  void initState() {
    super.initState();
    database = SalesDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle de Orden #${widget.orderId}')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addOrEditDetailDialog(context),
      ),
      body: FutureBuilder(
          future: Future.wait([
            database!.selectByColumn<OrderDetailModel>(
              'order_detail',
              'order_id',
              widget.orderId,
              OrderDetailModel.fromMap,
            ),
            database!.select<ProductModel>('product', ProductModel.fromMap),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final details = snapshot.data![0] as List<OrderDetailModel>;
              final products = snapshot.data![1] as List<ProductModel>;

              double totalOrden = 0;

              final items = details.map((detail) {
                final product = products.firstWhere(
                  (p) => p.productId == detail.productId,
                  orElse: () => ProductModel(
                      productId: detail.productId,
                      product: 'Desconocido',
                      price: 0.0),
                );

                final subtotal =
                    (product.price ?? 0.0) * (detail.quantity ?? 0);
                totalOrden += subtotal;

                return ListTile(
                  title: Text(product.product!),
                  subtitle: Text(
                      'Cantidad: ${detail.quantity}  •  Precio unitario: \$${product.price?.toStringAsFixed(2) ?? '0.00'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\$${subtotal.toStringAsFixed(2)}'),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await database!.delete(
                            'order_detail',
                            'order_detail_id',
                            detail.orderDetailId!,
                          );
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              }).toList();

              return Column(
                children: [
                  Expanded(child: ListView(children: items)),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('\$${totalOrden.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Future<void> _addOrEditDetailDialog(BuildContext context,
      [OrderDetailModel? detail]) async {
    final quantityCtrl = TextEditingController(
      text: detail != null ? detail.quantity.toString() : '',
    );

    final products = await database!.select<ProductModel>(
      'product',
      ProductModel.fromMap,
    );

    int? selectedProductId = detail?.productId ??
        (products.isNotEmpty ? products.first.productId : null);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(detail == null ? 'Agregar Detalle' : 'Editar Detalle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: selectedProductId,
              items: products.map((product) {
                return DropdownMenuItem<int>(
                  value: product.productId,
                  child: Text(product.product!),
                );
              }).toList(),
              onChanged: (value) {
                selectedProductId = value;
              },
              decoration: InputDecoration(labelText: 'Producto'),
            ),
            TextFormField(
              controller: quantityCtrl,
              decoration: InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final quantity = int.tryParse(quantityCtrl.text);

              if (selectedProductId != null && quantity != null) {
                final data = {
                  'order_id': widget.orderId,
                  'product_id': selectedProductId,
                  'quantity': quantity,
                };

                if (detail == null) {
                  await database!.insert('order_detail', data);
                } else {
                  data['order_detail_id'] = detail.orderDetailId!;
                  await database!
                      .update('order_detail', data, 'order_detail_id');
                }

                Navigator.pop(context);
                setState(() {});
              }
            },
            child: Text('Guardar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
