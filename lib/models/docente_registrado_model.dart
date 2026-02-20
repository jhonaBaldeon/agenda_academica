import 'package:cloud_firestore/cloud_firestore.dart';

class DocenteRegistrado {
  final String id;
  final String email;
  final String nombre;
  final DateTime fechaRegistro;
  final bool activo;

  DocenteRegistrado({
    required this.id,
    required this.email,
    required this.nombre,
    required this.fechaRegistro,
    this.activo = true,
  });

  factory DocenteRegistrado.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DocenteRegistrado(
      id: doc.id,
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      fechaRegistro: (data['fechaRegistro'] as Timestamp?)?.toDate() ?? DateTime.now(),
      activo: data['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nombre': nombre,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'activo': activo,
    };
  }
}
