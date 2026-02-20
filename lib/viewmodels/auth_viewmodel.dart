import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../repositories/user_repository.dart';
import '../repositories/docentes_repository.dart';
import '../repositories/admin_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();
  final DocentesRepository _docentesRepository = DocentesRepository();
  final AdminRepository _adminRepository = AdminRepository();

  User? _user;
  String? _role;
  bool _isLoading = false;

  User? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;

  // Método para iniciar sesión como Docente (con Google)
  Future<void> signInAsDocente(BuildContext context) async {
    _setLoading(true);

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && context.mounted) {
        // Verificar si es admin
        final esAdmin = await _adminRepository.esAdmin(user.email ?? '');

        // Si no es admin, verificar que esté registrado como docente
        if (!esAdmin) {
          final estaRegistrado = await _docentesRepository.esDocenteRegistrado(
            user.email ?? '',
          );

          if (!estaRegistrado) {
            // No está registrado, cerrar sesión y mostrar error
            await _authService.signOut();
            _setLoading(false);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Acceso denegado. No está registrado como docente. Contacte al administrador.",
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                ),
              );
            }
            return;
          }
        }

        _user = user;
        _role = esAdmin ? 'admin' : 'docente';
        notifyListeners();

        // Guardar docente en Firestore si es nuevo
        try {
          final existingRole = await _userRepository.getUserRole(user.uid);

          if (existingRole == null) {
            await _userRepository.saveUserRole(
              user.uid,
              user.email ?? '',
              user.displayName ?? '',
              esAdmin ? 'admin' : 'docente',
            );
          }
        } catch (e) {
          // Error handling is done by the catch block
        }

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home_docente');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al iniciar sesión: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  // Método para ingresar como Padre (sin autenticación)
  Future<void> signInAsPadre(BuildContext context) async {
    _setLoading(true);

    try {
      // Para padres, no se requiere autenticación
      _role = 'padre';
      _user = null; // No hay usuario autenticado
      notifyListeners();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home_padre');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await _authService.signOut();
    _user = null;
    _role = null;
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
    notifyListeners();
  }
}
