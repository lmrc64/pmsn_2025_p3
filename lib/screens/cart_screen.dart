import 'dart:io';

import 'package:badges/badges.dart' as badges;
import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:pmsn_2025_p3/database/sales_database.dart';
import 'package:pmsn_2025_p3/models/order_detail_model.dart';
import 'package:pmsn_2025_p3/models/product_model.dart';
import 'package:pmsn_2025_p3/screens/order_detail_user_screen.dart';
import 'package:pmsn_2025_p3/utils/global_values.dart';
import 'package:short_navigation/short_navigation.dart';

class CartScreen extends StatefulWidget {
  final String? dateInit;
  final String? dateFinal;
  final int? orderId;
  final int? categoryId;
  final String? categoryName;
  const CartScreen(
      {Key? key,
      this.categoryName,
      this.categoryId,
      this.orderId,
      this.dateInit,
      this.dateFinal})
      : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();

  SalesDatabase? database;
  // int _cartBadgeAmount = 6;
  bool _showCartBadge = GlobalValues.mountCart.value > 0;
  Color color = Colors.red;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    database = SalesDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName!),
        centerTitle: true,
        leading: badges.Badge(
          position: badges.BadgePosition.topEnd(top: 10, end: 10),
          child: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
        ),
        actions: <Widget>[
          ValueListenableBuilder(
            valueListenable: GlobalValues.mountCart,
            builder: (context, value, child) {
              return _shoppingCartBadge();
            },
          )
        ],
      ),
      endDrawer: Drawer(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
              // children: [
              //   Text("Carrito"),
              //   FutureBuilder(
              //     future: future,
              //     builder: (context, snapshot) {

              //     },)
              // ],
              ),
        ),
      ),
      body: FutureBuilder(
        // future: database!.select<ProductModel>('product', ProductModel.fromMap),
        future: database!.selectByColumn<ProductModel>(
          'product',
          'category_id',
          widget.categoryId!,
          ProductModel.fromMap,
        ),
        builder: (context, AsyncSnapshot<List<ProductModel>> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Ha ocurrido un error"),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return ItemProduct(product);
              },
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CardLoading(
                  height: 30,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  width: 100,
                  margin: EdgeInsets.only(bottom: 10),
                ),
                CardLoading(
                  height: 100,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  margin: EdgeInsets.only(bottom: 10),
                ),
                CardLoading(
                  height: 30,
                  width: 200,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  margin: EdgeInsets.only(bottom: 10),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget ItemProduct(ProductModel product) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.14,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 10, bottom: 15, left: 10, right: 10),
      padding: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
          color: Color.fromARGB(156, 216, 226, 225),
          borderRadius: BorderRadius.circular(10),
          border: BorderDirectional(
            end: BorderSide(
              color: Color.fromARGB(227, 167, 223, 217),
              width: 2,
            ),
            bottom: BorderSide(
              color: Color.fromARGB(227, 167, 223, 217),
              width: 2,
            ),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (product.image != null && product.image!.isNotEmpty)
            CircleAvatar(
              radius: 40,
              backgroundImage: FileImage(File(product.image!), scale: 2),
            )
          else
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.image),
            ),
          Column(
            spacing: 5,
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.product!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                width: 150,
                child: Text(
                  product.description!,
                  textAlign: TextAlign.start,
                  softWrap: true,
                ),
              ),
            ],
          ),
          Text("\$${product.price!}"),
          IconButton(
              onPressed: () {
                // GlobalValues.mountCart.value++;
                _addDetailDialog(context, product.productId!).then((value) {
                  _showCartBadge = GlobalValues.mountCart.value > 0;
                  setState(() {});
                });
              },
              icon: Icon(
                Icons.add_box_rounded,
                size: 30,
                color: Color.fromARGB(237, 59, 116, 77),
              ))
        ],
      ),
    );
  }

  Widget _shoppingCartBadge() {
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: -3, end: 2),
      badgeAnimation: badges.BadgeAnimation.slide(
          // disappearanceFadeAnimationDuration: Duration(milliseconds: 200),
          // curve: Curves.easeInCubic,
          ),
      showBadge: _showCartBadge,
      badgeStyle: badges.BadgeStyle(
        badgeColor: color,
      ),
      badgeContent: Text(
        GlobalValues.mountCart.value.toString(),
        style: TextStyle(color: Colors.white),
      ),
      child: IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: () {
            GoScale.to(OrderDetailUserScreen(orderId: widget.orderId!)).then(
              (value) {
                _showCartBadge = GlobalValues.mountCart.value > 0;
                setState(() {});
              },
            );
          }),
    );
  }

  Future<void> _addDetailDialog(BuildContext context, int productId,
      [OrderDetailModel? detail]) async {
    final quantityCtrl = TextEditingController(
      text: detail != null ? detail.quantity.toString() : '',
    );

    // final products = await database!.select<ProductModel>(
    //   'product',
    //   ProductModel.fromMap,
    // );

    // int? selectedProductId = detail?.productId ??
    //     (products.isNotEmpty ? products.first.productId : null);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(detail == null ? 'Agregar Detalle' : 'Editar Detalle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // DropdownButtonFormField<int>(
            //   value: selectedProductId,
            //   items: products.map((product) {
            //     return DropdownMenuItem<int>(
            //       value: product.productId,
            //       child: Text(product.product!),
            //     );
            //   }).toList(),
            //   onChanged: (value) {
            //     selectedProductId = value;
            //   },
            //   decoration: InputDecoration(labelText: 'Producto'),
            // ),
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
              if (quantity != null) {
                final data = {
                  'order_id': widget.orderId,
                  'product_id': productId,
                  'quantity': quantity,
                };
                if (detail == null) {
                  await database!.insert('order_detail', data);
                }

                GlobalValues.mountCart.value += quantity;
                Navigator.pop(context);
                // setState(() {});
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

  // Widget _addRemoveCartButtons() {
  //   return Row(
  //     // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: <Widget>[
  //       ElevatedButton.icon(
  //           onPressed: () => GlobalValues.mountCart.value++,
  //           icon: Icon(Icons.add),
  //           label: Text('Add to cart')),
  //       ElevatedButton.icon(
  //           onPressed: _showCartBadge
  //               ? () => setState(() {
  //                     _cartBadgeAmount--;
  //                     color = Colors.blue;
  //                   })
  //               : null,
  //           icon: Icon(Icons.remove),
  //           label: Text('Remove from cart')),
  //     ],
  //   );
  // }
}
