import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/curso_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/curso_viewmodel.dart';
import '../viewmodels/admin_viewmodel.dart';
import 'agregar_curso_view.dart';
import 'detalle_curso_view.dart';
import 'alumnos_view.dart';
import 'seguimiento_actividades_view.dart';
import 'avance_academico_view.dart';
import 'gestionar_docentes_view.dart';

class CursosView extends StatefulWidget {
  const CursosView({super.key});

  @override
  State<CursosView> createState() => CursosViewState();
}

class CursosViewState extends State<CursosView> {
  @override
  void initState() {
    super.initState();
    // Verificar si el usuario es admin al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final adminVM = Provider.of<AdminViewModel>(context, listen: false);
      if (authVM.user?.email != null) {
        adminVM.verificarAdmin(authVM.user!.email!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final cursoVM = Provider.of<CursoViewModel>(context);
    final adminVM = Provider.of<AdminViewModel>(context);
    final docenteId = authVM.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Cursos'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context, authVM, adminVM),
      body: StreamBuilder<List<Curso>>(
        stream: cursoVM.getCursosStream(docenteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cursos = snapshot.data ?? [];

          if (cursos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes cursos creados',
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
            itemCount: cursos.length,
            itemBuilder: (context, index) {
              final curso = cursos[index];
              return _buildCursoCard(context, curso);
            },
          );
        },
      ),
      floatingActionButton: adminVM.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AgregarCursoView()),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Agregar Curso'),
              backgroundColor: Colors.red.shade800,
            )
          : null,
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    AuthViewModel authVM,
    AdminViewModel adminVM,
  ) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.red.shade800),
            accountName: Text(
              authVM.user?.displayName ?? 'Docente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(authVM.user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: authVM.user?.photoURL != null
                  ? NetworkImage(authVM.user!.photoURL!)
                  : null,
              child: authVM.user?.photoURL == null
                  ? Icon(Icons.person, size: 40, color: Colors.red.shade800)
                  : null,
            ),
          ),
          ListTile(
            leading: Icon(Icons.school, color: Colors.red.shade800),
            title: Text('Cursos'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.assignment_turned_in,
              color: Colors.orange.shade700,
            ),
            title: Text('Seguimiento de Actividades'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeguimientoActividadesView(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart, color: Colors.purple.shade700),
            title: Text('Avance Académico'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AvanceAcademicoView()),
              );
            },
          ),
          // Opciones solo visibles para admin
          if (adminVM.isAdmin) ...[
            ListTile(
              leading: Icon(Icons.people, color: Colors.red.shade700),
              title: Text('Ingresar Alumno'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlumnosView()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.school, color: Colors.teal.shade700),
              title: Text('Gestionar Docentes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GestionarDocentesView(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.admin_panel_settings,
                color: Colors.indigo.shade700,
              ),
              title: Text('Cambiar Administrador'),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoCambiarAdmin(context, adminVM);
              },
            ),
          ],
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Cerrar Sesión'),
            onTap: () {
              authVM.logout(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCursoCard(BuildContext context, Curso curso) {
    final cursoVM = Provider.of<CursoViewModel>(context, listen: false);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleCursoView(curso: curso),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(curso.color), width: 3),
          ),
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
                        color: Color(curso.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        curso.nombreCurso,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditCursoDialog(context, curso);
                        } else if (value == 'delete') {
                          _showDeleteConfirmDialog(context, curso, cursoVM);
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
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      curso.nombreDocente,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        curso.horario,
                        style: TextStyle(color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditCursoDialog(BuildContext context, Curso curso) {
    final nombreController = TextEditingController(text: curso.nombreCurso);
    final docenteController = TextEditingController(text: curso.nombreDocente);
    final horarioController = TextEditingController(text: curso.horario);
    int selectedColor = curso.color;

    final List<Map<String, dynamic>> colores = [
      {'color': 0xFF2196F3, 'nombre': 'Azul'},
      {'color': 0xFF4CAF50, 'nombre': 'Verde'},
      {'color': 0xFFF44336, 'nombre': 'Rojo'},
      {'color': 0xFFFF9800, 'nombre': 'Naranja'},
      {'color': 0xFF9C27B0, 'nombre': 'Morado'},
      {'color': 0xFF00BCD4, 'nombre': 'Cyan'},
      {'color': 0xFFE91E63, 'nombre': 'Rosa'},
      {'color': 0xFF795548, 'nombre': 'Café'},
      {'color': 0xFFFFEB3B, 'nombre': 'Amarillo'},
      {'color': 0xFF3F51B5, 'nombre': 'Índigo'},
      {'color': 0xFF009688, 'nombre': 'Verde Azulado'},
      {'color': 0xFFCDDC39, 'nombre': 'Lima'},
      {'color': 0xFFFF5722, 'nombre': 'Naranja Oscuro'},
      {'color': 0xFF607D8B, 'nombre': 'Gris Azulado'},
      {'color': 0xFF8BC34A, 'nombre': 'Verde Lima'},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Editar Curso'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Curso',
                    prefixIcon: Icon(Icons.book),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: docenteController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Docente',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: horarioController,
                  decoration: InputDecoration(
                    labelText: 'Horario',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Color del Curso',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colores.map((colorData) {
                    final color = colorData['color'] as int;
                    final nombre = colorData['nombre'] as String;
                    final isSelected = selectedColor == color;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 50,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Color(color)
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(color),
                              radius: 16,
                            ),
                            SizedBox(height: 2),
                            Text(
                              nombre,
                              style: TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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
                final cursoVM = Provider.of<CursoViewModel>(
                  context,
                  listen: false,
                );

                await cursoVM.updateCurso(
                  cursoId: curso.id,
                  nombreCurso: nombreController.text,
                  nombreDocente: docenteController.text,
                  horario: horarioController.text,
                  color: selectedColor,
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
                      content: Text('Curso actualizado exitosamente'),
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

  void _showDeleteConfirmDialog(
    BuildContext context,
    Curso curso,
    CursoViewModel cursoVM,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el curso "${curso.nombreCurso}"?\n\n'
          'Esta acción también eliminará todas las actividades asociadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await cursoVM.deleteCurso(curso.id);
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
                    content: Text('Curso eliminado exitosamente'),
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

  void _mostrarDialogoCambiarAdmin(
    BuildContext context,
    AdminViewModel adminVM,
  ) async {
    // Cargar la configuración actual
    await adminVM.cargarConfig();

    if (!context.mounted) return;

    final emailController = TextEditingController();
    String? emailAReemplazar;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Gestionar Administradores'),
        content: StatefulBuilder(
          builder: (context, setState) {
            // ignore: sized_box_for_whitespace
            return Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 48,
                    color: Colors.indigo,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Administradores actuales (${adminVM.cantidadAdmins}/3):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...adminVM.adminEmails.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final email = entry.value;
                    final isSelected = emailAReemplazar == email;
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? Colors.orange
                            : Colors.indigo,
                        child: Text(
                          '$index',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        email,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? Colors.orange : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!adminVM.puedeAgregarAdmin)
                            IconButton(
                              icon: Icon(
                                Icons.swap_horiz,
                                color: isSelected ? Colors.orange : Colors.grey,
                              ),
                              tooltip: 'Seleccionar para reemplazar',
                              onPressed: () {
                                setState(() {
                                  emailAReemplazar = isSelected ? null : email;
                                });
                              },
                            ),
                          if (adminVM.cantidadAdmins > 1)
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmar = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Confirmar'),
                                    content: Text(
                                      '¿Eliminar a $email como administrador?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmar == true) {
                                  await adminVM.eliminarAdmin(email);
                                  setState(() {});
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          adminVM.error ??
                                              'Administrador eliminado',
                                        ),
                                        backgroundColor: adminVM.error != null
                                            ? Colors.red
                                            : Colors.red.shade600,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                        ],
                      ),
                    );
                  }),

                  Divider(),
                  SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email del nuevo administrador',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          if (adminVM.puedeAgregarAdmin)
            ElevatedButton.icon(
              onPressed: () async {
                final nuevoEmail = emailController.text;
                if (nuevoEmail.isNotEmpty && nuevoEmail.contains('@')) {
                  await adminVM.agregarAdmin(nuevoEmail);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          adminVM.error ??
                              'Administrador agregado exitosamente',
                        ),
                        backgroundColor: adminVM.error != null
                            ? Colors.red
                            : Colors.red.shade600,
                      ),
                    );
                  }
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ingrese un email válido'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: Icon(Icons.add),
              label: Text('Agregar Administrador'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: emailAReemplazar == null
                  ? null
                  : () async {
                      final nuevoEmail = emailController.text;
                      if (nuevoEmail.isNotEmpty && nuevoEmail.contains('@')) {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirmar Reemplazo'),
                            content: Text(
                              '¿Reemplazar a $emailAReemplazar por $nuevoEmail?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: Text('Reemplazar'),
                              ),
                            ],
                          ),
                        );

                        if (confirmar == true && context.mounted) {
                          await adminVM.reemplazarAdmin(
                            emailAReemplazar!,
                            nuevoEmail,
                          );
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          if (context.mounted) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  adminVM.error ??
                                      'Administrador reemplazado exitosamente',
                                ),
                                backgroundColor: adminVM.error != null
                                    ? Colors.red
                                    : Colors.red.shade600,
                              ),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ingrese un email válido'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              icon: Icon(Icons.swap_horiz),
              label: Text('Reemplazar Administrador'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
        ],
      ),
    );
  }
}
