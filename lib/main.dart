import "package:flutter/material.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:timezone/data/latest.dart";
import "package:timezone/timezone.dart";


void main() {
  runApp(AlarmApp());
}

class AlarmApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  AlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sanmay's Alarm App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AlarmScreen(flutterLocalNotificationsPlugin),
    );
  }
}

class AlarmScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const AlarmScreen(this.flutterLocalNotificationsPlugin, {super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
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
    final now = TZDateTime.now(local);
    final selectedDateTime = TZDateTime(
      local,
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      "Alarm App Notification Channel",
      "Something",
      "Description",
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await widget.flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      "Alarm",
      "Wake up Bhai !",
      selectedDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Alarm set for ${selectedDateTime.toString()} Bro"),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initializeTimeZones();
    const initializationSettingsAndroid =
    AndroidInitializationSettings("@mipmap/ic_launcher");
    const initializationSettings = InitializationSettings(
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
        title: const Text("Sanmay's Alarm App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Selected Time: ${_selectedTime.format(context)}",
              style: const TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: const Text("Select Time"),
            ),
            ElevatedButton(
              onPressed: () => _scheduleAlarm(),
              child: const Text("Set Alarm"),
            ),
          ],
        ),
      ),
    );
  }
}
