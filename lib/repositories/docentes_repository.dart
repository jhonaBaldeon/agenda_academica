import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/docente_registrado_model.dart';

class DocentesRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Registrar un nuevo docente (solo admin)
  Future<DocenteRegistrado> registrarDocente({
    required String email,
    required String nombre,
  }) async {
    final docRef = await _db.collection('docentes_registrados').add({
      'email': email,
      'nombre': nombre,
      'fechaRegistro': Timestamp.fromDate(DateTime.now()),
      'activo': true,
    });
    final doc = await docRef.get();
    return DocenteRegistrado.fromFirestore(doc);
  }

  // Verificar si un email está registrado como docente
  Future<bool> esDocenteRegistrado(String email) async {
    final snapshot = await _db
        .collection('docentes_registrados')
        .where('email', isEqualTo: email)
        .where('activo', isEqualTo: true)
        .limit(1)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }

  // Obtener todos los docentes registrados
  Stream<List<DocenteRegistrado>> getDocentesRegistrados() {
    return _db
        .collection('docentes_registrados')
        .orderBy('fechaRegistro', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => DocenteRegistrado.fromFirestore(doc)).toList());
  }

  // Desactivar un docente
  Future<void> desactivarDocente(String docenteId) async {
    await _db.collection('docentes_registrados').doc(docenteId).update({
      'activo': false,
    });
  }

  // Activar un docente
  Future<void> activarDocente(String docenteId) async {
    await _db.collection('docentes_registrados').doc(docenteId).update({
      'activo': true,
    });
  }

  // Eliminar un docente
  Future<void> eliminarDocente(String docenteId) async {
    await _db.collection('docentes_registrados').doc(docenteId).delete();
  }
}
