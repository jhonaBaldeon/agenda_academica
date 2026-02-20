import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Verificar si el usuario existe y obtener su rol
  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    
    if (doc.exists) {
      return doc['role'] as String?; // Retorna 'docente' o 'padre'
    } else {
      // Usuario nuevo, retorna null para indicar que necesita seleccionar rol
      return null;
    }
  }

  // Guardar el rol del usuario en Firestore
  Future<void> saveUserRole(String uid, String email, String displayName, String role) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}