import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alumno_model.dart';
import '../viewmodels/alumno_viewmodel.dart';

class AlumnosView extends StatelessWidget {
  const AlumnosView({super.key});

  @override
  Widget build(BuildContext context) {
    final alumnoVM = Provider.of<AlumnoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Alumnos'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Alumno>>(
        stream: alumnoVM.getAlumnosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final alumnos = snapshot.data ?? [];

          if (alumnos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay alumnos registrados',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Presiona el botón + para agregar uno',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: alumnos.length,
            itemBuilder: (context, index) {
              final alumno = alumnos[index];
              return _buildAlumnoCard(context, alumno, alumnoVM);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAlumnoDialog(context, null);
        },
        icon: Icon(Icons.add),
        label: Text('Agregar Alumno'),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }

  Widget _buildAlumnoCard(
    BuildContext context,
    Alumno alumno,
    AlumnoViewModel alumnoVM,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade800,
          child: Text(
            alumno.apellidoPaterno.isNotEmpty
                ? alumno.apellidoPaterno.substring(0, 1).toUpperCase()
                : '?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          alumno.nombreCompleto,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Grado: ${alumno.grado} - Sección: ${alumno.seccion}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'edit') {
              _showAlumnoDialog(context, alumno);
            } else if (value == 'delete') {
              _showDeleteConfirmDialog(context, alumno, alumnoVM);
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
      ),
    );
  }

  void _showAlumnoDialog(BuildContext context, Alumno? alumno) {
    final isEditing = alumno != null;
    final nombresController = TextEditingController(
      text: isEditing ? alumno.nombres : '',
    );
    final apellidoPaternoController = TextEditingController(
      text: isEditing ? alumno.apellidoPaterno : '',
    );
    final apellidoMaternoController = TextEditingController(
      text: isEditing ? alumno.apellidoMaterno : '',
    );
    final gradoController = TextEditingController(
      text: isEditing ? alumno.grado : '',
    );
    final seccionController = TextEditingController(
      text: isEditing ? alumno.seccion : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Alumno' : 'Agregar Alumno'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombresController,
                decoration: InputDecoration(
                  labelText: 'Nombres',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: apellidoPaternoController,
                decoration: InputDecoration(
                  labelText: 'Apellido Paterno',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: apellidoMaternoController,
                decoration: InputDecoration(
                  labelText: 'Apellido Materno',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: gradoController,
                decoration: InputDecoration(
                  labelText: 'Grado',
                  prefixIcon: Icon(Icons.school),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: seccionController,
                decoration: InputDecoration(
                  labelText: 'Sección',
                  prefixIcon: Icon(Icons.class_),
                ),
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
              final alumnoVM = Provider.of<AlumnoViewModel>(
                context,
                listen: false,
              );

              if (isEditing) {
                await alumnoVM.updateAlumno(
                  alumnoId: alumno.id,
                  nombres: nombresController.text,
                  apellidoPaterno: apellidoPaternoController.text,
                  apellidoMaterno: apellidoMaternoController.text,
                  grado: gradoController.text,
                  seccion: seccionController.text,
                );
              } else {
                await alumnoVM.createAlumno(
                  nombres: nombresController.text,
                  apellidoPaterno: apellidoPaternoController.text,
                  apellidoMaterno: apellidoMaternoController.text,
                  grado: gradoController.text,
                  seccion: seccionController.text,
                );
              }

              // ignore: use_build_context_synchronously
              Navigator.pop(context);

              if (alumnoVM.error != null) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(alumnoVM.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Alumno actualizado exitosamente'
                          : 'Alumno creado exitosamente',
                    ),
                    backgroundColor: Colors.red.shade600,
                  ),
                );
              }
            },
            child: Text(isEditing ? 'Actualizar' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    Alumno alumno,
    AlumnoViewModel alumnoVM,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${alumno.nombreCompleto}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await alumnoVM.deleteAlumno(alumno.id);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);

              if (alumnoVM.error != null) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(alumnoVM.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Alumno eliminado exitosamente'),
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
}
