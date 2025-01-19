import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../models/exam.dart';
import '../services/exam_service.dart';
import 'add_exam_screen.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Exam> _exams = [];

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    final examService = Provider.of<ExamService>(context, listen: false);
    final exams = await examService.getExams();
    setState(() {
      _exams = exams;
    });
  }

  List<Exam> _getExamsForDay(DateTime day) {
    return _exams.where((exam) =>
        exam.dateTime.year == day.year &&
        exam.dateTime.month == day.month &&
        exam.dateTime.day == day.day).toList();
  }

  Future<void> _addExam() async {
    final result = await Navigator.push<Exam>(
      context,
      MaterialPageRoute(builder: (context) => const AddExamScreen()),
    );

    if (result != null) {
      final examService = Provider.of<ExamService>(context, listen: false);
      await examService.saveExam(result);
      await _loadExams();
    }
  }

  Future<void> _deleteExam(Exam exam) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Избриши испит'),
        content: Text('Дали сте сигурни дека сакате да го избришете испитот ${exam.subject}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Откажи'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Избриши'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final examService = Provider.of<ExamService>(context, listen: false);
      await examService.deleteExam(exam.id);
      await _loadExams();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Распоред на испити'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addExam,
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Exam>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getExamsForDay,
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
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Text('Изберете датум за да видите испити'),
                  )
                : ListView.builder(
                    itemCount: _getExamsForDay(_selectedDay!).length,
                    itemBuilder: (context, index) {
                      final exam = _getExamsForDay(_selectedDay!)[index];
                      return Dismissible(
                        key: Key(exam.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) => _deleteExam(exam),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            title: Text(exam.subject),
                            subtitle: Text(
                              '${DateFormat('HH:mm').format(exam.dateTime)}\n${exam.location}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.map),
                              onPressed: () {
                                // TODO: Navigate to map screen
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 