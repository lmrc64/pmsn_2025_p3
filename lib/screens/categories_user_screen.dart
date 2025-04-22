import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pmsn_2025_p3/database/sales_database.dart';
import 'package:pmsn_2025_p3/models/category_model.dart';
import 'package:pmsn_2025_p3/screens/cart_screen.dart';
import 'package:pmsn_2025_p3/screens/products_screen.dart';
import 'package:pmsn_2025_p3/utils/global_values.dart';

import 'package:path/path.dart' as path;
import 'package:short_navigation/short_navigation.dart';

class CategoriesUserScreen extends StatefulWidget {
  const CategoriesUserScreen({super.key});

  @override
  State<CategoriesUserScreen> createState() => _CategoriesUserScreenState();
}

class _CategoriesUserScreenState extends State<CategoriesUserScreen> {
  SalesDatabase? database;

  @override
  void initState() {
    super.initState();
    database = SalesDatabase();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future:
            database!.select<CategoryModel>('category', CategoryModel.fromMap),
        builder: (context, AsyncSnapshot<List<CategoryModel>> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (snapshot.hasData) {
            return GridView.builder(
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
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
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
                categoryName: category.category!,
                categoryId: category.categoryId!,
              ));
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
}
