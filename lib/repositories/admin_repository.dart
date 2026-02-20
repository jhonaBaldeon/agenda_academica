import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_config_model.dart';

class AdminRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _configId = 'admin_config';
  static const int maxAdmins = 3;

  // Obtener configuración del admin
  Future<AdminConfig> getAdminConfig() async {
    final doc = await _db.collection('admin_config').doc(_configId).get();
    if (doc.exists) {
      return AdminConfig.fromFirestore(doc);
    } else {
      // Crear configuración por defecto si no existe
      final defaultConfig = AdminConfig(
        id: _configId,
        pin: '1234',
        adminEmails: ['46747313@continental.edu.pe'],
        updatedAt: DateTime.now(),
      );
      await _db
          .collection('admin_config')
          .doc(_configId)
          .set(defaultConfig.toMap());
      return defaultConfig;
    }
  }

  // Verificar PIN
  Future<bool> verificarPin(String pin) async {
    final config = await getAdminConfig();
    return config.pin == pin;
  }

  // Cambiar PIN
  Future<void> cambiarPin(String nuevoPin) async {
    await _db.collection('admin_config').doc(_configId).update({
      'pin': nuevoPin,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Verificar si un email es admin
  Future<bool> esAdmin(String email) async {
    final config = await getAdminConfig();
    return config.adminEmails.contains(email);
  }

  // Obtener lista de emails de administradores
  Future<List<String>> getAdminEmails() async {
    final config = await getAdminConfig();
    return config.adminEmails;
  }

  // Agregar un nuevo administrador
  Future<void> agregarAdmin(String nuevoEmail) async {
    final config = await getAdminConfig();

    if (config.adminEmails.length >= maxAdmins) {
      throw Exception('Ya se alcanzó el máximo de $maxAdmins administradores');
    }

    if (config.adminEmails.contains(nuevoEmail)) {
      throw Exception('Este email ya es administrador');
    }

    final nuevaLista = [...config.adminEmails, nuevoEmail];

    await _db.collection('admin_config').doc(_configId).update({
      'adminEmails': nuevaLista,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Reemplazar un administrador existente
  Future<void> reemplazarAdmin(String emailExistente, String nuevoEmail) async {
    final config = await getAdminConfig();

    if (!config.adminEmails.contains(emailExistente)) {
      throw Exception('El administrador a reemplazar no existe');
    }

    if (config.adminEmails.contains(nuevoEmail)) {
      throw Exception('El nuevo email ya es administrador');
    }

    final nuevaLista = config.adminEmails
        .map((e) => e == emailExistente ? nuevoEmail : e)
        .toList();

    await _db.collection('admin_config').doc(_configId).update({
      'adminEmails': nuevaLista,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Eliminar un administrador
  Future<void> eliminarAdmin(String email) async {
    final config = await getAdminConfig();

    if (config.adminEmails.length <= 1) {
      throw Exception('Debe haber al menos un administrador');
    }

    final nuevaLista = config.adminEmails.where((e) => e != email).toList();

    await _db.collection('admin_config').doc(_configId).update({
      'adminEmails': nuevaLista,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
