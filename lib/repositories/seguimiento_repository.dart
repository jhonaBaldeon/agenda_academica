import 'dart:async';
import '../models/seguimiento_actividad_model.dart';
import '../services/api_service.dart';

class SeguimientoRepository {
  final ApiService _api = ApiService();
  
  // Controlador para seguimientos
  final _seguimientosController = StreamController<List<SeguimientoActividad>>.broadcast();
  
  // Obtener todos los seguimientos
  Stream<List<SeguimientoActividad>> getAllSeguimientos() {
    _refreshSeguimientos();
    return _seguimientosController.stream;
  }
  
  // Método para refrescar seguimientos
  Future<void> _refreshSeguimientos({String? alumnoId, String? cursoId}) async {
    try {
      final seguimientos = await _api.getSeguimientos(
        alumnoId: alumnoId, 
        cursoId: cursoId,
      );
      _seguimientosController.add(seguimientos.map((s) => SeguimientoActividad.fromJson(s)).toList());
    } catch (e) {
      _seguimientosController.addError(e);
    }
  }

  // Obtener todos los seguimientos como lista
  Future<List<SeguimientoActividad>> getAllSeguimientosList() async {
    final seguimientos = await _api.getSeguimientos();
    return seguimientos.map((s) => SeguimientoActividad.fromJson(s)).toList();
  }

  // Crear seguimiento
  Future<SeguimientoActividad> createSeguimiento(SeguimientoActividad seguimiento) async {
    final data = await _api.createSeguimiento(seguimiento.toJson());
    return SeguimientoActividad.fromJson(data);
  }

  // Crear o actualizar seguimiento
  Future<SeguimientoActividad> createOrUpdateSeguimiento(SeguimientoActividad seguimiento) async {
    if (seguimiento.id.isEmpty) {
      return createSeguimiento(seguimiento);
    } else {
      await updateSeguimiento(seguimiento.id, seguimiento.toJson());
      final seguimientos = await getAllSeguimientosList();
      return seguimientos.firstWhere((s) => s.id == seguimiento.id);
    }
  }

  // Obtener seguimientos por alumno
  Stream<List<SeguimientoActividad>> getSeguimientosByAlumno(String alumnoId) {
    _refreshSeguimientos(alumnoId: alumnoId);
    return _seguimientosController.stream;
  }

  // Obtener seguimientos por curso
  Stream<List<SeguimientoActividad>> getSeguimientosByCurso(String cursoId) {
    _refreshSeguimientos(cursoId: cursoId);
    return _seguimientosController.stream;
  }

  // Obtener seguimientos por alumno y curso
  Stream<List<SeguimientoActividad>> getSeguimientosByAlumnoAndCurso(String alumnoId, String cursoId) {
    _refreshSeguimientos(alumnoId: alumnoId, cursoId: cursoId);
    return _seguimientosController.stream;
  }

  // Obtener seguimiento específico por alumno y actividad
  Future<SeguimientoActividad?> getSeguimientoByAlumnoAndActividad(String alumnoId, String actividadId) async {
    final seguimientos = await _api.getSeguimientos(alumnoId: alumnoId);
    try {
      return seguimientos
          .map((s) => SeguimientoActividad.fromJson(s))
          .firstWhere((s) => s.actividadId == actividadId);
    } catch (e) {
      return null;
    }
  }

  // Actualizar seguimiento
  Future<void> updateSeguimiento(String seguimientoId, Map<String, dynamic> data) async {
    await _api.updateSeguimiento(seguimientoId, data);
    _refreshSeguimientos();
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
    
    await _api.updateSeguimiento(seguimientoId, {
      'estado': estadoString,
      'updated_at': DateTime.now().toIso8601String(),
    });
    _refreshSeguimientos();
  }

  // Eliminar seguimiento
  Future<void> deleteSeguimiento(String seguimientoId) async {
    await _api.deleteSeguimiento(seguimientoId);
  }

  void dispose() {
    _seguimientosController.close();
  }
}
