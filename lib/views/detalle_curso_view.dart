import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/curso_model.dart';
import '../models/actividad_model.dart';
import '../viewmodels/curso_viewmodel.dart';
import 'agregar_actividad_view.dart';

class DetalleCursoView extends StatelessWidget {
  final Curso curso;

  const DetalleCursoView({super.key, required this.curso});

  @override
  Widget build(BuildContext context) {
    final cursoVM = Provider.of<CursoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(curso.nombreCurso),
        backgroundColor: Color(curso.color),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Info del curso
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(curso.color).withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(color: Color(curso.color), width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  curso.nombreCurso,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(curso.color),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 16),
                    SizedBox(width: 4),
                    Text(curso.nombreDocente),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16),
                    SizedBox(width: 4),
                    Text(curso.horario),
                  ],
                ),
              ],
            ),
          ),

          // Lista de actividades
          Expanded(
            child: StreamBuilder<List<Actividad>>(
              stream: cursoVM.getActividadesStream(curso.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final actividades = snapshot.data ?? [];

                if (actividades.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay actividades',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Presiona el botón + para agregar una',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: actividades.length,
                  itemBuilder: (context, index) {
                    final actividad = actividades[index];
                    return _buildActividadCard(context, actividad, cursoVM);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarActividadView(
                cursoId: curso.id,
                cursoNombre: curso.nombreCurso,
              ),
            ),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Agregar Actividad'),
        backgroundColor: Color(curso.color),
      ),
    );
  }

  Widget _buildActividadCard(
    BuildContext context,
    Actividad actividad,
    CursoViewModel cursoVM,
  ) {
    Color prioridadColor;
    String prioridadTexto;

    switch (actividad.prioridad) {
      case PrioridadActividad.alta:
        prioridadColor = Colors.red;
        prioridadTexto = 'Alta';
        break;
      case PrioridadActividad.baja:
        prioridadColor = Colors.green;
        prioridadTexto = 'Baja';
        break;
      default:
        prioridadColor = Colors.orange;
        prioridadTexto = 'Media';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    actividad.titulo,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: prioridadColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    prioridadTexto,
                    style: TextStyle(
                      color: prioridadColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditActividadDialog(context, actividad, cursoVM);
                    } else if (value == 'delete') {
                      _showDeleteConfirmDialog(context, actividad, cursoVM);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.red.shade600),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              actividad.descripcion,
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'Entrega: ${_formatFecha(actividad.fechaEntrega)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditActividadDialog(
    BuildContext context,
    Actividad actividad,
    CursoViewModel cursoVM,
  ) {
    final tituloController = TextEditingController(text: actividad.titulo);
    final descripcionController = TextEditingController(
      text: actividad.descripcion,
    );

    DateTime fechaEntrega = actividad.fechaEntrega;
    TimeOfDay horaEntrega = TimeOfDay.fromDateTime(actividad.fechaEntrega);
    PrioridadActividad prioridad = actividad.prioridad;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Editar Actividad'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título de la Actividad',
                    prefixIcon: Icon(Icons.assignment),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: fechaEntrega,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (fecha != null) {
                      setState(() {
                        fechaEntrega = fecha;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha de Entrega',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${fechaEntrega.day}/${fechaEntrega.month}/${fechaEntrega.year}',
                    ),
                  ),
                ),
                SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final hora = await showTimePicker(
                      context: context,
                      initialTime: horaEntrega,
                    );
                    if (hora != null) {
                      setState(() {
                        horaEntrega = hora;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Hora de Entrega',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    child: Text(
                      '${horaEntrega.hour.toString().padLeft(2, '0')}:${horaEntrega.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Prioridad',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildPrioridadOption(
                      context,
                      PrioridadActividad.alta,
                      'Alta',
                      Colors.red,
                      prioridad == PrioridadActividad.alta,
                      (value) => setState(() => prioridad = value),
                    ),
                    SizedBox(width: 8),
                    _buildPrioridadOption(
                      context,
                      PrioridadActividad.media,
                      'Media',
                      Colors.orange,
                      prioridad == PrioridadActividad.media,
                      (value) => setState(() => prioridad = value),
                    ),
                    SizedBox(width: 8),
                    _buildPrioridadOption(
                      context,
                      PrioridadActividad.baja,
                      'Baja',
                      Colors.red.shade400,
                      prioridad == PrioridadActividad.baja,
                      (value) => setState(() => prioridad = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final fechaHoraEntrega = DateTime(
                  fechaEntrega.year,
                  fechaEntrega.month,
                  fechaEntrega.day,
                  horaEntrega.hour,
                  horaEntrega.minute,
                );

                await cursoVM.updateActividad(
                  actividadId: actividad.id,
                  titulo: tituloController.text,
                  descripcion: descripcionController.text,
                  fechaEntrega: fechaHoraEntrega,
                  prioridad: prioridad,
                );

                // ignore: use_build_context_synchronously
                Navigator.pop(context);

                if (cursoVM.error != null) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(cursoVM.error!),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Actividad actualizada exitosamente'),
                      backgroundColor: Colors.red.shade600,
                    ),
                  );
                }
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioridadOption(
    BuildContext context,
    PrioridadActividad prioridad,
    String label,
    Color color,
    bool isSelected,
    Function(PrioridadActividad) onSelected,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () => onSelected(prioridad),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : Colors.grey.shade100,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    Actividad actividad,
    CursoViewModel cursoVM,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la actividad "${actividad.titulo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await cursoVM.deleteActividad(actividad.id);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);

              if (cursoVM.error != null) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(cursoVM.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Actividad eliminada exitosamente'),
                    backgroundColor: Colors.red.shade600,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}
