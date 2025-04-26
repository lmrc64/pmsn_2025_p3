import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pmsn_2025_p3/screens/cart_screen.dart';
import 'package:pmsn_2025_p3/screens/categories_screen.dart';
import 'package:pmsn_2025_p3/screens/categories_user_screen.dart';
import 'package:pmsn_2025_p3/screens/order_detail_screen.dart';
import 'package:pmsn_2025_p3/utils/global_values.dart';
import 'package:short_navigation/short_navigation.dart';
//import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pmsn_2025_p3/database/sales_database.dart';
import 'package:pmsn_2025_p3/models/order_model.dart';
import 'package:pmsn_2025_p3/models/state_model.dart';

class DashboardScreen extends StatefulWidget {
  final int? stateId;
  const DashboardScreen({super.key, this.stateId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SalesDatabase _database = SalesDatabase();
  Map<DateTime, List<OrderModel>> _events = {};
  List<StateModel> _states = [];

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  SalesDatabase? database;

  int? _selectedStateId;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    database = SalesDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales App'),
        centerTitle: true,
      ),
      // endDrawer: DropdownButtonFormField<int>(
      //   hint: Text('Filtrar por estado'),
      //   isExpanded: true,
      //   items: [
      //     DropdownMenuItem(value: null, child: Text('Todas')),
      //     DropdownMenuItem(value: 1, child: Text('Por cumplir')),
      //     DropdownMenuItem(value: 2, child: Text('Cancelado')),
      //     DropdownMenuItem(value: 3, child: Text('Completado'))
      //   ],
      //   onChanged: (value) {
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => DashboardScreen(
      //           stateId: value,
      //         ),
      //       ),
      //     );
      //   },
      // ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              onTap: () => Navigator.pushNamed(context, "/categories"),
              leading: Icon(Icons.category),
              title: Text('Categories Screen'),
              trailing: Icon(Icons.chevron_right),
            ),
            ListTile(
              onTap: () => Navigator.pushNamed(context, "/products"),
              leading: Icon(Icons.shopping_cart),
              title: Text('Products Screen'),
              trailing: Icon(Icons.chevron_right),
            ),
            ListTile(
              onTap: () => Navigator.pushNamed(context, "/orders"),
              leading: Icon(Icons.book),
              title: Text('Orders Screen'),
              trailing: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisSize: MainAxisSize.,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 211, 211, 209)),
                onPressed: () {
                  _orderDialogBuilder(context);
                },
                child: Row(
                  spacing: 5,
                  children: [
                    Icon(Icons.add),
                    Text('Agregar orden'),
                  ],
                ),
              ),
              Container(
                height: 60,
                width: 140,
                // margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                    // color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                    // border: Border.all(color: Colors.blue, width: 1),
                    border: BorderDirectional(
                      end: BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                      bottom: BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    )),
                child: DropdownButtonFormField<int>(
                  icon: Icon(Icons.filter_list_alt),

                  alignment: Alignment.centerRight,
                  decoration: InputDecoration(
                    // labelText: 'Filtrar por estado',
                    border: InputBorder.none,
                  ),
                  // hint: Text('Filtrar por estado'),

                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: null, child: Text('Todas')),
                    DropdownMenuItem(value: 1, child: Text('Por cumplir')),
                    DropdownMenuItem(value: 2, child: Text('Cancelado')),
                    DropdownMenuItem(value: 3, child: Text('Completado'))
                  ],
                  onChanged: (value) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardScreen(
                          stateId: value,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              if (_getEventsForDay(selectedDay).isNotEmpty) {
                _dialogBuilder(context);
              }
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final ordersForDay = _getEventsForDay(date);
                if (ordersForDay.isEmpty) return SizedBox();

                return Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ordersForDay.map((order) {
                      final stateName = _getStateName(order.stateId!);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.5),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getDotColor(stateName),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),

          //  Lista de órdenes para el día seleccionado
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: _buildNoOrders(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero, // Quita márgenes
          child: Scaffold(
            appBar: AppBar(
              title: Text('Órdenes del día'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            body: ListView(
              padding: EdgeInsets.all(16),
              children: _buildOrderListForSelectedDay(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadOrders() async {
    var orders =
        await _database.select<OrderModel>('order', OrderModel.fromMap);
    if (widget.stateId != null) {
      orders = await _database.selectByColumn<OrderModel>(
        'order',
        'state_id',
        widget.stateId!,
        OrderModel.fromMap,
      );
    }
    final states =
        await _database.select<StateModel>('state', StateModel.fromMap);

    Map<DateTime, List<OrderModel>> events = {};

    for (var order in orders) {
      final parsedDate = DateTime.parse(order.dueDate!);
      final date = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

      events.putIfAbsent(date, () => []).add(order);
    }

    setState(() {
      _events = events;
      _states = states;
    });
  }

  List<OrderModel> _getEventsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  Color _getDotColor(String state) {
    switch (state) {
      case 'Por cumplir':
        return Colors.green;
      case 'Cancelado':
        return Colors.red;
      case 'Completado':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  List<Widget> _buildOrderListForSelectedDay() {
    if (_selectedDay == null) return [];

    final selectedDate =
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final ordersThatDay = _events[selectedDate] ?? [];

    if (ordersThatDay.isEmpty) {
      return [
        ListTile(
          title: Text('No hay órdenes para este día'),
          leading: Icon(Icons.info_outline),
        ),
      ];
    }

    return ordersThatDay.map((order) {
      final stateName = _getStateName(order.stateId!);

      return ListTile(
        leading: Icon(Icons.circle, color: _getDotColor(stateName), size: 12),
        title: Text('Orden #${order.orderId} - Estado: $stateName'),
        subtitle: Text(
          'Fecha de la orden: ${order.date} \nFecha de entrega: ${order.dueDate}',
        ),
        trailing: IconButton(
          icon: Icon(Icons.remove_red_eye, color: Colors.grey),
          tooltip: 'Ver detalles',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(orderId: order.orderId!),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  List<Widget> _buildNoOrders() {
    _selectedDay ??= DateTime.now();

    final selectedDate =
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final ordersThatDay = _events[selectedDate] ?? [];

    if (ordersThatDay.isEmpty) {
      return [
        ListTile(
          title: Text('No hay órdenes para este día'),
          leading: Icon(Icons.info_outline),
        ),
      ];
    }

    return [];
  }

  String _getStateName(int stateId) {
    final state = _states.firstWhere(
      (s) => s.stateId == stateId,
      orElse: () => StateModel(stateId: 0, state: 'Desconocido'),
    );
    return state.state ?? 'Desconocido';
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

    conDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nueva Orden'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              readOnly: true,
              controller: conDate,
              decoration: InputDecoration(labelText: 'Fecha de Orden'),
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
                int? lastID;
                if (id == 0) {
                  lastID = await database!.insert('order', data);
                }
                // print(lastID);
                // Navigator.pop(context);
                // GoSize.to(CartScreen(dateInit:  conDate.text, dateFinal: conDueDate.text));
                GoSize.to(CategoriesUserScreen(
                        conDueDate: conDueDate.text, orderId: lastID))
                    .then(
                  (value) {
                    GlobalValues.mountCart.value = 0;
                    setState(() {});
                  },
                );
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
