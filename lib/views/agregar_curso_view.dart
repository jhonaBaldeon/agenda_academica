import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/curso_viewmodel.dart';

class AgregarCursoView extends StatefulWidget {
  const AgregarCursoView({super.key});

  @override
  State<AgregarCursoView> createState() => AgregarCursoViewState();
}

class AgregarCursoViewState extends State<AgregarCursoView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCursoController = TextEditingController();
  final _nombreDocenteController = TextEditingController();
  final _horarioController = TextEditingController();

  int _selectedColor = 0xFF2196F3; // Azul por defecto

  final List<Map<String, dynamic>> _colores = [
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

  @override
  void initState() {
    super.initState();
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    // Pre-llenar el nombre del docente si está disponible
    _nombreDocenteController.text = authVM.user?.displayName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final cursoVM = Provider.of<CursoViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Curso'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información del Curso',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              SizedBox(height: 20),

              // Nombre del curso
              TextFormField(
                controller: _nombreCursoController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Curso',
                  hintText: 'Ej: Matemáticas, Historia, Ciencias...',
                  prefixIcon: Icon(Icons.book),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del curso';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Nombre del docente
              TextFormField(
                controller: _nombreDocenteController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Docente',
                  hintText: 'Ej: Prof. Juan Pérez',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del docente';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Horario
              TextFormField(
                controller: _horarioController,
                decoration: InputDecoration(
                  labelText: 'Horario',
                  hintText: 'Ej: Lunes y Miércoles 8:00-10:00',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el horario';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Selección de color
              Text(
                'Color del Curso',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colores.map((colorData) {
                  final color = colorData['color'] as int;
                  final nombre = colorData['nombre'] as String;
                  final isSelected = _selectedColor == color;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 70,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(color).withValues(alpha: 0.2)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Color(color)
                              : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(color),
                            radius: 20,
                          ),
                          SizedBox(height: 4),
                          Text(
                            nombre,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 32),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: cursoVM.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            await cursoVM.createCurso(
                              nombreCurso: _nombreCursoController.text,
                              nombreDocente: _nombreDocenteController.text,
                              horario: _horarioController.text,
                              color: _selectedColor,
                              docenteId: authVM.user?.uid ?? '',
                            );

                            // Ignorar advertencia de BuildContext en async gaps
                            if (cursoVM.error == null && mounted) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Curso creado exitosamente'),
                                  backgroundColor: Colors.red.shade600,
                                ),
                              );
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            } else if (cursoVM.error != null) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(cursoVM.error!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: cursoVM.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Guardar Curso', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreCursoController.dispose();
    _nombreDocenteController.dispose();
    _horarioController.dispose();
    super.dispose();
  }
}
