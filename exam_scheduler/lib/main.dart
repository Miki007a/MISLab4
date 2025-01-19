import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/calendar_screen.dart';
import 'providers/exam_schedule_provider.dart';
import 'screens/add_exam_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExamScheduleProvider(),
      child: MaterialApp(
        title: 'Студентски распоред',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: CalendarPage(),
        routes: {
          '/add_exam': (context) => AddExamScreen(),
        },
      ),
    );
  }
}
