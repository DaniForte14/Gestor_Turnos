import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:gestor_horarios_app/data/models/schedule_model.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';
import 'package:gestor_horarios_app/data/repositories/schedule_repository.dart';
import 'package:gestor_horarios_app/presentation/schedule/schedule_form_screen.dart';
import 'package:intl/intl.dart';

class MySchedulesScreen extends StatefulWidget {
  const MySchedulesScreen({Key? key}) : super(key: key);

  @override
  _MySchedulesScreenState createState() => _MySchedulesScreenState();
}

class _MySchedulesScreenState extends State<MySchedulesScreen> {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  late Future<List<Schedule>> _schedulesFuture;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMySchedules();
  }

  Future<void> _loadMySchedules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id.toString();
      
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      _schedulesFuture = _scheduleRepository.getMySchedules(userId);
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los horarios: $e';
      });
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
        title: const Text('Mis Turnos Solicitados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadMySchedules,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScheduleFormScreen(),
            ),
          ).then((_) {
            // Recargar la lista después de crear un nuevo turno
            _loadMySchedules();
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMySchedules,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<Schedule>>(
      future: _schedulesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Error al cargar los horarios',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadMySchedules,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final schedules = snapshot.data ?? [];

        if (schedules.isEmpty) {
          return const Center(
            child: Text('No hay turnos solicitados'),
          );
        }

        return ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return _buildScheduleCard(schedule);
          },
        );
      },
    );
  }

  // Helper method to convert TimeOfDay to DateTime
  DateTime _timeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  Widget _buildScheduleCard(Schedule schedule) {
    final dateFormat = DateFormat('EEEE, d MMMM y', 'es_ES');
    final timeFormat = DateFormat('HH:mm');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          _showScheduleOptions(schedule);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(schedule.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(schedule.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatStatus(schedule.status),
                      style: TextStyle(
                        color: _getStatusColor(schedule.status),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${timeFormat.format(_timeOfDayToDateTime(TimeOfDay(hour: int.parse(schedule.startTime.split(':')[0]), minute: int.parse(schedule.startTime.split(':')[1]))))} - ${timeFormat.format(_timeOfDayToDateTime(TimeOfDay(hour: int.parse(schedule.endTime.split(':')[0]), minute: int.parse(schedule.endTime.split(':')[1]))))}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.work, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    schedule.role,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              if (schedule.description?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(schedule.description!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'AVAILABLE':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pendiente';
      case 'APPROVED':
        return 'Aprobado';
      case 'REJECTED':
        return 'Rechazado';
      case 'AVAILABLE':
        return 'Disponible';
      default:
        return status;
    }
  }

  Future<void> _showScheduleOptions(Schedule schedule) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar turno', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context, 'delete');
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(context, 'cancel'),
              ),
            ],
          ),
        );
      },
    );

    if (result == 'delete') {
      await _deleteSchedule(schedule.id);
    }
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar turno'),
        content: const Text('¿Estás seguro de que deseas eliminar este turno?'),
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

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)),
            SizedBox(width: 16),
            Text('Eliminando turno...'),
          ],
        ),
        duration: Duration(seconds: 5),
      ),
    );

    try {
      await _scheduleRepository.deleteSchedule(scheduleId);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Turno eliminado correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Recargar la lista de turnos
      _loadMySchedules();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      String errorMessage = 'Error al eliminar el turno';
      if (e is DioError) {
        if (e.response?.statusCode == 404) {
          errorMessage = 'El turno no existe o ya ha sido eliminado';
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'No tienes permiso para eliminar este turno';
        } else {
          errorMessage = 'Error de red: ${e.message}';
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $errorMessage'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: () => _deleteSchedule(scheduleId),
          ),
        ),
      );
    }
  }
}
