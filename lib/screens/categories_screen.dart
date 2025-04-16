import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:pmsn_2025_p3/database/sales_database.dart';
import 'package:pmsn_2025_p3/models/category_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  SalesDatabase? database;

  @override
  @override
  void initState() {
    super.initState();
    database = SalesDatabase();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
        ),
        onPressed: () {
          _categoryDialogBuilder(context);
        },
      ),
      appBar: AppBar(
        title: Center(
          child: const Text('Categories'),
        ),
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
            return Center(child: Text('No categories has been found'));
          }
        },
      ),
    );
  }

  Widget ItemCategory(CategoryModel category) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(8),
      child: Center(
        child: Text(
          category.category ?? 'Sin nombre',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _categoryDialogBuilder(BuildContext context, [int id = 0]) {
    TextEditingController conCategory = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == 0 ? 'Agregar categoría' : 'Editar categoría'),
          content: Container(
            height: 200,
            width: 300,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextFormField(
                  controller: conCategory,
                  decoration: InputDecoration(
                    hintText: 'Nombre de la categoría',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (conCategory.text.isNotEmpty) {
                      if (id == 0) {
                        database!.insert('category', {
                          'category': conCategory.text,
                          'image': null, // o algún valor por defecto
                        }).then((value) {
                          if (value > 0) {
                            setState(() {
                              // refrescar pantalla
                            });
                            Navigator.pop(context);
                            ArtSweetAlert.show(
                              context: context,
                              artDialogArgs: ArtDialogArgs(
                                type: ArtSweetAlertType.success,
                                title: 'Categoría',
                                text: 'Categoría agregada exitosamente',
                              ),
                            );
                          }
                        });
                      } else {
                        database!
                            .update(
                                'category',
                                {
                                  'category_id': id,
                                  'category': conCategory.text,
                                  'image': null,
                                },
                                'category_id')
                            .then((value) {
                          if (value > 0) {
                            setState(() {});
                            Navigator.pop(context);
                            ArtSweetAlert.show(
                              context: context,
                              artDialogArgs: ArtDialogArgs(
                                type: ArtSweetAlertType.success,
                                title: 'Categoría',
                                text: 'Categoría actualizada correctamente',
                              ),
                            );
                          }
                        });
                      }
                    }
                  },
                  child: Text('Guardar'),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
