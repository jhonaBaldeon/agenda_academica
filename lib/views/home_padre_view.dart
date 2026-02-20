import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/curso_model.dart';
import '../models/actividad_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/curso_viewmodel.dart';
import 'cumplimiento_alumno_view.dart';
import 'rendimiento_alumno_view.dart';

class HomePadreView extends StatelessWidget {
  const HomePadreView({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final cursoVM = Provider.of<CursoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cursos del Estudiante'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context, authVM),
      body: StreamBuilder<List<Curso>>(
        stream: cursoVM.getAllCursosStream(),
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
                    'No hay cursos disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Los docentes aún no han creado cursos',
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
              return _buildCursoCard(context, curso, cursoVM);
            },
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthViewModel authVM) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.red.shade600),
            accountName: Text(
              'Padre de Familia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text('Acceso sin autenticación'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.family_restroom,
                size: 40,
                color: Colors.red.shade600,
              ),
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
          ListTile(
            leading: Icon(
              Icons.assignment_turned_in,
              color: Colors.orange.shade700,
            ),
            title: Text('Cumplimiento del Alumno'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CumplimientoAlumnoView(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart, color: Colors.purple.shade700),
            title: Text('Rendimiento Académico'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RendimientoAlumnoView(),
                ),
              );
            },
          ),
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

  Widget _buildCursoCard(
    BuildContext context,
    Curso curso,
    CursoViewModel cursoVM,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: EdgeInsets.all(16),
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Color(curso.color),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          curso.nombreCurso,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(curso.nombreDocente),
            Text(
              curso.horario,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(curso.color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actividades',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(curso.color),
                  ),
                ),
                SizedBox(height: 8),
                StreamBuilder<List<Actividad>>(
                  stream: cursoVM.getActividadesStream(curso.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text('Error al cargar actividades');
                    }

                    final actividades = snapshot.data ?? [];

                    if (actividades.isEmpty) {
                      return Text(
                        'No hay actividades asignadas',
                        style: TextStyle(color: Colors.grey[600]),
                      );
                    }

                    return Column(
                      children: actividades.map((actividad) {
                        return _buildActividadItem(actividad);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadItem(Actividad actividad) {
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

    Color estadoColor;
    String estadoTexto;
    IconData estadoIcono;

    switch (actividad.estado) {
      case EstadoActividad.completado:
        estadoColor = Colors.green;
        estadoTexto = 'Completado';
        estadoIcono = Icons.check_circle;
        break;
      case EstadoActividad.noRealizado:
        estadoColor = Colors.red;
        estadoTexto = 'No Realizado';
        estadoIcono = Icons.cancel;
        break;
      default:
        estadoColor = Colors.orange;
        estadoTexto = 'Incompleto';
        estadoIcono = Icons.timelapse;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  actividad.titulo,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: prioridadColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  prioridadTexto,
                  style: TextStyle(
                    color: prioridadColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            actividad.descripcion,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text(
                'Entrega: ${_formatFecha(actividad.fechaEntrega)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Spacer(),
              Icon(estadoIcono, size: 14, color: estadoColor),
              SizedBox(width: 4),
              Text(
                estadoTexto,
                style: TextStyle(
                  fontSize: 12,
                  color: estadoColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}
