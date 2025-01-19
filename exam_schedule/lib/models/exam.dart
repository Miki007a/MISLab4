class Exam {
  final String id;
  final String subject;
  final DateTime dateTime;
  final String location;
  final double latitude;
  final double longitude;
  final bool hasReminder;

  Exam({
    required this.id,
    required this.subject,
    required this.dateTime,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.hasReminder = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'hasReminder': hasReminder,
    };
  }

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      subject: json['subject'],
      dateTime: DateTime.parse(json['dateTime']),
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      hasReminder: json['hasReminder'],
    );
  }
} 