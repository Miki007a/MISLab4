import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'exam_service.dart';

class LocationService {
  final ExamService _examService;
  Timer? _locationTimer;

  LocationService(this._examService);

  Future<void> startLocationTracking() async {
    // Request location permission
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return;
    }

    // Check location service status
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Start periodic location check
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      final exams = await _examService.getExams();
      final now = DateTime.now();
      
      // Check only upcoming exams within next 24 hours
      final upcomingExams = exams.where((exam) {
        final difference = exam.dateTime.difference(now);
        return difference.isNegative == false && difference.inHours <= 24;
      });

      // Check location for each upcoming exam
      for (final exam in upcomingExams) {
        await _examService.checkLocationAndNotify(exam);
      }
    });
  }

  void stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }
} 