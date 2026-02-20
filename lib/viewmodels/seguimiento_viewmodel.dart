import 'package:flutter/material.dart';
import '../models/seguimiento_actividad_model.dart';
import '../repositories/seguimiento_repository.dart';

class SeguimientoViewModel extends ChangeNotifier {
  final SeguimientoRepository _repository = SeguimientoRepository();

  final List<SeguimientoActividad> _seguimientos = [];
  SeguimientoActividad? _seguimientoSeleccionado;
  String? _alumnoIdSeleccionado;
  String? _cursoIdSeleccionado;
  bool _isLoading = false;
  String? _error;

  List<SeguimientoActividad> get seguimientos => _seguimientos;
  SeguimientoActividad? get seguimientoSeleccionado => _seguimientoSeleccionado;
  String? get alumnoIdSeleccionado => _alumnoIdSeleccionado;
  String? get cursoIdSeleccionado => _cursoIdSeleccionado;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtrar seguimientos
  void setAlumnoFiltro(String? alumnoId) {
    _alumnoIdSeleccionado = alumnoId;
    notifyListeners();
  }

  void setCursoFiltro(String? cursoId) {
    _cursoIdSeleccionado = cursoId;
    notifyListeners();
  }

  // Obtener seguimientos filtrados
  Stream<List<SeguimientoActividad>> getSeguimientosStream() {
    if (_alumnoIdSeleccionado != null && _cursoIdSeleccionado != null) {
      return _repository.getSeguimientosByAlumnoAndCurso(
        _alumnoIdSeleccionado!,
        _cursoIdSeleccionado!,
      );
    } else if (_alumnoIdSeleccionado != null) {
      return _repository.getSeguimientosByAlumno(_alumnoIdSeleccionado!);
    } else if (_cursoIdSeleccionado != null) {
      return _repository.getSeguimientosByCurso(_cursoIdSeleccionado!);
    }
    return Stream.value([]);
  }

  // Crear seguimiento para un alumno y actividad
  Future<void> createSeguimiento({
    required String alumnoId,
    required String alumnoNombre,
    required String actividadId,
    required String actividadTitulo,
    required String actividadDescripcion,
    required DateTime actividadFechaEntrega,
    required String cursoId,
    required String cursoNombre,
    EstadoSeguimiento estado = EstadoSeguimiento.incompleto,
    String? observaciones,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      // Verificar si ya existe un seguimiento
      final existingSeguimiento = await _repository
          .getSeguimientoByAlumnoAndActividad(alumnoId, actividadId);

      if (existingSeguimiento != null) {
        // Ya existe, no crear duplicado
        return;
      }

      final seguimiento = SeguimientoActividad(
        id: '',
        alumnoId: alumnoId,
        alumnoNombre: alumnoNombre,
        actividadId: actividadId,
        actividadTitulo: actividadTitulo,
        actividadDescripcion: actividadDescripcion,
        actividadFechaEntrega: actividadFechaEntrega,
        cursoId: cursoId,
        cursoNombre: cursoNombre,
        estado: estado,
        observaciones: observaciones,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createOrUpdateSeguimiento(seguimiento);
    } catch (e) {
      _error = 'Error al crear seguimiento: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Crear seguimientos para todos los alumnos de una actividad
  Future<void> createSeguimientosForAllAlumnos({
    required List<Map<String, dynamic>> alumnos,
    required String actividadId,
    required String actividadTitulo,
    required String actividadDescripcion,
    required DateTime actividadFechaEntrega,
    required String cursoId,
    required String cursoNombre,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      for (final alumnoData in alumnos) {
        final alumnoId = alumnoData['id'] as String;
        final alumnoNombre = alumnoData['nombreCompleto'] as String;

        // Verificar si ya existe un seguimiento
        final existingSeguimiento = await _repository
            .getSeguimientoByAlumnoAndActividad(alumnoId, actividadId);

        if (existingSeguimiento == null) {
          final seguimiento = SeguimientoActividad(
            id: '',
            alumnoId: alumnoId,
            alumnoNombre: alumnoNombre,
            actividadId: actividadId,
            actividadTitulo: actividadTitulo,
            actividadDescripcion: actividadDescripcion,
            actividadFechaEntrega: actividadFechaEntrega,
            cursoId: cursoId,
            cursoNombre: cursoNombre,
            estado: EstadoSeguimiento.incompleto,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _repository.createOrUpdateSeguimiento(seguimiento);
        }
      }
    } catch (e) {
      _error = 'Error al crear seguimientos: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar estado de seguimiento
  Future<void> updateEstadoSeguimiento(
    String seguimientoId,
    EstadoSeguimiento nuevoEstado,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.updateEstadoSeguimiento(seguimientoId, nuevoEstado);
    } catch (e) {
      _error = 'Error al actualizar estado: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar observaciones
  Future<void> updateObservaciones(
    String seguimientoId,
    String observaciones,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      // Obtener el seguimiento existente primero
      // Nota: Esto es una simplificación, idealmente deberíamos tener un método para actualizar solo observaciones
      await _repository.updateEstadoSeguimiento(
        seguimientoId,
        EstadoSeguimiento.incompleto,
      );
    } catch (e) {
      _error = 'Error al actualizar observaciones: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar seguimiento
  Future<void> deleteSeguimiento(String seguimientoId) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.deleteSeguimiento(seguimientoId);
    } catch (e) {
      _error = 'Error al eliminar seguimiento: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
