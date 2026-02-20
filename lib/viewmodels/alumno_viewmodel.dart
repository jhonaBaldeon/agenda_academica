import 'package:flutter/material.dart';
import '../models/alumno_model.dart';
import '../repositories/alumno_repository.dart';

class AlumnoViewModel extends ChangeNotifier {
  final AlumnoRepository _repository = AlumnoRepository();

  final List<Alumno> _alumnos = [];
  Alumno? _alumnoSeleccionado;
  bool _isLoading = false;
  String? _error;

  List<Alumno> get alumnos => _alumnos;
  Alumno? get alumnoSeleccionado => _alumnoSeleccionado;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<Alumno>> getAlumnosStream() {
    return _repository.getAllAlumnos();
  }

  Future<void> createAlumno({
    required String nombres,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String grado,
    required String seccion,
    String padreId = '',
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final alumno = Alumno(
        id: '',
        nombres: nombres,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        grado: grado,
        seccion: seccion,
        padreId: padreId,
        createdAt: DateTime.now(),
      );

      await _repository.createAlumno(alumno);
    } catch (e) {
      _error = 'Error al crear alumno: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAlumno({
    required String alumnoId,
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? grado,
    String? seccion,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final data = <String, dynamic>{};
      if (nombres != null) data['nombres'] = nombres;
      if (apellidoPaterno != null) data['apellidoPaterno'] = apellidoPaterno;
      if (apellidoMaterno != null) data['apellidoMaterno'] = apellidoMaterno;
      if (grado != null) data['grado'] = grado;
      if (seccion != null) data['seccion'] = seccion;

      await _repository.updateAlumno(alumnoId, data);
    } catch (e) {
      _error = 'Error al actualizar alumno: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAlumno(String alumnoId) async {
    _setLoading(true);
    _error = null;

    try {
      await _repository.deleteAlumno(alumnoId);
    } catch (e) {
      _error = 'Error al eliminar alumno: $e';
    } finally {
      _setLoading(false);
    }
  }

  void selectAlumno(Alumno alumno) {
    _alumnoSeleccionado = alumno;
    notifyListeners();
  }

  void clearSelectedAlumno() {
    _alumnoSeleccionado = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
