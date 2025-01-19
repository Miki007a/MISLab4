import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/exam.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class ExamService {
  static const String _storageKey = 'exams';
  final SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _notifications;
  
  ExamService(this._prefs, this._notifications);

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notifications.initialize(initializationSettings);
  }

  Future<List<Exam>> getExams() async {
    final String? examsJson = _prefs.getString(_storageKey);
    if (examsJson == null) return [];

    final List<dynamic> examsList = json.decode(examsJson);
    return examsList.map((e) => Exam.fromJson(e)).toList();
  }

  Future<void> saveExam(Exam exam) async {
    final exams = await getExams();
    exams.add(exam);
    await _prefs.setString(_storageKey, json.encode(exams.map((e) => e.toJson()).toList()));
    await _scheduleNotification(exam);
  }

  Future<void> deleteExam(String id) async {
    final exams = await getExams();
    exams.removeWhere((exam) => exam.id == id);
    await _prefs.setString(_storageKey, json.encode(exams.map((e) => e.toJson()).toList()));
  }

  Future<void> _scheduleNotification(Exam exam) async {
    final androidDetails = AndroidNotificationDetails(
      'exam_schedule',
      'Exam Schedule',
      channelDescription: 'Notifications for exam schedule',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    final notificationDetails = NotificationDetails(android: androidDetails);
    
    // Schedule notification 1 hour before exam
    final scheduledDate = exam.dateTime.subtract(const Duration(hours: 1));
    if (scheduledDate.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        exam.id.hashCode,
        'Потсетник за испит',
        '${exam.subject} започнува за 1 час во ${exam.location}',
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> checkLocationAndNotify(Exam exam) async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        exam.latitude,
        exam.longitude,
      );

      // If within 500 meters of exam location
      if (distance <= 500) {
        final androidDetails = AndroidNotificationDetails(
          'exam_location',
          'Location Alerts',
          channelDescription: 'Location-based notifications for exams',
          importance: Importance.max,
          priority: Priority.high,
        );
        
        final notificationDetails = NotificationDetails(android: androidDetails);
        
        await _notifications.show(
          exam.id.hashCode + 1,
          'Близу сте до локацијата на испитот',
          '${exam.subject} е закажан за ${exam.dateTime.hour}:${exam.dateTime.minute} во ${exam.location}',
          notificationDetails,
        );
      }
    } catch (e) {
      // Handle location errors silently
    }
  }
} 