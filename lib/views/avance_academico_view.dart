import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../viewmodels/avance_academico_viewmodel.dart';
import '../models/avance_academico_model.dart';

class AvanceAcademicoView extends StatefulWidget {
  const AvanceAcademicoView({super.key});

  @override
  State<AvanceAcademicoView> createState() => _AvanceAcademicoViewState();
}

class _AvanceAcademicoViewState extends State<AvanceAcademicoView> {
  @override
  void initState() {
    super.initState();
    // Calcular estadísticas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AvanceAcademicoViewModel>(
        context,
        listen: false,
      ).calcularEstadisticas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AvanceAcademicoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Avance Académico'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : viewModel.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error al cargar estadísticas',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  Text(viewModel.error!),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.calcularEstadisticas(),
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => viewModel.calcularEstadisticas(),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección Global
                    if (viewModel.estadisticaGlobal != null)
                      _buildGlobalStats(viewModel.estadisticaGlobal!),

                    SizedBox(height: 24),

                    // Sección por Curso
                    Text(
                      'Estadísticas por Curso',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                    SizedBox(height: 16),

                    if (viewModel.estadisticasCursos.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No hay datos estadísticos disponibles',
                              style: TextStyle(color: Colors.grey),
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
            ),
    );
  }

  Widget _buildGlobalStats(EstadisticaGlobal global) {
    final porcentaje = global.porcentajeCompletados / 100;
    final colorRendimiento = _getColorRendimiento(global.rendimientoGlobal);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Estadística Global del Aula',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gráfico circular de progreso
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
                      Text(
                        'Completado',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  progressColor: colorRendimiento,
                  backgroundColor: Colors.grey.shade200,
                  circularStrokeCap: CircularStrokeCap.round,
                ),

                // Resumen numérico
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatItem(
                      'Total Cursos',
                      global.totalCursos,
                      Colors.red.shade600,
                    ),
                    SizedBox(height: 8),
                    _buildStatItem(
                      'Total Alumnos',
                      global.totalAlumnos,
                      Colors.red.shade500,
                    ),
                    SizedBox(height: 8),
                    _buildStatItem(
                      'Total Actividades',
                      global.totalActividades,
                      Colors.red.shade400,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Gráfico de barras
            SizedBox(height: 200, child: _buildBarChart(global)),

            SizedBox(height: 20),

            // Rendimiento Académico
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorRendimiento.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorRendimiento, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'Rendimiento Académico del Aula',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    global.rendimientoGlobal,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorRendimiento,
                    ),
                  ),
                  SizedBox(height: 4),
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
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
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
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    estadistica.cursoNombre,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            SizedBox(height: 16),

            // Gráfico de pastel
            SizedBox(height: 180, child: _buildPieChart(estadistica)),

            SizedBox(height: 16),

            // Leyenda
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

            SizedBox(height: 12),

            // Porcentaje completado
            LinearProgressIndicator(
              value: estadistica.porcentajeCompletados / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(colorRendimiento),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: 4),
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
        SizedBox(width: 8),
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
            SizedBox(width: 4),
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
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
        ],
        gridData: FlGridData(show: false),
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
            titleStyle: TextStyle(
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
            titleStyle: TextStyle(
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
            titleStyle: TextStyle(
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
