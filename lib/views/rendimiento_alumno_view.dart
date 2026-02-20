import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../viewmodels/rendimiento_alumno_viewmodel.dart';
import '../viewmodels/alumno_viewmodel.dart';
import '../models/avance_academico_model.dart';
import '../models/alumno_model.dart';

class RendimientoAlumnoView extends StatefulWidget {
  const RendimientoAlumnoView({super.key});

  @override
  State<RendimientoAlumnoView> createState() => _RendimientoAlumnoViewState();
}

class _RendimientoAlumnoViewState extends State<RendimientoAlumnoView> {
  String? _alumnoIdSeleccionado;

  @override
  Widget build(BuildContext context) {
    final alumnoVM = Provider.of<AlumnoViewModel>(context);
    final rendimientoVM = Provider.of<RendimientoAlumnoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendimiento Académico'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: StreamBuilder<List<Alumno>>(
              stream: alumnoVM.getAlumnosStream(),
              builder: (context, snapshot) {
                final alumnos = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  initialValue: _alumnoIdSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Seleccione el Alumno',
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.yellow.shade50,
                  ),
                  hint: const Text('Seleccione un alumno'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Seleccione un alumno'),
                    ),
                    ...alumnos.map(
                      (alumno) => DropdownMenuItem<String>(
                        value: alumno.id,
                        child: Text(alumno.nombreCompleto),
                      ),
                    ),
                  ],
                  onChanged: (alumnoId) {
                    setState(() {
                      _alumnoIdSeleccionado = alumnoId;
                    });
                    if (alumnoId != null) {
                      rendimientoVM.calcularEstadisticasPorAlumno(alumnoId);
                    }
                  },
                );
              },
            ),
          ),
          Expanded(child: _buildContent(rendimientoVM)),
        ],
      ),
    );
  }

  Widget _buildContent(RendimientoAlumnoViewModel viewModel) {
    if (_alumnoIdSeleccionado == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Seleccione un alumno',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'para ver su rendimiento académico',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar estadísticas',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            Text(viewModel.error!),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          viewModel.calcularEstadisticasPorAlumno(_alumnoIdSeleccionado!),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (viewModel.estadisticaGlobal != null)
              _buildGlobalStats(
                viewModel.estadisticaGlobal!,
                viewModel.alumnoSeleccionado,
              ),
            const SizedBox(height: 24),
            Text(
              'Rendimiento por Curso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 16),
            if (viewModel.estadisticasCursos.isEmpty)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.school, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No hay datos disponibles',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              ...viewModel.estadisticasCursos.map(
                (estadistica) => _buildCursoCard(estadistica),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStats(EstadisticaGlobal global, Alumno? alumno) {
    final porcentaje = global.porcentajeCompletados / 100;
    final colorRendimiento = _getColorRendimiento(global.rendimientoGlobal);
    final nombreAlumno = alumno?.nombreCompleto ?? 'Alumno';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Rendimiento Global',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularPercentIndicator(
                  radius: 80,
                  lineWidth: 12,
                  percent: porcentaje,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${global.porcentajeCompletados.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorRendimiento,
                        ),
                      ),
                      const Text(
                        'Completado',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  progressColor: colorRendimiento,
                  backgroundColor: Colors.grey.shade200,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatItem(
                      'Total Cursos',
                      global.totalCursos,
                      Colors.red.shade600,
                    ),
                    const SizedBox(height: 8),
                    _buildStatItem(
                      'Total Actividades',
                      global.totalActividades,
                      Colors.red.shade400,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(height: 200, child: _buildBarChart(global)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorRendimiento.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorRendimiento, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'Rendimiento Académico de:',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nombreAlumno,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    global.rendimientoGlobal,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorRendimiento,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDescripcionRendimiento(global.rendimientoGlobal),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCursoCard(EstadisticaCurso estadistica) {
    final colorRendimiento = _getColorRendimiento(estadistica.rendimiento);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(estadistica.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    estadistica.cursoNombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorRendimiento.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estadistica.rendimiento,
                    style: TextStyle(
                      color: colorRendimiento,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(height: 180, child: _buildPieChart(estadistica)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(
                  'Completado',
                  estadistica.completados,
                  Colors.green,
                ),
                _buildLegendItem(
                  'Incompleto',
                  estadistica.incompletos,
                  Colors.orange,
                ),
                _buildLegendItem(
                  'No Realizado',
                  estadistica.noRealizados,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: estadistica.porcentajeCompletados / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(colorRendimiento),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Text(
              '${estadistica.porcentajeCompletados.toStringAsFixed(1)}% completado',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ],
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(EstadisticaGlobal global) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: global.totalActividades > 0
            ? global.totalActividades.toDouble()
            : 10,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String text = '';
                switch (value.toInt()) {
                  case 0:
                    text = 'Completado';
                    break;
                  case 1:
                    text = 'Incompleto';
                    break;
                  case 2:
                    text = 'No Realizado';
                    break;
                }
                return Text(
                  text,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: global.totalCompletados.toDouble(),
                color: Colors.green,
                width: 40,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: global.totalIncompletos.toDouble(),
                color: Colors.orange,
                width: 40,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: global.totalNoRealizados.toDouble(),
                color: Colors.red,
                width: 40,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
        ],
        gridData: const FlGridData(show: false),
      ),
    );
  }

  Widget _buildPieChart(EstadisticaCurso estadistica) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: estadistica.completados.toDouble(),
            title: '${estadistica.porcentajeCompletados.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.orange,
            value: estadistica.incompletos.toDouble(),
            title: '${estadistica.porcentajeIncompletos.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.red,
            value: estadistica.noRealizados.toDouble(),
            title: '${estadistica.porcentajeNoRealizados.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorRendimiento(String rendimiento) {
    switch (rendimiento) {
      case 'Excelente':
        return Colors.green;
      case 'Regular':
        return Colors.amber;
      case 'En proceso de Aprendizaje':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getDescripcionRendimiento(String rendimiento) {
    switch (rendimiento) {
      case 'Excelente':
        return '≥90% de actividades completadas';
      case 'Regular':
        return '60-89% de actividades completadas';
      case 'En proceso de Aprendizaje':
        return '<60% de actividades completadas';
      default:
        return '';
    }
  }
}
