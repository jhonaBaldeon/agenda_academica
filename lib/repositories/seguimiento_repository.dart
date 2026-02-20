import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seguimiento_actividad_model.dart';

class SeguimientoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear o actualizar seguimiento
  Future<SeguimientoActividad> createOrUpdateSeguimiento(SeguimientoActividad seguimiento) async {
    if (seguimiento.id.isEmpty) {
      // Crear nuevo
      final docRef = await _db.collection('seguimientos').add(seguimiento.toMap());
      final doc = await docRef.get();
      return SeguimientoActividad.fromFirestore(doc);
    } else {
      // Actualizar existente
      await _db.collection('seguimientos').doc(seguimiento.id).update(seguimiento.toMap());
      final doc = await _db.collection('seguimientos').doc(seguimiento.id).get();
      return SeguimientoActividad.fromFirestore(doc);
    }
  }

  // Obtener seguimientos por alumno
  Stream<List<SeguimientoActividad>> getSeguimientosByAlumno(String alumnoId) {
    return _db
        .collection('seguimientos')
        .where('alumnoId', isEqualTo: alumnoId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SeguimientoActividad.fromFirestore(doc)).toList());
  }

  // Obtener seguimientos por curso
  Stream<List<SeguimientoActividad>> getSeguimientosByCurso(String cursoId) {
    return _db
        .collection('seguimientos')
        .where('cursoId', isEqualTo: cursoId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SeguimientoActividad.fromFirestore(doc)).toList());
  }

  // Obtener seguimientos por alumno y curso
  Stream<List<SeguimientoActividad>> getSeguimientosByAlumnoAndCurso(String alumnoId, String cursoId) {
    return _db
        .collection('seguimientos')
        .where('alumnoId', isEqualTo: alumnoId)
        .where('cursoId', isEqualTo: cursoId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SeguimientoActividad.fromFirestore(doc)).toList());
  }

  // Obtener seguimiento específico por alumno y actividad
  Future<SeguimientoActividad?> getSeguimientoByAlumnoAndActividad(String alumnoId, String actividadId) async {
    final snapshot = await _db
        .collection('seguimientos')
        .where('alumnoId', isEqualTo: alumnoId)
        .where('actividadId', isEqualTo: actividadId)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return SeguimientoActividad.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  // Actualizar estado de seguimiento
  Future<void> updateEstadoSeguimiento(String seguimientoId, EstadoSeguimiento nuevoEstado) async {
    String estadoString;
    switch (nuevoEstado) {
      case EstadoSeguimiento.completado:
        estadoString = 'completado';
        break;
      case EstadoSeguimiento.noRealizado:
        estadoString = 'noRealizado';
        break;
      default:
        estadoString = 'incompleto';
    }
    
    await _db.collection('seguimientos').doc(seguimientoId).update({
      'estado': estadoString,
      'fechaCompletado': nuevoEstado == EstadoSeguimiento.completado ? Timestamp.fromDate(DateTime.now()) : null,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Eliminar seguimiento
  Future<void> deleteSeguimiento(String seguimientoId) async {
    await _db.collection('seguimientos').doc(seguimientoId).delete();
  }
}
