// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  runApp(AlarmApp());
}

class AlarmApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sanmays Alarm App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AlarmScreen(flutterLocalNotificationsPlugin),
    );
  }
}

class AlarmScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  AlarmScreen(this.flutterLocalNotificationsPlugin);

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleAlarm() async {
    final now = tz.TZDateTime.now(tz.local);
    final selectedDateTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'Alarm App',
      'Alarm App Notification Channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await widget.flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Alarm',
      'Wake up Bhai !',
      selectedDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm set for ${selectedDateTime.toString()} Bro'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    final initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null,
    );

    widget.flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Sanmay Alarm App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Selected Time: ${_selectedTime.format(context)}',
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: const Text('Select Time'),
            ),
            ElevatedButton(
              onPressed: () => _scheduleAlarm(),
              child: const Text('Set Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}