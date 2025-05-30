import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleFormScreen extends StatefulWidget {
  const ScheduleFormScreen({Key? key}) : super(key: key);

  @override
  _ScheduleFormScreenState createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 15, minute: 0);
  String? _selectedShiftType;
  String? _selectedRole;

  // Available options
  final List<String> _shiftTypes = ['Mañana', 'Tarde', 'Noche'];
  final List<String> _roles = ['MÉDICO', 'ENFERMERO', 'TCAE'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar la lógica para guardar el horario
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedStartTime = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
      final formattedEndTime = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';
      
      print('Fecha: $formattedDate');
      print('Hora inicio: $formattedStartTime');
      print('Hora fin: $formattedEndTime');
      print('Turno: $_selectedShiftType');
      print('Rol: $_selectedRole');
      
      // Mostrar mensaje de éxito y volver
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horario guardado correctamente')),
      );
      
      // Volver a la pantalla anterior después de guardar
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Horario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de fecha
              ListTile(
                title: const Text('Fecha'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const Divider(),
              
              // Selector de hora de inicio
              ListTile(
                title: const Text('Hora de inicio'),
                subtitle: Text(_startTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, true),
              ),
              const Divider(),
              
              // Selector de hora de fin
              ListTile(
                title: const Text('Hora de fin'),
                subtitle: Text(_endTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, false),
              ),
              const Divider(),
              
              // Selector de tipo de turno
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Tipo de turno',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedShiftType,
                  items: _shiftTypes.map((shift) {
                    return DropdownMenuItem(
                      value: shift,
                      child: Text(shift),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedShiftType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor selecciona un tipo de turno';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Selector de rol
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Para el rol',
                  border: OutlineInputBorder(),
                ),
                value: _selectedRole,
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona un rol';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Botón de guardar
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Guardar Horario',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
