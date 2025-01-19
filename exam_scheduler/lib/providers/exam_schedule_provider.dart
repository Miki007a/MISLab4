import 'package:flutter/material.dart';
import '../models/exam.dart';

class ExamScheduleProvider with ChangeNotifier {
  List<exam> _examSchedules = [];

  List<exam> get examSchedules => _examSchedules;

  void addExam(exam exam) {
    _examSchedules.add(exam);
    notifyListeners();
  }
}
