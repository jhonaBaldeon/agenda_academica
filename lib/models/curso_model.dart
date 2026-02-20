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
}
