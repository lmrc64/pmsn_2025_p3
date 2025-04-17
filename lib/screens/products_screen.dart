import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pmsn_2025_p3/database/sales_database.dart';
import 'package:pmsn_2025_p3/models/category_model.dart';
import 'package:pmsn_2025_p3/models/product_model.dart';
import 'package:pmsn_2025_p3/utils/global_values.dart';

import 'package:path/path.dart' as path;

class ProductsScreen extends StatefulWidget {
  final int? categoryId;

  const ProductsScreen({super.key, this.categoryId});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
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
          _productDialogBuilder(context);
        },
      ),
      appBar: AppBar(
        title: Center(
          child: const Text('Products'),
        ),
      ),
      body: FutureBuilder(
        future: widget.categoryId != null
            ? database!.selectByColumn<ProductModel>(
                'product',
                'category_id',
                widget.categoryId!,
                ProductModel.fromMap,
              )
            : database!.select<ProductModel>('product', ProductModel.fromMap),
        builder: (context, AsyncSnapshot<List<ProductModel>> snapshot) {
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
                final product = snapshot.data![index];
                return ItemProduct(product);
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

  Widget ItemProduct(ProductModel product) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (product.image != null && product.image!.isNotEmpty)
            CircleAvatar(
              radius: 30,
              backgroundImage: FileImage(File(product.image!)),
            )
          else
            CircleAvatar(
              radius: 30,
              child: Icon(Icons.image),
            ),
          SizedBox(height: 5),
          Text(
            product.product ?? 'Producto sin nombre',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            '\$${product.price?.toStringAsFixed(2) ?? '0.00'}',
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.lightBlueAccent),
                onPressed: () {
                  //print(product.categoryId);
                  _productDialogBuilder(
                    context,
                    product.productId ?? 0,
                    product,
                  );
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
                      text: "Esta acción eliminará el producto",
                      showCancelBtn: true,
                    ),
                  );

                  if (confirm?.isTapConfirmButton ?? false) {
                    await database!.delete(
                      'product',
                      'product_id',
                      product.productId!,
                    );
                    setState(() {});
                    ArtSweetAlert.show(
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.success,
                        title: 'Eliminado',
                        text: 'Producto eliminado correctamente',
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

  Future<void> _productDialogBuilder(BuildContext context,
      [int id = 0, ProductModel? product]) async {
    GlobalValues.userImage.value = null;

    TextEditingController conProduct =
        TextEditingController(text: product?.product ?? '');
    TextEditingController conDescription =
        TextEditingController(text: product?.description ?? '');
    TextEditingController conPrice =
        TextEditingController(text: product?.price?.toString() ?? '');

    int? selectedCategoryId = product?.categoryId;

    // Si el producto tiene imagen, precargarla
    if (product?.image != null && product!.image!.isNotEmpty) {
      GlobalValues.userImage.value = File(product.image!);
    }

    // Obtener lista de categorías (para el dropdown)
    List<CategoryModel> categories = await database!.select<CategoryModel>(
      'category',
      CategoryModel.fromMap,
    );

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == 0 ? 'Agregar producto' : 'Editar producto'),
          content: Container(
            width: 300,
            height: 460,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: conProduct,
                    decoration:
                        InputDecoration(labelText: 'Nombre del producto'),
                  ),
                  TextFormField(
                    controller: conDescription,
                    decoration: InputDecoration(labelText: 'Descripción'),
                  ),
                  TextFormField(
                    controller: conPrice,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Precio'),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: categories
                            .any((cat) => cat.categoryId == selectedCategoryId)
                        ? selectedCategoryId
                        : null,
                    items: categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat.categoryId,
                        child: Text(cat.category ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedCategoryId = value;
                    },
                    decoration: InputDecoration(labelText: 'Categoría'),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: ValueListenableBuilder<File?>(
                      valueListenable: GlobalValues.userImage,
                      builder: (context, value, child) {
                        return CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              value != null ? FileImage(value) : null,
                          child: value == null
                              ? Icon(Icons.camera_alt,
                                  size: 40, color: Colors.grey[600])
                              : null,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (conProduct.text.isNotEmpty &&
                          conPrice.text.isNotEmpty) {
                        double? price = double.tryParse(conPrice.text);

                        if (id == 0) {
                          // Insertar producto nuevo
                          database!.insert('product', {
                            'product': conProduct.text,
                            'description': conDescription.text,
                            'price': price ?? 0.0,
                            'image': GlobalValues.userImage.value?.path ?? '',
                            'category_id': selectedCategoryId ?? 0,
                          }).then((value) {
                            if (value > 0) {
                              GlobalValues.userImage.value = null;
                              Navigator.pop(context);
                              setState(() {});
                              ArtSweetAlert.show(
                                context: context,
                                artDialogArgs: ArtDialogArgs(
                                  type: ArtSweetAlertType.success,
                                  title: 'Producto',
                                  text: 'Producto agregado correctamente',
                                ),
                              );
                            }
                          });
                        } else {
                          // Actualizar producto
                          database!
                              .update(
                                  'product',
                                  {
                                    'product_id': id,
                                    'product': conProduct.text,
                                    'description': conDescription.text,
                                    'price': price ?? 0.0,
                                    'image':
                                        GlobalValues.userImage.value?.path ??
                                            '',
                                    'category_id': selectedCategoryId ?? 0,
                                  },
                                  'product_id')
                              .then((value) {
                            if (value > 0) {
                              GlobalValues.userImage.value = null;
                              Navigator.pop(context);
                              setState(() {});
                              ArtSweetAlert.show(
                                context: context,
                                artDialogArgs: ArtDialogArgs(
                                  type: ArtSweetAlertType.success,
                                  title: 'Producto',
                                  text: 'Producto actualizado correctamente',
                                ),
                              );
                            }
                          });
                        }
                      }
                    },
                    child: Text('Guardar'),
                  ),
                ],
              ),
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
