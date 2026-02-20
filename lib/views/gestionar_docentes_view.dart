import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/docentes_viewmodel.dart';
import '../models/docente_registrado_model.dart';

class GestionarDocentesView extends StatelessWidget {
  const GestionarDocentesView({super.key});

  @override
  Widget build(BuildContext context) {
    final docentesVM = Provider.of<DocentesViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Docentes'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<DocenteRegistrado>>(
        stream: docentesVM.getDocentesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docentes = snapshot.data ?? [];

          if (docentes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No hay docentes registrados',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Presiona el botón + para agregar uno',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docentes.length,
            itemBuilder: (context, index) {
              final docente = docentes[index];
              return _buildDocenteCard(context, docente, docentesVM);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _mostrarDialogoAgregarDocente(context, docentesVM);
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Docente'),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }

  Widget _buildDocenteCard(
    BuildContext context,
    DocenteRegistrado docente,
    DocentesViewModel docentesVM,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: docente.activo ? Colors.red.shade800 : Colors.grey,
          child: Text(
            docente.nombre.isNotEmpty
                ? docente.nombre.substring(0, 1).toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          docente.nombre,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Email: ${docente.email}'),
            Text(
              docente.activo ? 'Estado: Activo' : 'Estado: Inactivo',
              style: TextStyle(
                color: docente.activo ? Colors.red.shade600 : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'toggle') {
              docentesVM.toggleEstadoDocente(docente);
            } else if (value == 'delete') {
              _mostrarDialogoEliminar(context, docente, docentesVM);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    docente.activo ? Icons.block : Icons.check_circle,
                    color: docente.activo ? Colors.orange : Colors.red.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(docente.activo ? 'Desactivar' : 'Activar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarDocente(
    BuildContext context,
    DocentesViewModel docentesVM,
  ) {
    final nombreController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Docente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombreController.text.isEmpty ||
                  emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Todos los campos son obligatorios'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await docentesVM.registrarDocente(
                nombre: nombreController.text,
                email: emailController.text,
              );

              // ignore: use_build_context_synchronously
              Navigator.pop(context);

              if (docentesVM.error != null) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(docentesVM.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Docente registrado exitosamente'),
                    backgroundColor: Colors.red.shade600,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminar(
    BuildContext context,
    DocenteRegistrado docente,
    DocentesViewModel docentesVM,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${docente.nombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await docentesVM.eliminarDocente(docente.id);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);

              if (docentesVM.error != null) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(docentesVM.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Docente eliminado exitosamente'),
                    backgroundColor: Colors.red.shade600,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
