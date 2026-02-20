import 'package:flutter/material.dart';
import '../models/admin_config_model.dart';
import '../repositories/admin_repository.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  bool _isLoading = false;
  String? _error;
  bool _isAdmin = false;
  AdminConfig? _config;
  List<String> _adminEmails = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _isAdmin;
  AdminConfig? get config => _config;
  List<String> get adminEmails => _adminEmails;
  int get cantidadAdmins => _adminEmails.length;
  bool get puedeAgregarAdmin => _adminEmails.length < 3;

  // Verificar PIN
  Future<bool> verificarPin(String pin) async {
    _setLoading(true);
    _error = null;
    
    try {
      final esValido = await _repository.verificarPin(pin);
      _setLoading(false);
      return esValido;
    } catch (e) {
      _error = 'Error al verificar PIN: $e';
      _setLoading(false);
      return false;
    }
  }

  // Cambiar PIN
  Future<void> cambiarPin(String nuevoPin) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _repository.cambiarPin(nuevoPin);
      _setLoading(false);
    } catch (e) {
      _error = 'Error al cambiar PIN: $e';
      _setLoading(false);
    }
  }

  // Verificar si el usuario actual es admin
  Future<void> verificarAdmin(String email) async {
    _setLoading(true);
    _error = null;
    
    try {
      _isAdmin = await _repository.esAdmin(email);
      _config = await _repository.getAdminConfig();
      _adminEmails = await _repository.getAdminEmails();
      _setLoading(false);
    } catch (e) {
      _error = 'Error al verificar admin: $e';
      _setLoading(false);
    }
  }

  // Obtener configuración y lista de admins
  Future<void> cargarConfig() async {
    _setLoading(true);
    _error = null;
    
    try {
      _config = await _repository.getAdminConfig();
      _adminEmails = await _repository.getAdminEmails();
      _setLoading(false);
    } catch (e) {
      _error = 'Error al cargar configuración: $e';
      _setLoading(false);
    }
  }

  // Agregar nuevo administrador
  Future<void> agregarAdmin(String nuevoEmail) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _repository.agregarAdmin(nuevoEmail);
      _adminEmails = await _repository.getAdminEmails();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // Reemplazar administrador existente
  Future<void> reemplazarAdmin(String emailExistente, String nuevoEmail) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _repository.reemplazarAdmin(emailExistente, nuevoEmail);
      _adminEmails = await _repository.getAdminEmails();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // Eliminar administrador
  Future<void> eliminarAdmin(String email) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _repository.eliminarAdmin(email);
      _adminEmails = await _repository.getAdminEmails();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
