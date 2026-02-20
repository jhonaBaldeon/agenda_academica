import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alumno_model.dart';
import '../models/curso_model.dart';
import '../models/seguimiento_actividad_model.dart';
import '../viewmodels/alumno_viewmodel.dart';
import '../viewmodels/curso_viewmodel.dart';
import '../viewmodels/seguimiento_viewmodel.dart';

class CumplimientoAlumnoView extends StatefulWidget {
  const CumplimientoAlumnoView({super.key});

  @override
  State<CumplimientoAlumnoView> createState() => _CumplimientoAlumnoViewState();
}

class _CumplimientoAlumnoViewState extends State<CumplimientoAlumnoView> {
  String? _alumnoIdSeleccionado;
  String? _cursoIdSeleccionado;
  List<Alumno> _alumnosList = [];
  List<Curso> _cursosList = [];
  bool _inicializado = false;

  @override
  Widget build(BuildContext context) {
    final alumnoVM = Provider.of<AlumnoViewModel>(context);
    final cursoVM = Provider.of<CursoViewModel>(context);
    final seguimientoVM = Provider.of<SeguimientoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cumplimiento del Alumno'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                // Filtro de Alumno
                StreamBuilder<List<Alumno>>(
                  stream: alumnoVM.getAlumnosStream(),
                  builder: (context, snapshot) {
                    _alumnosList = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      initialValue: _alumnoIdSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Seleccione el Alumno',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.yellow.shade50,
                      ),
                      hint: Text('Todos los alumnos'),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Seleccione un alumno'),
                        ),
                        ..._alumnosList.map(
                          (alumno) => DropdownMenuItem<String>(
                            value: alumno.id,
                            child: Text(alumno.nombreCompleto),
                          ),
                        ),
                      ],
                      onChanged: (alumnoId) {
                        setState(() {
                          _alumnoIdSeleccionado = alumnoId;
                          // Si solo se selecciona alumno sin curso, usar primer curso
                          if (alumnoId != null &&
                              (_cursoIdSeleccionado == null ||
                                  _cursoIdSeleccionado!.isEmpty)) {
                            if (_cursosList.isNotEmpty) {
                              _cursoIdSeleccionado = _cursosList.first.id;
                            }
                          }
                        });
                        seguimientoVM.setAlumnoFiltro(alumnoId);
                        seguimientoVM.setCursoFiltro(_cursoIdSeleccionado);
                      },
                    );
                  },
                ),
                SizedBox(height: 12),
                // Filtro de Curso
                StreamBuilder<List<Curso>>(
                  stream: cursoVM.getAllCursosStream(),
                  builder: (context, snapshot) {
                    _cursosList = snapshot.data ?? [];

                    // Inicializar con el primer curso si no se ha inicializado y hay cursos
                    if (!_inicializado && _cursosList.isNotEmpty) {
                      _inicializado = true;
                      _cursoIdSeleccionado = _cursosList.first.id;
                      // Deferir la llamada a notifyListeners() hasta después de que el widget se haya construido
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        seguimientoVM.setCursoFiltro(_cursoIdSeleccionado);
                      });
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _cursoIdSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Seleccione el Curso',
                        prefixIcon: Icon(Icons.school),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.yellow.shade50,
                      ),
                      hint: Text('Todos los cursos'),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Seleccione un curso'),
                        ),
                        ..._cursosList.map(
                          (curso) => DropdownMenuItem<String>(
                            value: curso.id,
                            child: Text(curso.nombreCurso),
                          ),
                        ),
                      ],
                      onChanged: (cursoId) {
                        setState(() {
                          _cursoIdSeleccionado = cursoId;
                        });
                        seguimientoVM.setCursoFiltro(cursoId);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          // Lista de seguimientos
          Expanded(child: _buildSeguimientosList(seguimientoVM)),
        ],
      ),
    );
  }

  Widget _buildSeguimientosList(SeguimientoViewModel seguimientoVM) {
    return StreamBuilder<List<SeguimientoActividad>>(
      stream: seguimientoVM.getSeguimientosStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final seguimientos = snapshot.data ?? [];

        if (seguimientos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay actividades registradas',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Seleccione un alumno y/o curso para ver las actividades',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // Obtener el nombre del alumno del primer seguimiento
        final nombreAlumno = seguimientos.isNotEmpty
            ? seguimientos.first.alumnoNombre
            : '';

        return Column(
          children: [
            // Información del alumno seleccionado
            if (_alumnoIdSeleccionado != null && nombreAlumno.isNotEmpty)
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red.shade600,
                      child: Text(
                        nombreAlumno.isNotEmpty
                            ? nombreAlumno.substring(0, 1).toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alumno:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            nombreAlumno,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // Lista de actividades
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: seguimientos.length,
                itemBuilder: (context, index) {
                  final seguimiento = seguimientos[index];
                  return _buildSeguimientoCard(seguimiento);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeguimientoCard(SeguimientoActividad seguimiento) {
    Color estadoColor;
    String estadoTexto;
    IconData estadoIcono;

    switch (seguimiento.estado) {
      case EstadoSeguimiento.completado:
        estadoColor = Colors.green;
        estadoTexto = 'Completado';
        estadoIcono = Icons.check_circle;
        break;
      case EstadoSeguimiento.noRealizado:
        estadoColor = Colors.red;
        estadoTexto = 'No Realizado';
        estadoIcono = Icons.cancel;
        break;
      default:
        estadoColor = Colors.orange;
        estadoTexto = 'Incompleto';
        estadoIcono = Icons.timelapse;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Curso
            Row(
              children: [
                Icon(Icons.school, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    seguimiento.cursoNombre,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Título de actividad
            Text(
              seguimiento.actividadTitulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            SizedBox(height: 4),
            // Descripción
            Text(
              seguimiento.actividadDescripcion,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            SizedBox(height: 12),
            Divider(),
            // Fecha de entrega y estado
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'Entrega: ${_formatFecha(seguimiento.actividadFechaEntrega)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: estadoColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(estadoIcono, color: estadoColor, size: 16),
                      SizedBox(width: 4),
                      Text(
                        estadoTexto,
                        style: TextStyle(
                          color: estadoColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (seguimiento.fechaCompletado != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.red.shade600,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Completado el: ${_formatFecha(seguimiento.fechaCompletado!)}',
                    style: TextStyle(color: Colors.red.shade600, fontSize: 11),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}
