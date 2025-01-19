import 'package:exam_scheduler/models/exam.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:exam_scheduler/screens/add_exam_screen.dart'; // Import the AddExamScreen

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Map<DateTime, List<exam>> _events;
  late List<exam> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedEvents = [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedEvents = _events[selectedDay] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Распоред за полагање'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to AddExamScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExamScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: DateTime.now(),
            selectedDayPredicate: (day) => isSameDay(day, DateTime.now()),
            onDaySelected: _onDaySelected,
            eventLoader: (day) {
              return _events[day] ?? [];
            },
          ),
          Expanded(
            child: ListView(
              children: _selectedEvents.map((exam) => ListTile(
                title: Text(exam.subject),
                subtitle: Text('Локација: ${exam.location}'),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
