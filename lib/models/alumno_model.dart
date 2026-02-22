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

  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidoPaterno: json['apellido_paterno'] ?? json['apellidoPaterno'] ?? '',
      apellidoMaterno: json['apellido_materno'] ?? json['apellidoMaterno'] ?? '',
      grado: json['grado'] ?? '',
      seccion: json['seccion'] ?? '',
      padreId: json['padre_id'] ?? json['padreId'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

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
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombres,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'grado': grado,
      'seccion': seccion,
      'padre_id': padreId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
