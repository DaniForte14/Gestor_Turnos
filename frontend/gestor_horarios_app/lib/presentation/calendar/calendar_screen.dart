import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gestor_horarios_app/data/models/schedule_model.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';
import 'package:gestor_horarios_app/data/repositories/schedule_repository.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Schedule> _schedules = [];
  bool _isLoading = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _checkUserRole();
    _loadSchedules();
  }

  void _checkUserRole() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isAdmin = authProvider.currentUser?.roles.any((role) => 
        role == 'ROLE_ADMIN' || role == 'ADMIN' || role == 'ADMINISTRADOR'
      ) ?? false;
    });
  }

  Future<void> _loadSchedules() async {
    if (_selectedDay == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String roleToUse = 'MEDICO'; // Default role
      if (!_isAdmin && authProvider.currentUser != null) {
        roleToUse = authProvider.currentUser!.roles.firstWhere(
          (role) => ['TCAE', 'ENFERMERO', 'MEDICO'].contains(role),
          orElse: () => 'MEDICO',
        );
      }

      final schedules = await _scheduleRepository.getPublishedSchedules(
        date: _selectedDay!,
        role: roleToUse,
      );

      setState(() {
        _schedules = schedules;
      });
    } catch (e) {
      debugPrint('Error loading schedules: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar los horarios'),
            backgroundColor: Colors.red,
          ),
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

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    await _loadSchedules();
  }

  Widget _buildScheduleList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_schedules.isEmpty) {
      return const Center(
        child: Text('No hay horarios publicados para este día'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _schedules.length,
      itemBuilder: (context, index) {
        final schedule = _schedules[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text('${schedule.startTime} - ${schedule.endTime}'),
            subtitle: Text('Rol: ${schedule.role}'),
            trailing: _buildScheduleAction(schedule),
          ),
        );
      },
    );
  }

  Widget _buildScheduleAction(Schedule schedule) {
    if (_isAdmin) {
      return const SizedBox.shrink();
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final isMySchedule = schedule.assignedTo == authProvider.currentUser?.id.toString();
    
    if (isMySchedule) {
      return const Text(
        'Asignado a ti',
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    }

    if (schedule.status == 'PENDING' || schedule.status == 'REJECTED') {
      return Text(
        schedule.status == 'PENDING' ? 'Pendiente' : 'Rechazado',
        style: TextStyle(
          color: schedule.status == 'PENDING' ? Colors.orange : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (schedule.status != 'AVAILABLE') {
      return const Text('No disponible');
    }

    return ElevatedButton(
      onPressed: () => _requestSchedule(schedule),
      child: const Text('Solicitar'),
    );
  }

  Future<void> _requestSchedule(Schedule schedule) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.id == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _scheduleRepository.requestSchedule(
        scheduleId: schedule.id,
        userId: authProvider.currentUser!.id.toString(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud de horario enviada'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadSchedules();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al solicitar horario: $e'),
            backgroundColor: Colors.red,
          ),
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

  void _showAddScheduleDialog() {
    if (_selectedDay == null) return;

    final formKey = GlobalKey<FormState>();
    String startTime = '08:00';
    String endTime = '16:00';
    String? selectedRole = 'ENFERMERO';
    String? description;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir horario'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Día: ${_selectedDay!.toString().split(' ')[0]}'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: ['TCAE', 'ENFERMERO', 'MEDICO']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                  onChanged: (value) => selectedRole = value,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  validator: (value) =>
                      value == null ? 'Selecciona un rol' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Hora de inicio',
                    hintText: 'HH:MM',
                  ),
                  initialValue: startTime,
                  onChanged: (value) => startTime = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Hora de fin',
                    hintText: 'HH:MM',
                  ),
                  initialValue: endTime,
                  onChanged: (value) => endTime = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                  ),
                  maxLines: 2,
                  onChanged: (value) => description = value,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                await _createSchedule(
                  startTime: startTime,
                  endTime: endTime,
                  role: selectedRole!,
                  description: description,
                );
              }
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _createSchedule({
    required String startTime,
    required String endTime,
    required String role,
    String? description,
  }) async {
    if (_selectedDay == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final newSchedule = Schedule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDay!,
        startTime: startTime,
        endTime: endTime,
        role: role,
        description: description,
        isPublished: true,
        createdBy: authProvider.currentUser?.id.toString(),
        status: 'AVAILABLE',
      );

      await _scheduleRepository.createSchedule(newSchedule);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horario creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadSchedules();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear horario: $e'),
            backgroundColor: Colors.red,
          ),
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
        title: const Text('Calendario'),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.publish),
              onPressed: _loadSchedules,
              tooltip: 'Actualizar horarios',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  formatButtonTextStyle: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Horarios para ${_selectedDay?.toString().split(' ')[0] ?? ''}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildScheduleList(),
          ],
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _showAddScheduleDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
