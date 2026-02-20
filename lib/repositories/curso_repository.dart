import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/curso_model.dart';
import '../models/actividad_model.dart';

class CursoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear un nuevo curso
  Future<Curso> createCurso(Curso curso) async {
    final docRef = await _db.collection('cursos').add(curso.toMap());
    final doc = await docRef.get();
    return Curso.fromFirestore(doc);
  }

  // Obtener todos los cursos de un docente
  Stream<List<Curso>> getCursosByDocente(String docenteId) {
    return _db
        .collection('cursos')
        .where('docenteId', isEqualTo: docenteId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Curso.fromFirestore(doc)).toList());
  }

  // Obtener todos los cursos (para padres)
  Stream<List<Curso>> getAllCursos() {
    return _db
        .collection('cursos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Curso.fromFirestore(doc)).toList());
  }

  // Crear una nueva actividad
  Future<Actividad> createActividad(Actividad actividad) async {
    final docRef = await _db.collection('actividades').add(actividad.toMap());
    final doc = await docRef.get();
    return Actividad.fromFirestore(doc);
  }

  // Obtener actividades de un curso
  Stream<List<Actividad>> getActividadesByCurso(String cursoId) {
    return _db
        .collection('actividades')
        .where('cursoId', isEqualTo: cursoId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Actividad.fromFirestore(doc)).toList());
  }

  // Actualizar actividad
  Future<void> updateActividad(String actividadId, Map<String, dynamic> data) async {
    await _db.collection('actividades').doc(actividadId).update(data);
  }

  // Eliminar actividad
  Future<void> deleteActividad(String actividadId) async {
    await _db.collection('actividades').doc(actividadId).delete();
  }

  // Actualizar curso
  Future<void> updateCurso(String cursoId, Map<String, dynamic> data) async {
    await _db.collection('cursos').doc(cursoId).update(data);
  }

  // Eliminar curso y sus actividades
  Future<void> deleteCurso(String cursoId) async {
    // Primero eliminar todas las actividades del curso
    final actividadesSnapshot = await _db
        .collection('actividades')
        .where('cursoId', isEqualTo: cursoId)
        .get();
    
    for (var doc in actividadesSnapshot.docs) {
      await doc.reference.delete();
    }
    
    // Luego eliminar el curso
    await _db.collection('cursos').doc(cursoId).delete();
  }
}
