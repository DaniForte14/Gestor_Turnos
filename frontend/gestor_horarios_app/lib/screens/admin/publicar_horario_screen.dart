import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/core/utils/api_client.dart';
import 'package:gestor_horarios_app/data/models/horario.dart';
import 'package:gestor_horarios_app/data/repositories/horario_repository.dart';
import 'package:gestor_horarios_app/data/services/horario_service.dart';
import 'package:intl/intl.dart';

class PublicarHorarioScreen extends StatefulWidget {
  const PublicarHorarioScreen({Key? key}) : super(key: key);

  @override
  _PublicarHorarioScreenState createState() => _PublicarHorarioScreenState();
}

class _PublicarHorarioScreenState extends State<PublicarHorarioScreen> {
  _PublicarHorarioScreenState() : _horarioService = HorarioService(
    HorarioRepository(ApiClient()),
  );
  final _formKey = GlobalKey<FormState>();
  // Inyectar el servicio de horarios a través del constructor
  final HorarioService _horarioService;
  
  final _fechaController = TextEditingController();
  final _horaInicioController = TextEditingController();
  final _horaFinController = TextEditingController();
  final _notasController = TextEditingController();
  
  bool _isLoading = false;
  
  final List<MapEntry<TipoJornada, String>> _tiposTurno = [
    MapEntry(TipoJornada.MANANA, 'Mañana'),
    MapEntry(TipoJornada.TARDE, 'Tarde'),
    MapEntry(TipoJornada.NOCHE, 'Noche'),
    MapEntry(TipoJornada.COMPLETA, 'Jornada Completa'),
  ];
  
  TipoJornada _tipoJornada = TipoJornada.MANANA;
  
  // Roles disponibles para selección
  final Map<String, bool> _rolesSeleccionados = {
    'ROLE_MEDICO': false,
    'ROLE_ENFERMERO': false,
    'ROLE_TCAE': false,
  };
  
  // Mapeo de códigos de rol a nombres legibles
  final Map<String, String> _nombresRoles = {
    'ROLE_MEDICO': 'Médico',
    'ROLE_ENFERMERO': 'Enfermero/a',
    'ROLE_TCAE': 'TCAE',
  };
  
  @override
  void dispose() {
    _fechaController.dispose();
    _horaInicioController.dispose();
    _horaFinController.dispose();
    _notasController.dispose();
    super.dispose();
  }
  
  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (fecha != null) {
      _fechaController.text = DateFormat('dd/MM/yyyy').format(fecha);
    }
  }
  
  Future<void> _seleccionarHora(TextEditingController controller) async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (hora != null) {
      controller.text = '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
    }
  }
  
  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Verificar que se haya seleccionado al menos un rol
    if (!_rolesSeleccionados.values.any((seleccionado) => seleccionado)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona al menos un rol')),
        );
      }
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final fecha = DateFormat('dd/MM/yyyy').parse(_fechaController.text);
      final horaInicio = _horaInicioController.text;
      final horaFin = _horaFinController.text;
      
      // Obtener la lista de roles seleccionados
      final rolesSeleccionados = _rolesSeleccionados.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      
      final horario = Horario(
        id: 0, // El ID será generado por el backend
        fecha: fecha,
        horaInicio: horaInicio,
        horaFin: horaFin,
        tipoJornada: _tipoJornada,
        notas: _notasController.text.isEmpty ? null : _notasController.text,
        activo: true,
        roles: rolesSeleccionados,
      );
      
      // Usar el método crearHorarioDisponible del servicio
      await _horarioService.crearHorarioDisponible(
        fecha: horario.fecha,
        horaInicio: TimeOfDay(
          hour: int.parse(horario.horaInicio.split(':')[0]),
          minute: int.parse(horario.horaInicio.split(':')[1]),
        ),
        horaFin: TimeOfDay(
          hour: int.parse(horario.horaFin.split(':')[0]),
          minute: int.parse(horario.horaFin.split(':')[1]),
        ),
        tipoJornada: horario.tipoJornada,
        notas: horario.notas,
        roles: rolesSeleccionados, // Añadir los roles seleccionados
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horario publicado exitosamente')),
        );
        _formKey.currentState!.reset();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar el horario: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Horario Disponible'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo de fecha
              TextFormField(
                controller: _fechaController,
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _seleccionarFecha,
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona una fecha';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16.0),
              
              // Campos de hora de inicio y fin
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _horaInicioController,
                      decoration: InputDecoration(
                        labelText: 'Hora de inicio',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _seleccionarHora(_horaInicioController),
                        ),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: _horaFinController,
                      decoration: InputDecoration(
                        labelText: 'Hora de fin',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _seleccionarHora(_horaFinController),
                        ),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16.0),
              
              // Dropdown para seleccionar el tipo de jornada
              DropdownButtonFormField<TipoJornada>(
                value: _tipoJornada,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Jornada',
                  border: OutlineInputBorder(),
                ),
                items: _tiposTurno.map((entry) {
                  return DropdownMenuItem<TipoJornada>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _tipoJornada = value;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 16.0),
              
              // Sección de selección de roles
              const Text(
                'Roles permitidos:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              // Lista de checkboxes para seleccionar roles
              ..._rolesSeleccionados.entries.map((entry) {
                return CheckboxListTile(
                  title: Text(_nombresRoles[entry.key] ?? entry.key),
                  value: entry.value,
                  onChanged: (bool? value) {
                    setState(() {
                      _rolesSeleccionados[entry.key] = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
              
              const SizedBox(height: 16.0),
              
              // Campo de observaciones
              const SizedBox(height: 24.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Observaciones (Opcional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _notasController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe aquí cualquier observación relevante...',
                        contentPadding: EdgeInsets.all(12.0),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24.0),
              
              // Botón de envío
              ElevatedButton(
                onPressed: _isLoading ? null : _enviarFormulario,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Publicar Horario',
                        style: TextStyle(fontSize: 16.0),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
