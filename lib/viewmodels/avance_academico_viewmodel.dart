import 'package:flutter/material.dart';
import '../models/avance_academico_model.dart';
import '../models/seguimiento_actividad_model.dart';
import '../repositories/seguimiento_repository.dart';
import '../repositories/curso_repository.dart';
import '../repositories/alumno_repository.dart';

class AvanceAcademicoViewModel extends ChangeNotifier {
  final SeguimientoRepository _seguimientoRepository = SeguimientoRepository();
  final CursoRepository _cursoRepository = CursoRepository();
  final AlumnoRepository _alumnoRepository = AlumnoRepository();

  bool _isLoading = false;
  String? _error;
  List<EstadisticaCurso> _estadisticasCursos = [];
  EstadisticaGlobal? _estadisticaGlobal;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<EstadisticaCurso> get estadisticasCursos => _estadisticasCursos;
  EstadisticaGlobal? get estadisticaGlobal => _estadisticaGlobal;

  Future<void> calcularEstadisticas() async {
    _setLoading(true);
    _error = null;

    try {
      // Obtener todos los cursos
      final cursosSnapshot = await _cursoRepository.getAllCursos().first;

      // Obtener todos los alumnos
      final alumnosSnapshot = await _alumnoRepository.getAllAlumnos().first;
      final totalAlumnos = alumnosSnapshot.length;

      List<EstadisticaCurso> estadisticasCursosList = [];
      int totalCompletadosGlobal = 0;
      int totalIncompletosGlobal = 0;
      int totalNoRealizadosGlobal = 0;

      for (final curso in cursosSnapshot) {
        // Obtener seguimientos del curso
        final seguimientosSnapshot = await _seguimientoRepository
            .getSeguimientosByCurso(curso.id)
            .first;

        int completados = 0;
        int incompletos = 0;
        int noRealizados = 0;

        for (final seguimiento in seguimientosSnapshot) {
          switch (seguimiento.estado) {
            case EstadoSeguimiento.completado:
              completados++;
              break;
            case EstadoSeguimiento.incompleto:
              incompletos++;
              break;
            case EstadoSeguimiento.noRealizado:
              noRealizados++;
              break;
          }
        }

        totalCompletadosGlobal += completados;
        totalIncompletosGlobal += incompletos;
        totalNoRealizadosGlobal += noRealizados;

        estadisticasCursosList.add(
          EstadisticaCurso(
            cursoId: curso.id,
            cursoNombre: curso.nombreCurso,
            color: curso.color,
            totalAlumnos: totalAlumnos,
            completados: completados,
            incompletos: incompletos,
            noRealizados: noRealizados,
          ),
        );
      }

      _estadisticasCursos = estadisticasCursosList;
      _estadisticaGlobal = EstadisticaGlobal(
        totalAlumnos: totalAlumnos,
        totalCursos: cursosSnapshot.length,
        totalCompletados: totalCompletadosGlobal,
        totalIncompletos: totalIncompletosGlobal,
        totalNoRealizados: totalNoRealizadosGlobal,
      );

      notifyListeners();
    } catch (e) {
      _error = 'Error al calcular estadísticas: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
