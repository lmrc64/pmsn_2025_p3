import 'package:flutter/material.dart';
import 'package:pmsn_2025_p3/screens/categories_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: CategoriesScreen(),
    );
  }
}
