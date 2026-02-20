import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/actividad_model.dart';
import '../viewmodels/curso_viewmodel.dart';

class AgregarActividadView extends StatefulWidget {
  final String cursoId;
  final String cursoNombre;

  const AgregarActividadView({
    super.key,
    required this.cursoId,
    required this.cursoNombre,
  });

  @override
  State<AgregarActividadView> createState() => AgregarActividadViewState();
}

class AgregarActividadViewState extends State<AgregarActividadView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  DateTime _fechaEntrega = DateTime.now().add(Duration(days: 7));
  TimeOfDay _horaEntrega = TimeOfDay(hour: 23, minute: 59);
  PrioridadActividad _prioridad = PrioridadActividad.media;

  @override
  Widget build(BuildContext context) {
    final cursoVM = Provider.of<CursoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Actividad'),
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
                'Información de la Actividad',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              SizedBox(height: 20),

              // Título
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título de la Actividad',
                  hintText: 'Ej: Tarea de Matemáticas, Proyecto...',
                  prefixIcon: Icon(Icons.assignment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el título';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe la actividad...',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Fecha de entrega
              InkWell(
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: _fechaEntrega,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                    locale: Locale('es', 'ES'),
                  );
                  if (fecha != null) {
                    setState(() {
                      _fechaEntrega = fecha;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha de Entrega',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_fechaEntrega.day}/${_fechaEntrega.month}/${_fechaEntrega.year}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Hora de entrega
              InkWell(
                onTap: () async {
                  final hora = await showTimePicker(
                    context: context,
                    initialTime: _horaEntrega,
                    builder: (BuildContext context, Widget? child) {
                      return MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      );
                    },
                  );
                  if (hora != null) {
                    setState(() {
                      _horaEntrega = hora;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hora Máxima de Entrega',
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_horaEntrega.hour.toString().padLeft(2, '0')}:${_horaEntrega.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Prioridad
              Text(
                'Prioridad',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildPrioridadOption(
                    PrioridadActividad.alta,
                    'Alta',
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                  SizedBox(width: 12),
                  _buildPrioridadOption(
                    PrioridadActividad.media,
                    'Media',
                    Colors.orange,
                    Icons.remove,
                  ),
                  SizedBox(width: 12),
                  _buildPrioridadOption(
                    PrioridadActividad.baja,
                    'Baja',
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                ],
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
                            // Combinar fecha y hora
                            final fechaHoraEntrega = DateTime(
                              _fechaEntrega.year,
                              _fechaEntrega.month,
                              _fechaEntrega.day,
                              _horaEntrega.hour,
                              _horaEntrega.minute,
                            );
                            await cursoVM.createActividad(
                              cursoId: widget.cursoId,
                              cursoNombre: widget.cursoNombre,
                              titulo: _tituloController.text,
                              descripcion: _descripcionController.text,
                              fechaEntrega: fechaHoraEntrega,
                              prioridad: _prioridad,
                            );

                            // Ignorar advertencia de BuildContext en async gaps
                            if (cursoVM.error == null && mounted) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Actividad creada exitosamente',
                                  ),
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
                      : Text(
                          'Guardar Actividad',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioridadOption(
    PrioridadActividad prioridad,
    String label,
    Color color,
    IconData icon,
  ) {
    final isSelected = _prioridad == prioridad;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _prioridad = prioridad;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : Colors.grey.shade100,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}
