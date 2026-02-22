import 'package:cloud_firestore/cloud_firestore.dart';

enum PrioridadActividad { alta, media, baja }

enum EstadoActividad { completado, incompleto, noRealizado }

class Actividad {
  final String id;
  final String cursoId;
  final String titulo;
  final String descripcion;
  final DateTime fechaEntrega;
  final PrioridadActividad prioridad;
  final EstadoActividad estado;
  final DateTime createdAt;

  Actividad({
    required this.id,
    required this.cursoId,
    required this.titulo,
    required this.descripcion,
    required this.fechaEntrega,
    required this.prioridad,
    this.estado = EstadoActividad.incompleto,
    required this.createdAt,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      id: json['id'] ?? '',
      cursoId: json['curso_id'] ?? json['cursoId'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fechaEntrega: json['fecha_entrega'] != null 
          ? DateTime.tryParse(json['fecha_entrega'].toString()) ?? DateTime.now()
          : DateTime.now(),
      prioridad: _prioridadFromString(json['prioridad'] ?? 'media'),
      estado: _estadoFromString(json['estado'] ?? 'incompleto'),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  factory Actividad.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Actividad(
      id: doc.id,
      cursoId: data['cursoId'] ?? '',
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      fechaEntrega: (data['fechaEntrega'] as Timestamp?)?.toDate() ?? DateTime.now(),
      prioridad: _prioridadFromString(data['prioridad'] ?? 'media'),
      estado: _estadoFromString(data['estado'] ?? 'incompleto'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cursoId': cursoId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaEntrega': Timestamp.fromDate(fechaEntrega),
      'prioridad': _prioridadToString(prioridad),
      'estado': _estadoToString(estado),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'curso_id': cursoId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_entrega': fechaEntrega.toIso8601String(),
      'prioridad': _prioridadToString(prioridad),
      'estado': _estadoToString(estado),
      'created_at': createdAt.toIso8601String(),
    };
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

  static EstadoActividad _estadoFromString(String value) {
    switch (value) {
      case 'completado':
        return EstadoActividad.completado;
      case 'noRealizado':
        return EstadoActividad.noRealizado;
      default:
        return EstadoActividad.incompleto;
    }
  }

  static String _estadoToString(EstadoActividad estado) {
    switch (estado) {
      case EstadoActividad.completado:
        return 'completado';
      case EstadoActividad.noRealizado:
        return 'noRealizado';
      default:
        return 'incompleto';
    }
  }
}
