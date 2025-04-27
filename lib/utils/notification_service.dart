import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Monterrey'));
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

Future<void> showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'Hola',
    'Mira esto',
    importance: Importance.max,
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    1,
    'Hello, World!',
    'This is a notification message.',
    platformChannelSpecifics,
  );
}

Future<void> notificationProgramada(
  DateTime fechaHora,
  String dueDate,
) async {
  // print("desde notificacion programada");
  // print(fechaHora);
  // print(tz.local);
  print(tz.TZDateTime.from(fechaHora, tz.local));
  final BigTextStyleInformation bigTextStyleInformation =
      BigTextStyleInformation(
    '''
        <p>
        Usted tiene una orden para el día: <b>$dueDate</b> <br>
        Recuerde revisar el estado de la orden
        </p>      
    ''',
    htmlFormatBigText: true,
    contentTitle: '<b>Recordatorio de Orden</b>',
    htmlFormatContentTitle: true,
    summaryText: 'Recordatorio de Orden',
    htmlFormatSummaryText: true,
  );
  await flutterLocalNotificationsPlugin.zonedSchedule(
    DateTime.now().second * DateTime.now().millisecond,
    "Recordatorio de Orden",
    "Fecha Orden: <b>$dueDate</b>",
    tz.TZDateTime.from(fechaHora, tz.local),
    NotificationDetails(
      android: AndroidNotificationDetails(
        '10',
        'Adrian',
        channelDescription: 'NPI',
        styleInformation: bigTextStyleInformation,
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}
