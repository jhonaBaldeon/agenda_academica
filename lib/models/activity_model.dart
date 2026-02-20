import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;
  final String courseId;

  ActivityModel({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.courseId,
  });

  // Convierte un JSON (de Firestore o API) en un objeto de Dart
  factory ActivityModel.fromJson(Map<String, dynamic> json, String documentId) {
    return ActivityModel(
      id: documentId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      // Manejo flexible de fechas: Firestore (Timestamp) vs API (String)
      dueDate: (json['due_date'] is Timestamp) 
          ? (json['due_date'] as Timestamp).toDate() 
          : DateTime.parse(json['due_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pendiente',
      courseId: json['course_id'] ?? '',
    );
  }

  // ¡IMPORTANTE! Convierte el objeto a JSON para enviarlo a Firestore o FastAPI
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(), // Formato estándar ISO para FastAPI
      'status': status,
      'course_id': courseId,
    };
  }
}