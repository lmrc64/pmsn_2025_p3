import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pmsn_2025_p3/database/sales_database.dart';
import 'package:pmsn_2025_p3/models/order_model.dart';
import 'package:pmsn_2025_p3/models/state_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Sales App')),
      ),
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
              children: _buildOrderListForSelectedDay(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadOrders() async {
    final orders =
        await _database.select<OrderModel>('order', OrderModel.fromMap);
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
      // Opcional: puedes obtener el nombre del estado si lo necesitas
      final stateName =
          _getStateName(order.stateId!); // crea esta función si quieres

      return ListTile(
        leading: Icon(Icons.circle, color: _getDotColor(stateName), size: 12),
        title: Text('Orden #${order.orderId} - Estado: $stateName'),
        subtitle: Text(
            'Fecha de la orden: ${order.date} \nFecha de entrega: ${order.dueDate}'),
      );
    }).toList();
  }

  String _getStateName(int stateId) {
    final state = _states.firstWhere(
      (s) => s.stateId == stateId,
      orElse: () => StateModel(stateId: 0, state: 'Desconocido'),
    );
    return state.state ?? 'Desconocido';
  }
}
