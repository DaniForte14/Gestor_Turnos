import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:gestor_horarios_app/data/models/schedule_model.dart';
import 'package:gestor_horarios_app/data/repositories/schedule_repository.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  
  // Calendar state
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  // Schedule data
  List<Schedule> _schedules = [];
  List<Schedule> _filteredSchedules = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _checkAdminStatus();
    await _loadSchedules();
  }

  Future<void> _checkAdminStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isAdmin = authProvider.currentUser?.isAdmin ?? false;
    });
  }

  Future<void> _loadSchedules() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      debugPrint('🔍 Cargando horarios para el usuario: ${currentUser.id}');
      
      // Cargar tanto los horarios del usuario como los turnos asignados
      final schedules = await _scheduleRepository.getSchedules();
      final myShifts = await _scheduleRepository.getMySchedules(currentUser.id.toString());
      
      // Combinar y eliminar duplicados
      final allSchedules = [...schedules, ...myShifts].toSet().toList();
      
      debugPrint('✅ ${allSchedules.length} horarios cargados correctamente (${schedules.length} horarios + ${myShifts.length} turnos)');
      
      if (mounted) {
        setState(() {
          _schedules = allSchedules;
          _filteredSchedules = _filterSchedulesByDate(_selectedDay);
          _errorMessage = null;
          _isAdmin = currentUser.isAdmin;
        });
      }
      
    } on DioError catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message ?? 'Error desconocido';
      debugPrint('❌ Error de red/API: $errorMsg');
      
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Error de conexión: $errorMsg';
      });
      
      // Mostrar snackbar con el error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar horarios: $errorMsg'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Error inesperado al cargar los horarios';
      });
      
      // Mostrar snackbar con el error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error inesperado al cargar los horarios'),
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

  List<Schedule> _filterSchedulesByDate(DateTime? date) {
    if (date == null || _schedules.isEmpty) return [];
    
    // Filter schedules for the selected date
    final filtered = _schedules.where((schedule) {
      return schedule.date.year == date.year &&
             schedule.date.month == date.month &&
             schedule.date.day == date.day;
    }).toList();
    
    // Sort by start time
    filtered.sort((a, b) {
      final aTime = TimeOfDay(
        hour: int.parse(a.startTime.split(':')[0]),
        minute: int.parse(a.startTime.split(':')[1]),
      );
      final bTime = TimeOfDay(
        hour: int.parse(b.startTime.split(':')[0]),
        minute: int.parse(b.startTime.split(':')[1]),
      );
      
      final aInMinutes = aTime.hour * 60 + aTime.minute;
      final bInMinutes = bTime.hour * 60 + bTime.minute;
      
      return aInMinutes.compareTo(bInMinutes);
    });
    
    return filtered;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _filteredSchedules = _filterSchedulesByDate(_selectedDay);
      });
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: TableCalendar<dynamic>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        onDaySelected: _onDaySelected,
        onPageChanged: _onPageChanged,
        eventLoader: (day) {
          // Return a list with a single item if there are schedules on this day
          return _schedules.where((schedule) => 
            schedule.date.year == day.year &&
            schedule.date.month == day.month &&
            schedule.date.day == day.day
          ).map((schedule) => schedule).toList();
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          markersAlignment: Alignment.bottomCenter,
          markerMargin: const EdgeInsets.only(top: 4),
          markerSize: 8,
          todayTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          selectedTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadSchedules,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            : _filteredSchedules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay horarios para esta fecha',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selecciona otra fecha o crea un nuevo horario',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        if (_isAdmin)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navegar a la creación de horario
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Crear horario'),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = _filteredSchedules[index];
                      final isApproved = schedule.status == 'APPROVED';
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Mostrar detalles del horario
                            _showScheduleDetails(schedule);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Indicador de estado
                                Container(
                                  width: 4,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(schedule.status),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Contenido del horario
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            _getRoleIcon(schedule.role),
                                            size: 20,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            schedule.role,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (isApproved)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.green[200]!),
                                              ),
                                              child: const Text(
                                                'Confirmado',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_formatTimeString(schedule.startTime)} - ${_formatTimeString(schedule.endTime)}',
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (schedule.description?.isNotEmpty ?? false) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          schedule.description!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
  }

  // Muestra los detalles completos de un horario
  void _showScheduleDetails(Schedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getRoleIcon(schedule.role),
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  schedule.role,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.calendar_today, 'Fecha',
                DateFormat('EEEE, d MMMM y', 'es_ES').format(schedule.date)),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.access_time, 'Horario',
                '${_formatTimeString(schedule.startTime)} - ${_formatTimeString(schedule.endTime)}'),
            if (schedule.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.description, 'Descripción', schedule.description!),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      'Cerrar',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                if (_isAdmin) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _editSchedule(schedule);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Editar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Construye una fila de detalle para el diálogo
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Obtiene el color según el estado del horario
  Color _getStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Obtiene el ícono según el rol
  IconData _getRoleIcon(String role) {
    switch (role.toUpperCase()) {
      case 'MÉDICO':
      case 'MEDICO':
        return Icons.medical_services;
      case 'ENFERMERO':
      case 'ENFERMERA':
        return Icons.medication;
      case 'TCAE':
        return Icons.medical_information;
      default:
        return Icons.person;
    }
  }

  // Formatea la hora en un formato legible
  String _formatTimeString(String timeString) {
    try {
      final timeFormat = DateFormat('HH:mm');
      final dateTime = timeFormat.parse(timeString);
      return timeFormat.format(dateTime);
    } catch (e) {
      return timeString; // Return original string if parsing fails
    }
  }

  // Edita un horario (solo para administradores)
  void _editSchedule(Schedule schedule) {
    // TODO: Implementar funcionalidad de edición
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de edición no implementada'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSchedules,
            tooltip: 'Actualizar horarios',
          ),
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Navegar a la pantalla de creación de horario
              },
              tooltip: 'Crear nuevo horario',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSchedules,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendar(),
              const SizedBox(height: 16),
              _buildScheduleList(),
            ],
          ),
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => _addSchedule(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _addSchedule() {
    // TODO: Implement add schedule functionality
    if (_selectedDay != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Añadir horario para ${DateFormat.yMMMd().format(_selectedDay!)}'),
        ),
      );
    }
  }
}
