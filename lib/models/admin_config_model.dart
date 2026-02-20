import 'package:cloud_firestore/cloud_firestore.dart';

class AdminConfig {
  final String id;
  final String pin;
  final List<String> adminEmails; // Lista de hasta 3 administradores
  final DateTime updatedAt;

  AdminConfig({
    required this.id,
    required this.pin,
    required this.adminEmails,
    required this.updatedAt,
  });

  factory AdminConfig.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Manejar migración de adminEmail único a lista
    List<String> emails = [];
    if (data['adminEmails'] != null) {
      emails = List<String>.from(data['adminEmails']);
    } else if (data['adminEmail'] != null) {
      // Migración: convertir email único a lista
      emails = [data['adminEmail']];
    } else {
      // Valor por defecto
      emails = ['46747313@continental.edu.pe'];
    }
    
    return AdminConfig(
      id: doc.id,
      pin: data['pin'] ?? '1234',
      adminEmails: emails,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pin': pin,
      'adminEmails': adminEmails,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  int get cantidadAdmins => adminEmails.length;
  bool get puedeAgregarAdmin => adminEmails.length < 3;
}
