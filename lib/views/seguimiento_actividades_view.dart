import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alumno_model.dart';
import '../models/curso_model.dart';
import '../models/seguimiento_actividad_model.dart';
import '../viewmodels/alumno_viewmodel.dart';
import '../viewmodels/curso_viewmodel.dart';
import '../viewmodels/seguimiento_viewmodel.dart';

class SeguimientoActividadesView extends StatefulWidget {
  const SeguimientoActividadesView({super.key});

  @override
  State<SeguimientoActividadesView> createState() =>
      _SeguimientoActividadesViewState();
}

class _SeguimientoActividadesViewState
    extends State<SeguimientoActividadesView> {
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
        title: Text('Seguimiento de Actividades'),
        backgroundColor: Colors.red.shade800,
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
                        labelText: 'Seleccionar Alumno',
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
                          child: Text('Todos los alumnos'),
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
                        labelText: 'Seleccionar Curso',
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
                          child: Text('Todos los cursos'),
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
                  'No hay seguimientos registrados',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Las actividades aparecerán aquí cuando se creen',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: seguimientos.length,
          itemBuilder: (context, index) {
            final seguimiento = seguimientos[index];
            return _buildSeguimientoCard(context, seguimiento, seguimientoVM);
          },
        );
      },
    );
  }

  Widget _buildSeguimientoCard(
    BuildContext context,
    SeguimientoActividad seguimiento,
    SeguimientoViewModel seguimientoVM,
  ) {
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
            // Información del alumno
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.shade800,
                  child: Text(
                    seguimiento.alumnoNombre.isNotEmpty
                        ? seguimiento.alumnoNombre.substring(0, 1).toUpperCase()
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
                        seguimiento.alumnoNombre,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        seguimiento.cursoNombre,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(),
            // Información de la actividad
            Text(
              seguimiento.actividadTitulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              seguimiento.actividadDescripcion,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'Fecha de entrega: ${_formatFecha(seguimiento.actividadFechaEntrega)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(),
            // Estado con menú
            Row(
              children: [
                Icon(estadoIcono, color: estadoColor),
                SizedBox(width: 8),
                Text(
                  'Estado: $estadoTexto',
                  style: TextStyle(
                    color: estadoColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                PopupMenuButton<EstadoSeguimiento>(
                  icon: Icon(Icons.edit, color: Colors.grey[600]),
                  tooltip: 'Cambiar estado',
                  onSelected: (nuevoEstado) async {
                    await seguimientoVM.updateEstadoSeguimiento(
                      seguimiento.id,
                      nuevoEstado,
                    );
                    // Ignorar advertencia de BuildContext en async gaps
                    if (seguimientoVM.error != null && mounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(seguimientoVM.error!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: EstadoSeguimiento.completado,
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Completado'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: EstadoSeguimiento.incompleto,
                      child: Row(
                        children: [
                          Icon(Icons.timelapse, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Incompleto'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: EstadoSeguimiento.noRealizado,
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          SizedBox(width: 8),
                          Text('No Realizado'),
                        ],
                      ),
                    ),
                  ],
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
                    style: TextStyle(color: Colors.red.shade600, fontSize: 12),
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
