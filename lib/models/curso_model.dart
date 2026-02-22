import 'package:cloud_firestore/cloud_firestore.dart';

class Curso {
  final String id;
  final String nombreCurso;
  final String nombreDocente;
  final String horario;
  final int color;
  final String docenteId;
  final DateTime createdAt;

  Curso({
    required this.id,
    required this.nombreCurso,
    required this.nombreDocente,
    required this.horario,
    required this.color,
    required this.docenteId,
    required this.createdAt,
  });

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      id: json['id'] ?? '',
      nombreCurso: json['nombre_curso'] ?? json['nombreCurso'] ?? '',
      nombreDocente: json['nombre_docente'] ?? json['nombreDocente'] ?? '',
      horario: json['horario'] ?? '',
      color: json['color'] ?? 0xFF2196F3,
      docenteId: json['docente_id'] ?? json['docenteId'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  factory Curso.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Curso(
      id: doc.id,
      nombreCurso: data['nombreCurso'] ?? '',
      nombreDocente: data['nombreDocente'] ?? '',
      horario: data['horario'] ?? '',
      color: data['color'] ?? 0xFF2196F3,
      docenteId: data['docenteId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombreCurso': nombreCurso,
      'nombreDocente': nombreDocente,
      'horario': horario,
      'color': color,
      'docenteId': docenteId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_curso': nombreCurso,
      'nombre_docente': nombreDocente,
      'horario': horario,
      'color': color,
      'docente_id': docenteId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
