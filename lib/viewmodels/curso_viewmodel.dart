import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/curso_model.dart';
import '../models/actividad_model.dart';
import '../repositories/curso_repository.dart';
import '../repositories/alumno_repository.dart';
import 'seguimiento_viewmodel.dart';

class CursoViewModel extends ChangeNotifier {
  final CursoRepository _repository = CursoRepository();
  final AlumnoRepository _alumnoRepository = AlumnoRepository();
  final SeguimientoViewModel _seguimientoVM = SeguimientoViewModel();

  final List<Curso> _cursos = [];
  final List<Actividad> _actividades = [];
  bool _isLoading = false;
  String? _error;

  List<Curso> get cursos => _cursos;
  List<Actividad> get actividades => _actividades;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<Curso>> getCursosStream(String docenteId) {
    return _repository.getCursosByDocente(docenteId);
  }

  Stream<List<Curso>> getAllCursosStream() {
    return _repository.getAllCursos();
  }

  Stream<List<Actividad>> getActividadesStream(String cursoId) {
    return _repository.getActividadesByCurso(cursoId);
  }

  Future<void> createCurso({
    required String nombreCurso,
    required String nombreDocente,
    required String horario,
    required int color,
    required String docenteId,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final curso = Curso(
        id: '',
        nombreCurso: nombreCurso,
        nombreDocente: nombreDocente,
        horario: horario,
        color: color,
        docenteId: docenteId,
        createdAt: DateTime.now(),
      );

      await _repository.createCurso(curso);
    } catch (e) {
      _error = 'Error al crear curso: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createActividad({
    required String cursoId,
    required String cursoNombre,
    required String titulo,
    required String descripcion,
    required DateTime fechaEntrega,
    required PrioridadActividad prioridad,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      // Crear la actividad
      final actividad = Actividad(
        id: '',
        cursoId: cursoId,
        titulo: titulo,
        descripcion: descripcion,
        fechaEntrega: fechaEntrega,
        prioridad: prioridad,
        estado: EstadoActividad.incompleto,
        createdAt: DateTime.now(),
      );

      final actividadCreada = await _repository.createActividad(actividad);

      // Obtener todos los alumnos para crear seguimientos
      final alumnosSnapshot = await _alumnoRepository.getAllAlumnos().first;

      if (alumnosSnapshot.isNotEmpty) {
        final alumnosData = alumnosSnapshot
            .map(
              (alumno) => {
                'id': alumno.id,
                'nombreCompleto': alumno.nombreCompleto,
              },
            )
            .toList();

        // Crear seguimientos para todos los alumnos
        await _seguimientoVM.createSeguimientosForAllAlumnos(
          alumnos: alumnosData,
          actividadId: actividadCreada.id,
          actividadTitulo: titulo,
          actividadDescripcion: descripcion,
          actividadFechaEntrega: fechaEntrega,
          cursoId: cursoId,
          cursoNombre: cursoNombre,
        );
      }
    } catch (e) {
      _error = 'Error al crear actividad: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateActividad({
    required String actividadId,
    String? titulo,
    String? descripcion,
    DateTime? fechaEntrega,
    PrioridadActividad? prioridad,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final data = <String, dynamic>{};
      if (titulo != null) data['titulo'] = titulo;
      if (descripcion != null) data['descripcion'] = descripcion;
      if (fechaEntrega != null) {
        data['fechaEntrega'] = Timestamp.fromDate(fechaEntrega);
      }
      if (prioridad != null) {
        String prioridadString;
        switch (prioridad) {
          case PrioridadActividad.alta:
            prioridadString = 'alta';
            break;
          case PrioridadActividad.baja:
            prioridadString = 'baja';
            break;
          default:
            prioridadString = 'media';
        }
        data['prioridad'] = prioridadString;
      }

      await _repository.updateActividad(actividadId, data);
    } catch (e) {
      _error = 'Error al actualizar actividad: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteActividad(String actividadId) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.deleteActividad(actividadId);
    } catch (e) {
      _error = 'Error al eliminar actividad: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCurso({
    required String cursoId,
    String? nombreCurso,
    String? nombreDocente,
    String? horario,
    int? color,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final data = <String, dynamic>{};
      if (nombreCurso != null) data['nombreCurso'] = nombreCurso;
      if (nombreDocente != null) data['nombreDocente'] = nombreDocente;
      if (horario != null) data['horario'] = horario;
      if (color != null) data['color'] = color;

      await _repository.updateCurso(cursoId, data);
    } catch (e) {
      _error = 'Error al actualizar curso: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCurso(String cursoId) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.deleteCurso(cursoId);
    } catch (e) {
      _error = 'Error al eliminar curso: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
