class EstadisticaCurso {
  final String cursoId;
  final String cursoNombre;
  final int color;
  final int totalAlumnos;
  final int completados;
  final int incompletos;
  final int noRealizados;

  EstadisticaCurso({
    required this.cursoId,
    required this.cursoNombre,
    required this.color,
    required this.totalAlumnos,
    required this.completados,
    required this.incompletos,
    required this.noRealizados,
  });

  int get totalActividades => completados + incompletos + noRealizados;
  
  double get porcentajeCompletados => totalActividades > 0 
      ? (completados / totalActividades) * 100 
      : 0;
  
  double get porcentajeIncompletos => totalActividades > 0 
      ? (incompletos / totalActividades) * 100 
      : 0;
  
  double get porcentajeNoRealizados => totalActividades > 0 
      ? (noRealizados / totalActividades) * 100 
      : 0;

  String get rendimiento {
    final porcentaje = porcentajeCompletados;
    if (porcentaje >= 90) {
      return 'Excelente';
    } else if (porcentaje >= 60) {
      return 'Regular';
    } else {
      return 'En proceso de Aprendizaje';
    }
  }

  String get colorRendimiento {
    final porcentaje = porcentajeCompletados;
    if (porcentaje >= 90) {
      return 'verde';
    } else if (porcentaje >= 60) {
      return 'amarillo';
    } else {
      return 'anaranjado';
    }
  }
}

class EstadisticaGlobal {
  final int totalAlumnos;
  final int totalCursos;
  final int totalCompletados;
  final int totalIncompletos;
  final int totalNoRealizados;

  EstadisticaGlobal({
    required this.totalAlumnos,
    required this.totalCursos,
    required this.totalCompletados,
    required this.totalIncompletos,
    required this.totalNoRealizados,
  });

  int get totalActividades => totalCompletados + totalIncompletos + totalNoRealizados;
  
  double get porcentajeCompletados => totalActividades > 0 
      ? (totalCompletados / totalActividades) * 100 
      : 0;
  
  double get porcentajeIncompletos => totalActividades > 0 
      ? (totalIncompletos / totalActividades) * 100 
      : 0;
  
  double get porcentajeNoRealizados => totalActividades > 0 
      ? (totalNoRealizados / totalActividades) * 100 
      : 0;

  String get rendimientoGlobal {
    final porcentaje = porcentajeCompletados;
    if (porcentaje >= 90) {
      return 'Excelente';
    } else if (porcentaje >= 60) {
      return 'Regular';
    } else {
      return 'En proceso de Aprendizaje';
    }
  }

  String get colorRendimientoGlobal {
    final porcentaje = porcentajeCompletados;
    if (porcentaje >= 90) {
      return 'verde';
    } else if (porcentaje >= 60) {
      return 'amarillo';
    } else {
      return 'anaranjado';
    }
  }
}
