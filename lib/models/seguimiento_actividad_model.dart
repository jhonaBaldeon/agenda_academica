import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoSeguimiento { completado, incompleto, noRealizado }

class SeguimientoActividad {
  final String id;
  final String alumnoId;
  final String alumnoNombre;
  final String actividadId;
  final String actividadTitulo;
  final String actividadDescripcion;
  final DateTime actividadFechaEntrega;
  final String cursoId;
  final String cursoNombre;
  final EstadoSeguimiento estado;
  final DateTime? fechaCompletado;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  SeguimientoActividad({
    required this.id,
    required this.alumnoId,
    required this.alumnoNombre,
    required this.actividadId,
    required this.actividadTitulo,
    required this.actividadDescripcion,
    required this.actividadFechaEntrega,
    required this.cursoId,
    required this.cursoNombre,
    this.estado = EstadoSeguimiento.incompleto,
    this.fechaCompletado,
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SeguimientoActividad.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SeguimientoActividad(
      id: doc.id,
      alumnoId: data['alumnoId'] ?? '',
      alumnoNombre: data['alumnoNombre'] ?? '',
      actividadId: data['actividadId'] ?? '',
      actividadTitulo: data['actividadTitulo'] ?? '',
      actividadDescripcion: data['actividadDescripcion'] ?? '',
      actividadFechaEntrega: (data['actividadFechaEntrega'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cursoId: data['cursoId'] ?? '',
      cursoNombre: data['cursoNombre'] ?? '',
      estado: _estadoFromString(data['estado'] ?? 'incompleto'),
      fechaCompletado: (data['fechaCompletado'] as Timestamp?)?.toDate(),
      observaciones: data['observaciones'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alumnoId': alumnoId,
      'alumnoNombre': alumnoNombre,
      'actividadId': actividadId,
      'actividadTitulo': actividadTitulo,
      'actividadDescripcion': actividadDescripcion,
      'actividadFechaEntrega': Timestamp.fromDate(actividadFechaEntrega),
      'cursoId': cursoId,
      'cursoNombre': cursoNombre,
      'estado': _estadoToString(estado),
      'fechaCompletado': fechaCompletado != null ? Timestamp.fromDate(fechaCompletado!) : null,
      'observaciones': observaciones,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static EstadoSeguimiento _estadoFromString(String value) {
    switch (value) {
      case 'completado':
        return EstadoSeguimiento.completado;
      case 'noRealizado':
        return EstadoSeguimiento.noRealizado;
      default:
        return EstadoSeguimiento.incompleto;
    }
  }

  static String _estadoToString(EstadoSeguimiento estado) {
    switch (estado) {
      case EstadoSeguimiento.completado:
        return 'completado';
      case EstadoSeguimiento.noRealizado:
        return 'noRealizado';
      default:
        return 'incompleto';
    }
  }

  SeguimientoActividad copyWith({
    String? id,
    String? alumnoId,
    String? alumnoNombre,
    String? actividadId,
    String? actividadTitulo,
    String? actividadDescripcion,
    DateTime? actividadFechaEntrega,
    String? cursoId,
    String? cursoNombre,
    EstadoSeguimiento? estado,
    DateTime? fechaCompletado,
    String? observaciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SeguimientoActividad(
      id: id ?? this.id,
      alumnoId: alumnoId ?? this.alumnoId,
      alumnoNombre: alumnoNombre ?? this.alumnoNombre,
      actividadId: actividadId ?? this.actividadId,
      actividadTitulo: actividadTitulo ?? this.actividadTitulo,
      actividadDescripcion: actividadDescripcion ?? this.actividadDescripcion,
      actividadFechaEntrega: actividadFechaEntrega ?? this.actividadFechaEntrega,
      cursoId: cursoId ?? this.cursoId,
      cursoNombre: cursoNombre ?? this.cursoNombre,
      estado: estado ?? this.estado,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
