import 'package:cloud_firestore/cloud_firestore.dart';

class Alumno {
  final String id;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String grado;
  final String seccion;
  final String padreId;
  final DateTime createdAt;

  Alumno({
    required this.id,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.grado,
    required this.seccion,
    this.padreId = '',
    required this.createdAt,
  });

  // Formato: Apellido Paterno Apellido Materno Nombres
  String get nombreCompleto => '$apellidoPaterno $apellidoMaterno $nombres';

  factory Alumno.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Alumno(
      id: doc.id,
      nombres: data['nombres'] ?? '',
      apellidoPaterno: data['apellidoPaterno'] ?? '',
      apellidoMaterno: data['apellidoMaterno'] ?? '',
      grado: data['grado'] ?? '',
      seccion: data['seccion'] ?? '',
      padreId: data['padreId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombres': nombres,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'grado': grado,
      'seccion': seccion,
      'padreId': padreId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
