import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_horarios_app/data/models/schedule_model.dart';
import 'package:gestor_horarios_app/data/repositories/schedule_repository.dart';
import 'package:gestor_horarios_app/presentation/schedule/schedule_form_screen.dart';
import 'package:intl/intl.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({Key? key}) : super(key: key);

  @override
  _ScheduleListScreenState createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  late Future<List<Schedule>> _schedulesFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _schedulesFuture = _scheduleRepository.getSchedules();
    });
  }

  Future<void> _navigateToAddSchedule() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScheduleFormScreen(),
      ),
    );

    if (result == true) {
      _loadSchedules();
    }
  }

  Future<void> _editSchedule(Schedule schedule) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleFormScreen(schedule: schedule),
      ),
    );

    if (result == true) {
      _loadSchedules();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Horarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isLoading ? null : _navigateToAddSchedule,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadSchedules,
          ),
        ],
      ),
      body: FutureBuilder<List<Schedule>>(
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
                  const Text('Error al cargar los horarios'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSchedules,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final schedules = snapshot.data ?? [];

          if (schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay horarios programados',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _navigateToAddSchedule,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear horario'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadSchedules,
            child: ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return _buildScheduleCard(schedule);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _navigateToAddSchedule,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    final dateFormat = DateFormat('EEEE, d MMMM y', 'es_ES');
    final timeFormat = DateFormat('HH:mm');
    
    // Parse times for display
    final startTime = '${schedule.startTime}:00';
    final endTime = '${schedule.endTime}:00';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _editSchedule(schedule),
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
                      _getStatusText(schedule.status),
                      style: TextStyle(
                        color: _getStatusColor(schedule.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
                    '$startTime - $endTime',
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
    switch (status) {
      case 'AVAILABLE':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'AVAILABLE':
        return 'Disponible';
      case 'PENDING':
        return 'Pendiente';
      case 'APPROVED':
        return 'Aprobado';
      case 'REJECTED':
        return 'Rechazado';
      default:
        return status;
    }
  }
}
