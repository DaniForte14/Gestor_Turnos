import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gestor_horarios_app/data/models/schedule_model.dart';
import 'package:gestor_horarios_app/data/repositories/schedule_repository.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';

class ScheduleFormScreen extends StatefulWidget {
  final Schedule? schedule;
  final bool isRequest;
  
  const ScheduleFormScreen({
    Key? key, 
    this.schedule,
    this.isRequest = false,
  }) : super(key: key);

  @override
  _ScheduleFormScreenState createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scheduleRepository = ScheduleRepository();
  
  // Form fields
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String? _selectedRole;
  String? _description;
  bool _isLoading = false;
  String? _errorMessage;

  // Available roles with display names
  final Map<String, String> _roles = {
    'ROLE_MEDICO': 'MÉDICO',
    'ROLE_ENFERMERO': 'ENFERMERO/A',
    'ROLE_TCAE': 'TCAE',
  };

  @override
  void initState() {
    super.initState();
    // Initialize with current date and time
    final now = DateTime.now();
    _selectedDate = widget.schedule?.date ?? now;
    
    if (widget.schedule != null) {
      // Editing existing schedule
      final startParts = widget.schedule!.startTime.split(':');
      final endParts = widget.schedule!.endTime.split(':');
      _startTime = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
      _endTime = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
      _selectedRole = widget.schedule!.role;
      _description = widget.schedule!.description;
    } else {
      // New schedule - default to next hour
      _startTime = TimeOfDay(hour: now.hour + 1, minute: 0);
      _endTime = TimeOfDay(hour: now.hour + 2, minute: 0);
      // Establecer el primer rol disponible como predeterminado
      _selectedRole = _roles.isNotEmpty ? _roles.keys.first : 'ROLE_USER';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  bool _validateForm() {
    if (_selectedRole == null || _selectedRole!.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor selecciona un rol';
      });
      return false;
    }

    final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _startTime.hour, _startTime.minute);
    final end = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _endTime.hour, _endTime.minute);
    
    if (end.isBefore(start)) {
      setState(() {
        _errorMessage = 'La hora de fin debe ser posterior a la hora de inicio';
      });
      return false;
    }

    setState(() {
      _errorMessage = null;
    });
    return true;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id.toString();
      if (userId == null) throw Exception('Usuario no autenticado');

      // Format time with seconds
      final startTimeStr = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}:00';
      final endTimeStr = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}:00';
      
      // Get the role key (should already be in ROLE_XXX format from _roles map keys)
      final selectedRole = _selectedRole ?? _roles.keys.first;
      
      // Ensure the role is in the correct format for the backend
      final formattedRole = selectedRole.startsWith('ROLE_') 
          ? selectedRole 
          : 'ROLE_${selectedRole.toUpperCase()}';
      
      // Format date as yyyy-MM-dd
      final formattedDate = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      
      debugPrint('Creando horario con fecha: $formattedDate');
      debugPrint('Hora inicio: $startTimeStr, Hora fin: $endTimeStr');
      debugPrint('Rol seleccionado: $formattedRole');

      final schedule = Schedule(
        id: widget.schedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: widget.isRequest ? widget.schedule!.date : _selectedDate,
        startTime: startTimeStr,
        endTime: endTimeStr,
        role: formattedRole, // Use the properly formatted role
        description: _description,
        status: widget.isRequest ? 'PENDING' : 'AVAILABLE',
        isPublished: !widget.isRequest,
        createdBy: widget.isRequest ? widget.schedule!.createdBy : userId,
        assignedTo: widget.isRequest ? userId : null,
      );
      
      debugPrint('Enviando horario: ${schedule.toJson()}');

      if (widget.isRequest) {
        // Enviar solicitud de horario
        await _scheduleRepository.requestSchedule(
          scheduleId: schedule.id,
          userId: userId,
        );
      } else if (widget.schedule != null) {
        await _scheduleRepository.updateSchedule(schedule);
      } else {
        debugPrint('Enviando horario al backend: ${schedule.toJson()}');
        await _scheduleRepository.createSchedule(schedule);
      }

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isRequest 
              ? 'Solicitud enviada exitosamente' 
              : widget.schedule == null 
                ? 'Horario creado exitosamente' 
                : 'Horario actualizado exitosamente'
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Error al procesar la solicitud: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool get _isEditing => widget.schedule?.id != null;

  Widget _buildDateField(BuildContext context) {
    return ListTile(
      title: const Text('Fecha'),
      subtitle: Text(DateFormat('EEEE, d MMMM y', 'es_ES').format(_selectedDate)),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildTimeFields(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Hora de inicio'),
          subtitle: Text(_startTime.format(context)),
          trailing: const Icon(Icons.access_time),
          onTap: () => _selectTime(context, true),
        ),
        ListTile(
          title: const Text('Hora de fin'),
          subtitle: Text(_endTime.format(context)),
          trailing: const Icon(Icons.access_time),
          onTap: () => _selectTime(context, false),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    // Get role entries and sort them for consistent ordering
    final roleEntries = _roles.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    // Ensure we have a valid selected role
    final selectedRoleKey = _selectedRole ?? _roles.keys.first;
    
    debugPrint('Current selected role key: $selectedRoleKey');
    debugPrint('Available roles: ${_roles.toString()}');

    return DropdownButtonFormField<String>(
      value: selectedRoleKey,
      decoration: const InputDecoration(
        labelText: 'Rol',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isExpanded: true,
      items: roleEntries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(
            entry.value,
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: _isLoading 
          ? null 
          : (String? newValue) {
              if (newValue != null) {
                debugPrint('Role changed to: $newValue');
                setState(() {
                  _selectedRole = newValue;
                });
              }
            },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor selecciona un rol';
        }
        if (!_roles.containsKey(value)) {
          return 'Rol no válido';
        }
        return null;
      },
    );
  }
  


  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Descripción (opcional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      initialValue: _description,
      onChanged: (value) => _description = value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isRequest 
            ? 'Solicitar Horario' 
            : widget.schedule != null
              ? 'Editar Horario' 
              : 'Nuevo Horario'
        ),
        actions: [
          if (widget.schedule != null && !widget.isRequest)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteSchedule,
              tooltip: 'Eliminar horario',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!widget.isRequest) _buildDateField(context),
                    if (!widget.isRequest) const SizedBox(height: 16),
                    _buildTimeFields(context),
                    if (!widget.isRequest) const SizedBox(height: 16),
                    if (!widget.isRequest) _buildRoleDropdown(),
                    if (widget.isRequest) ...[
                      Text(
                        'Rol: ${_roles[widget.schedule?.role] ?? widget.schedule?.role ?? ''}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(widget.schedule?.date ?? DateTime.now())}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildDescriptionField(),
                    const SizedBox(height: 16),
                    // Error message
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    // Submit button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(widget.isRequest ? 'Enviar Solicitud' : 'Guardar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Future<void> _deleteSchedule() async {
    if (widget.schedule == null || _isLoading) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar horario'),
        content: const Text('¿Estás seguro de que quieres eliminar este horario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _scheduleRepository.deleteSchedule(widget.schedule!.id);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horario eliminado correctamente')),
      );
      
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el horario: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
