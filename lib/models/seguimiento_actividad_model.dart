import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoSeguimiento { completado, incompleto, noRealizado }

enum PrioridadActividad { alta, media, baja }

class SeguimientoActividad {
  final String id;
  final String alumnoId;
  final String alumnoNombre;
  final String actividadId;
  final String actividadTitulo;
  final String actividadDescripcion;
  final DateTime actividadFechaEntrega;
  final PrioridadActividad actividadPrioridad;
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
    this.actividadPrioridad = PrioridadActividad.media,
    required this.cursoId,
    required this.cursoNombre,
    this.estado = EstadoSeguimiento.incompleto,
    this.fechaCompletado,
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SeguimientoActividad.fromJson(Map<String, dynamic> json) {
    return SeguimientoActividad(
      id: json['id'] ?? '',
      alumnoId: json['alumno_id'] ?? json['alumnoId'] ?? '',
      alumnoNombre: json['alumno_nombre'] ?? json['alumnoNombre'] ?? '',
      actividadId: json['actividad_id'] ?? json['actividadId'] ?? '',
      actividadTitulo: json['actividad_titulo'] ?? json['actividadTitulo'] ?? '',
      actividadDescripcion: json['actividad_descripcion'] ?? json['actividadDescripcion'] ?? '',
      actividadFechaEntrega: json['actividad_fecha_entrega'] != null 
          ? DateTime.tryParse(json['actividad_fecha_entrega'].toString()) ?? DateTime.now()
          : DateTime.now(),
      actividadPrioridad: _prioridadFromString(json['actividad_prioridad'] ?? 'media'),
      cursoId: json['curso_id'] ?? json['cursoId'] ?? '',
      cursoNombre: json['curso_nombre'] ?? json['cursoNombre'] ?? '',
      estado: _estadoFromString(json['estado'] ?? 'incompleto'),
      fechaCompletado: json['fecha_completado'] != null 
          ? DateTime.tryParse(json['fecha_completado'].toString())
          : null,
      observaciones: json['observaciones'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

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
      actividadPrioridad: _prioridadFromString(data['actividadPrioridad'] ?? 'media'),
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
      'actividadPrioridad': _prioridadToString(actividadPrioridad),
      'cursoId': cursoId,
      'cursoNombre': cursoNombre,
      'estado': _estadoToString(estado),
      'fechaCompletado': fechaCompletado != null ? Timestamp.fromDate(fechaCompletado!) : null,
      'observaciones': observaciones,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alumno_id': alumnoId,
      'alumno_nombre': alumnoNombre,
      'actividad_id': actividadId,
      'actividad_titulo': actividadTitulo,
      'actividad_descripcion': actividadDescripcion,
      'actividad_fecha_entrega': actividadFechaEntrega.toIso8601String(),
      'actividad_prioridad': _prioridadToString(actividadPrioridad),
      'curso_id': cursoId,
      'curso_nombre': cursoNombre,
      'estado': _estadoToString(estado),
      'fecha_completado': fechaCompletado?.toIso8601String(),
      'observaciones': observaciones,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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

  static PrioridadActividad _prioridadFromString(String value) {
    switch (value) {
      case 'alta':
        return PrioridadActividad.alta;
      case 'baja':
        return PrioridadActividad.baja;
      default:
        return PrioridadActividad.media;
    }
  }

  static String _prioridadToString(PrioridadActividad prioridad) {
    switch (prioridad) {
      case PrioridadActividad.alta:
        return 'alta';
      case PrioridadActividad.baja:
        return 'baja';
      default:
        return 'media';
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
    PrioridadActividad? actividadPrioridad,
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
      actividadPrioridad: actividadPrioridad ?? this.actividadPrioridad,
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
