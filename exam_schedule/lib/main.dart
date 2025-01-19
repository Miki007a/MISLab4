import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/calendar_screen.dart';
import 'services/exam_service.dart';
import 'services/location_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final notifications = FlutterLocalNotificationsPlugin();
  final examService = ExamService(prefs, notifications);
  await examService.initialize();
  
  final locationService = LocationService(examService);
  await locationService.startLocationTracking();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: examService),
        Provider.value(value: locationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Распоред на испити',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalendarScreen(),
    );
  }
}
