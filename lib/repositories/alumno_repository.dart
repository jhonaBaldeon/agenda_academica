import 'dart:async';
import '../models/alumno_model.dart';
import '../services/api_service.dart';

class AlumnoRepository {
  final ApiService _api = ApiService();
  
  // Controlador para alumnos
  final _alumnosController = StreamController<List<Alumno>>.broadcast();
  
  // Obtener stream de todos los alumnos
  Stream<List<Alumno>> getAllAlumnos() {
    _refreshAlumnos();
    return _alumnosController.stream;
  }
  
  // Método para refrescar alumnos
  Future<void> _refreshAlumnos() async {
    try {
      final alumnos = await _api.getAlumnos();
      _alumnosController.add(alumnos.map((a) => Alumno.fromJson(a)).toList());
    } catch (e) {
      _alumnosController.addError(e);
    }
  }

  // Obtener todos los alumnos como lista
  Future<List<Alumno>> getAllAlumnosList() async {
    final alumnos = await _api.getAlumnos();
    return alumnos.map((a) => Alumno.fromJson(a)).toList();
  }

  // Obtener un alumno por ID
  Future<Alumno?> getAlumnoById(String alumnoId) async {
    try {
      final data = await _api.getAlumno(alumnoId);
      return Alumno.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Crear un nuevo alumno
  Future<Alumno> createAlumno(Alumno alumno) async {
    final data = await _api.createAlumno(alumno.toJson());
    _refreshAlumnos();
    return Alumno.fromJson(data);
  }

  // Actualizar alumno
  Future<void> updateAlumno(String alumnoId, Map<String, dynamic> data) async {
    await _api.updateAlumno(alumnoId, data);
    _refreshAlumnos();
  }

  // Eliminar alumno
  Future<void> deleteAlumno(String alumnoId) async {
    await _api.deleteAlumno(alumnoId);
    _refreshAlumnos();
  }

  // Buscar alumnos (implementación básica)
  Future<List<Alumno>> buscarAlumnos(String query) async {
    final alumnos = await getAllAlumnosList();
    final queryLower = query.toLowerCase();
    return alumnos.where((alumno) {
      return alumno.nombres.toLowerCase().contains(queryLower) ||
             alumno.apellidoPaterno.toLowerCase().contains(queryLower) ||
             alumno.apellidoMaterno.toLowerCase().contains(queryLower);
    }).toList();
  }

  void dispose() {
    _alumnosController.close();
  }
}
