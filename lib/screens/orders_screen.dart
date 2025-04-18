import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pmsn_2025_p3/database/sales_database.dart';
import 'package:pmsn_2025_p3/models/order_model.dart';
import 'package:pmsn_2025_p3/models/state_model.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  SalesDatabase? database;

  @override
  void initState() {
    super.initState();
    database = SalesDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: const Text('Orders'))),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _orderDialogBuilder(context),
      ),
      body: FutureBuilder(
        future: Future.wait([
          database!.select<OrderModel>('order', OrderModel.fromMap),
          database!.select<StateModel>('state', StateModel.fromMap),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            final orders = snapshot.data![0] as List<OrderModel>;
            final states = snapshot.data![1] as List<StateModel>;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final state = states.firstWhere(
                  (s) => s.stateId == order.stateId,
                  orElse: () => StateModel(stateId: 0, state: 'Desconocido'),
                );

                return Card(
                  color: getColorByState(state.state),
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Fecha: ${order.date}'),
                    subtitle: Text(
                      'Entrega: ${order.dueDate}\nEstado: ${state.state}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _orderDialogBuilder(
                              context, order.orderId!, order),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await ArtSweetAlert.show(
                              context: context,
                              artDialogArgs: ArtDialogArgs(
                                type: ArtSweetAlertType.warning,
                                title: "¿Eliminar orden?",
                                text: "Esta acción no se puede deshacer",
                                showCancelBtn: true,
                              ),
                            );
                            if (confirm?.isTapConfirmButton ?? false) {
                              await database!
                                  .delete('order', 'order_id', order.orderId!);
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> _orderDialogBuilder(BuildContext context,
      [int id = 0, OrderModel? order]) async {
    TextEditingController conDate =
        TextEditingController(text: order?.date ?? '');
    TextEditingController conDueDate =
        TextEditingController(text: order?.dueDate ?? '');
    int? selectedStateId = order?.stateId;

    List<StateModel> states = await database!.select<StateModel>(
      'state',
      StateModel.fromMap,
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == 0 ? 'Nueva Orden' : 'Editar Orden'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              readOnly: true,
              controller: conDate,
              decoration: InputDecoration(labelText: 'Fecha'),
              onTap: () async {
                DateTime? datePicked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (datePicked != null) {
                  conDate.text = DateFormat('yyyy-MM-dd').format(datePicked);
                }
              },
            ),
            TextFormField(
              readOnly: true,
              controller: conDueDate,
              decoration: InputDecoration(labelText: 'Fecha de Entrega'),
              onTap: () async {
                DateTime? datePicked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (datePicked != null) {
                  conDueDate.text = DateFormat('yyyy-MM-dd').format(datePicked);
                }
              },
            ),
            DropdownButtonFormField<int>(
              value: states.any((s) => s.stateId == selectedStateId)
                  ? selectedStateId
                  : null,
              items: states.map((s) {
                return DropdownMenuItem<int>(
                  value: s.stateId,
                  child: Text(s.state ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                selectedStateId = value;
              },
              decoration: InputDecoration(labelText: 'Estado'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (conDate.text.isNotEmpty &&
                  conDueDate.text.isNotEmpty &&
                  selectedStateId != null) {
                final data = {
                  'date': conDate.text,
                  'due_date': conDueDate.text,
                  'state_id': selectedStateId,
                };

                if (id == 0) {
                  await database!.insert('order', data);
                } else {
                  data['order_id'] = id;
                  await database!.update('order', data, 'order_id');
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

  Color getColorByState(String? stateName) {
    switch (stateName) {
      case 'Por cumplir':
        return Colors.green.shade100;
      case 'Cancelado':
        return Colors.red.shade100;
      case 'Completado':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}
