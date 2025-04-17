import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pmsn_2025_p3/database/sales_database.dart';
import 'package:pmsn_2025_p3/models/category_model.dart';
import 'package:pmsn_2025_p3/utils/global_values.dart';

import 'package:path/path.dart' as path;

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  SalesDatabase? database;

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
          if (category.image != null && category.image!.isNotEmpty)
            CircleAvatar(
              radius: 30,
              backgroundImage: FileImage(File(category.image!)),
            )
          else
            CircleAvatar(
              radius: 30,
              child: Icon(Icons.category),
            ),
          SizedBox(height: 10),
          Text(
            category.category ?? 'Sin nombre',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.lightBlueAccent),
                onPressed: () {
                  _categoryDialogBuilder(
                      context, category.categoryId ?? 0, category);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await ArtSweetAlert.show(
                    context: context,
                    artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.warning,
                      title: "¿Estás seguro?",
                      text: "Esta acción eliminará la categoría",
                      showCancelBtn: true,
                    ),
                  );

                  if (confirm?.isTapConfirmButton ?? false) {
                    await database!.delete(
                      'category',
                      'category_id',
                      category.categoryId!,
                    );
                    setState(() {});
                    ArtSweetAlert.show(
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.success,
                        title: 'Eliminado',
                        text: 'Categoría eliminada correctamente',
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _categoryDialogBuilder(BuildContext context,
      [int id = 0, CategoryModel? category]) {
    GlobalValues.userImage.value = null;

    TextEditingController conCategory = TextEditingController(
      text: category?.category ?? '',
    );

    if (category?.image != null && category!.image!.isNotEmpty) {
      GlobalValues.userImage.value = File(category.image!);
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == 0 ? 'Agregar categoría' : 'Editar categoría'),
          content: Container(
            height: 250,
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
                GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      child: ValueListenableBuilder<File?>(
                        valueListenable: GlobalValues.userImage,
                        builder: (context, value, child) {
                          return CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                value == null ? null : FileImage(value),
                            child: value == null
                                ? Icon(Icons.camera_alt,
                                    size: 40, color: Colors.grey[600])
                                : null,
                          );
                        },
                      )),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (conCategory.text.isNotEmpty) {
                      if (id == 0) {
                        // INSERTAR NUEVA CATEGORÍA
                        database!.insert('category', {
                          'category': conCategory.text,
                          'image': GlobalValues.userImage.value?.path ?? '',
                        }).then((value) {
                          if (value > 0) {
                            GlobalValues.userImage.value = null;
                            setState(() {});
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
                        // ACTUALIZAR CATEGORÍA EXISTENTE
                        database!
                            .update(
                          'category',
                          {
                            'category_id': id,
                            'category': conCategory.text,
                            'image': GlobalValues.userImage.value?.path ?? '',
                          },
                          'category_id',
                        )
                            .then((value) {
                          if (value > 0) {
                            GlobalValues.userImage.value = null;
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

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galería'),
              onTap: () {
                _pickImageFromSource(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Cámara'),
              onTap: () {
                _pickImageFromSource(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();

      final filename =
          'img_${DateTime.now().millisecondsSinceEpoch}${path.extension(pickedFile.path)}';

      final savedImage =
          await File(pickedFile.path).copy('${directory.path}/$filename');

      GlobalValues.userImage.value = savedImage;
    }
  }
}
