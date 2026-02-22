import 'dart:async';
import '../models/curso_model.dart';
import '../models/actividad_model.dart';
import '../services/api_service.dart';

class CursoRepository {
  final ApiService _api = ApiService();
  
  // Controlador para cursos
  final _cursosController = StreamController<List<Curso>>.broadcast();
  
  // Controlador para actividades
  final _actividadesController = StreamController<List<Actividad>>.broadcast();
  
  // Mapa de controladores para cada curso
  final Map<String, StreamController<List<Actividad>>> _actividadesControllersByCurso = {};
  
  // Obtener stream de cursos (para un docente específico)
  Stream<List<Curso>> getCursosByDocente(String docenteId) {
    _refreshCursos();
    return _cursosController.stream;
  }
  
  // Obtener stream de todos los cursos
  Stream<List<Curso>> getAllCursos() {
    _refreshCursos();
    return _cursosController.stream;
  }
  
  // Método para refrescar cursos
  Future<void> _refreshCursos() async {
    try {
      final cursos = await _api.getCursos();
      _cursosController.add(cursos.map((c) => Curso.fromJson(c)).toList());
    } catch (e) {
      _cursosController.addError(e);
    }
  }

  // Obtener todos los cursos como lista
  Future<List<Curso>> getAllCursosList() async {
    final cursos = await _api.getCursos();
    return cursos.map((c) => Curso.fromJson(c)).toList();
  }

  // Obtener un curso por ID
  Future<Curso> getCurso(String cursoId) async {
    final data = await _api.getCurso(cursoId);
    return Curso.fromJson(data);
  }

  // Crear un nuevo curso
  Future<Curso> createCurso(Curso curso) async {
    final data = await _api.createCurso(curso.toJson());
    _refreshCursos();
    return Curso.fromJson(data);
  }

  // Actualizar curso
  Future<void> updateCurso(String cursoId, Map<String, dynamic> data) async {
    await _api.updateCurso(cursoId, data);
    _refreshCursos();
  }

  // Eliminar curso
  Future<void> deleteCurso(String cursoId) async {
    await _api.deleteCurso(cursoId);
    _refreshCursos();
  }

  // Obtener stream de actividades de un curso
  Stream<List<Actividad>> getActividadesByCurso(String cursoId) {
    _refreshActividades(cursoId);
    return _actividadesController.stream;
  }
  
  // Obtener stream de actividades por curso (separado)
  Stream<List<Actividad>> getActividadesStreamByCurso(String cursoId) {
    if (!_actividadesControllersByCurso.containsKey(cursoId)) {
      _actividadesControllersByCurso[cursoId] = StreamController<List<Actividad>>.broadcast();
      // Add empty list immediately to avoid loading state
      _actividadesControllersByCurso[cursoId]!.add([]);
    }
    // Fetch data in background
    _fetchAndAddActividades(cursoId, _actividadesControllersByCurso[cursoId]!);
    return _actividadesControllersByCurso[cursoId]!.stream;
  }
  
  // Fetch and add actividades to controller
  Future<void> _fetchAndAddActividades(String cursoId, StreamController<List<Actividad>> controller) async {
    try {
      final actividades = await _api.getActividades(cursoId);
      if (!controller.isClosed) {
        controller.add(actividades.map((a) => Actividad.fromJson(a)).toList());
      }
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    }
  }
  
  // Método para refrescar actividades
  Future<void> _refreshActividades(String cursoId) async {
    try {
      final actividades = await _api.getActividades(cursoId);
      _actividadesController.add(actividades.map((a) => Actividad.fromJson(a)).toList());
    } catch (e) {
      _actividadesController.addError(e);
    }
  }

  // Obtener actividades como lista
  Future<List<Actividad>> getActividadesList(String cursoId) async {
    final actividades = await _api.getActividades(cursoId);
    return actividades.map((a) => Actividad.fromJson(a)).toList();
  }

  // Crear actividad
  Future<Actividad> createActividad(Actividad actividad) async {
    final data = await _api.createActividad(actividad.cursoId, actividad.toJson());
    return Actividad.fromJson(data);
  }

  // Actualizar actividad
  Future<void> updateActividad(String cursoId, String actividadId, Map<String, dynamic> data) async {
    await _api.updateActividad(cursoId, actividadId, data);
    _refreshActividades(cursoId);
    if (_actividadesControllersByCurso.containsKey(cursoId)) {
      _fetchAndAddActividades(cursoId, _actividadesControllersByCurso[cursoId]!);
    }
  }

  // Eliminar actividad
  Future<void> deleteActividad(String cursoId, String actividadId) async {
    await _api.deleteActividad(cursoId, actividadId);
    _refreshActividades(cursoId);
    if (_actividadesControllersByCurso.containsKey(cursoId)) {
      _fetchAndAddActividades(cursoId, _actividadesControllersByCurso[cursoId]!);
    }
  }

  void dispose() {
    _cursosController.close();
    _actividadesController.close();
    for (var controller in _actividadesControllersByCurso.values) {
      controller.close();
    }
  }
}
