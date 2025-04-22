import 'dart:io';

import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:pmsn_2025_p3/database/sales_database.dart';
import 'package:pmsn_2025_p3/models/product_model.dart';
import 'package:short_navigation/short_navigation.dart';

class CartScreen extends StatefulWidget {
  final String? dateInit;
  final String? dateFinal;
  final int? categoryId;
  final String? categoryName;
  const CartScreen(
      {Key? key,
      this.categoryName,
      this.categoryId,
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
  // final String date = widget.dateInit;
  // final String dueDate = widget.dateFinal;

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
              onPressed: () {},
              icon: Icon(
                Icons.add_box_rounded,
                size: 30,
                color: Color.fromARGB(237, 59, 116, 77),
              ))
        ],
      ),
    );
  }
}
