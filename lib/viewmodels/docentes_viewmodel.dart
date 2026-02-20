import 'package:flutter/material.dart';
import '../models/docente_registrado_model.dart';
import '../repositories/docentes_repository.dart';

class DocentesViewModel extends ChangeNotifier {
  final DocentesRepository _repository = DocentesRepository();
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<DocenteRegistrado>> getDocentesStream() {
    return _repository.getDocentesRegistrados();
  }

  Future<void> registrarDocente({
    required String nombre,
    required String email,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _repository.registrarDocente(
        email: email,
        nombre: nombre,
      );
    } catch (e) {
      _error = 'Error al registrar docente: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> eliminarDocente(String docenteId) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _repository.eliminarDocente(docenteId);
    } catch (e) {
      _error = 'Error al eliminar docente: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleEstadoDocente(DocenteRegistrado docente) async {
    _setLoading(true);
    _error = null;
    
    try {
      if (docente.activo) {
        await _repository.desactivarDocente(docente.id);
      } else {
        await _repository.activarDocente(docente.id);
      }
    } catch (e) {
      _error = 'Error al cambiar estado: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
