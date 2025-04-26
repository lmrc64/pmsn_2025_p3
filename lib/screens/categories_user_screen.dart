import 'dart:io';

import 'package:action_slider/action_slider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:pmsn_2025_p3/database/sales_database.dart';
import 'package:pmsn_2025_p3/models/category_model.dart';
import 'package:pmsn_2025_p3/screens/cart_screen.dart';
import 'package:pmsn_2025_p3/screens/dashboard_screen.dart';
import 'package:pmsn_2025_p3/screens/order_detail_user_screen.dart';
import 'package:pmsn_2025_p3/utils/global_values.dart';

// import 'package:path/path.dart' as path;
import 'package:short_navigation/short_navigation.dart';

class CategoriesUserScreen extends StatefulWidget {
  final int? orderId;
  final String? conDueDate;
  const CategoriesUserScreen({super.key, this.orderId, this.conDueDate});

  @override
  State<CategoriesUserScreen> createState() => _CategoriesUserScreenState();
}

class _CategoriesUserScreenState extends State<CategoriesUserScreen> {
  SalesDatabase? database;

  // int _cartBadgeAmount = GlobalValues.mountCart as int;
  bool _showCartBadge = GlobalValues.mountCart.value > 0;
  Color color = Colors.red;

  @override
  void initState() {
    super.initState();
    database = SalesDatabase();
    print(widget.conDueDate);
  }

  Widget build(BuildContext context) {
    _showCartBadge = GlobalValues.mountCart.value > 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
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
          // ValueListenableBuilder(child: _shoppingCartBadge()),
        ],
        // bottom: _tabBar(),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder(
          future: database!
              .select<CategoryModel>('category', CategoryModel.fromMap),
          builder: (context, AsyncSnapshot<List<CategoryModel>> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else if (snapshot.hasData) {
              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final category = snapshot.data![index];
                        return ItemCategory(category);
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 70),
                    child: ActionSlider.standard(
                      sliderBehavior: SliderBehavior.stretch,
                      width: 300.0,
                      backgroundColor: Colors.white,
                      toggleColor: Colors.redAccent,
                      action: (controller) async {
                        controller.loading(); //starts loading animation
                        await Future.delayed(const Duration(seconds: 2));
                        controller.success(); //starts success animation

                        await Future.delayed(const Duration(seconds: 1));
                        await database!
                            .delete('order', 'order_id', widget.orderId!);
                        Go.toRemoveUntil(DashboardScreen());
                        // controller.reset(); //resets the slider
                      },
                      child: const Text('Cancelar orden'),
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Widget ItemCategory(CategoryModel category) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              // Aquí puedes navegar o mostrar productos filtrados por categoría
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => CartScreen(
              //       categoryName: category.category!,
              //       categoryId: category.categoryId!,
              //     ),
              //   ),
              // );
              GoFade.to(CartScreen(
                orderId: widget.orderId,
                categoryName: category.category!,
                categoryId: category.categoryId!,
                dateFinal: widget.conDueDate,
              )).then(
                (value) {
                  // GlobalValues.mountCart.value = GlobalValues.mountCart.value;
                  // _showCartBadge = GlobalValues.mountCart.value > 0;
                  setState(() {});
                },
              );
            },
            child: category.image != null && category.image!.isNotEmpty
                ? CircleAvatar(
                    radius: 30,
                    backgroundImage: FileImage(File(category.image!)),
                  )
                : CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.category),
                  ),
          ),
          SizedBox(height: 10),
          Text(
            category.category ?? 'Sin nombre',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
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
        // _cartBadgeAmount.toString(),
        GlobalValues.mountCart.value.toString(),
        style: TextStyle(color: Colors.white),
      ),
      child: IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: () {
            GoScale.to(OrderDetailUserScreen(
                    conDueDate: widget.conDueDate, orderId: widget.orderId!))
                .then(
              (value) {
                _showCartBadge = GlobalValues.mountCart.value > 0;
                setState(() {});
              },
            );
          }),
    );
  }

  // Widget _addRemoveCartButtons() {
  //   return Row(
  //     // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: <Widget>[
  //       ElevatedButton.icon(
  //           onPressed: () => setState(() {
  //                 _cartBadgeAmount++;
  //                 if (color == Colors.blue) {
  //                   color = Colors.red;
  //                 }
  //               }),
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
