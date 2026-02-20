import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alumno_model.dart';

class AlumnoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear un nuevo alumno
  Future<Alumno> createAlumno(Alumno alumno) async {
    final docRef = await _db.collection('alumnos').add(alumno.toMap());
    final doc = await docRef.get();
    return Alumno.fromFirestore(doc);
  }

  // Obtener todos los alumnos
  Stream<List<Alumno>> getAllAlumnos() {
    return _db
        .collection('alumnos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Alumno.fromFirestore(doc)).toList(),
        );
  }

  // Obtener un alumno por ID
  Future<Alumno?> getAlumnoById(String alumnoId) async {
    final doc = await _db.collection('alumnos').doc(alumnoId).get();
    if (doc.exists) {
      return Alumno.fromFirestore(doc);
    }
    return null;
  }

  // Actualizar alumno
  Future<void> updateAlumno(String alumnoId, Map<String, dynamic> data) async {
    await _db.collection('alumnos').doc(alumnoId).update(data);
  }

  // Eliminar alumno
  Future<void> deleteAlumno(String alumnoId) async {
    await _db.collection('alumnos').doc(alumnoId).delete();
  }

  // Buscar alumnos por nombre
  Stream<List<Alumno>> buscarAlumnos(String query) {
    return _db
        .collection('alumnos')
        .orderBy('nombre')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Alumno.fromFirestore(doc)).toList(),
        );
  }
}
