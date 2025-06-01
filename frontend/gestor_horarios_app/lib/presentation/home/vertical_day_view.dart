import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gestor_horarios_app/data/models/horario.dart';
import 'package:gestor_horarios_app/data/repositories/horario_repository.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';

class VerticalDayView extends StatefulWidget {
  const VerticalDayView({Key? key}) : super(key: key);

  @override
  _VerticalDayViewState createState() => _VerticalDayViewState();
}

class _VerticalDayViewState extends State<VerticalDayView> {
  bool _isLoading = true;
  Map<String, List<Horario>> _dailySchedules = {};
  late List<DateTime> _visibleDays;

  @override
  void initState() {
    super.initState();
    _initializeVisibleDays();
    _loadAllHorarios();
  }

  void _initializeVisibleDays() {
    final now = DateTime.now();
    _visibleDays = List.generate(7, (index) => DateTime(now.year, now.month, now.day + index));
  }

  Future<void> _loadAllHorarios() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _dailySchedules = {};
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final horarioRepository = Provider.of<HorarioRepository>(context, listen: false);
      
      // Get the user's first role or default to 'USER'
      final userRole = authProvider.currentUser?.roles.isNotEmpty == true
          ? authProvider.currentUser!.roles.first
          : 'USER';
      
      debugPrint('Fetching schedules for role: $userRole');
      
      // Load schedules for each visible day
      for (final day in _visibleDays) {
        try {
          final horarios = await horarioRepository.getHorariosDisponibles(
            fecha: day,
            rol: userRole,
          );
          
          if (mounted) {
            setState(() {
              _dailySchedules[_formatDateKey(day)] = horarios;
            });
          }
        } catch (e) {
          debugPrint('Error loading schedules for ${_formatDateKey(day)}: $e');
          // Continue with next day even if one fails
        }
      }
    } catch (e) {
      debugPrint('Error in _loadAllHorarios: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar los horarios')),
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
  
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadAllHorarios,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _visibleDays.length,
        itemBuilder: (context, index) {
          final day = _visibleDays[index];
          final daySchedules = _dailySchedules[_formatDateKey(day)] ?? [];
          final isToday = index == 0;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            elevation: isToday ? 4.0 : 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: isToday 
                  ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0)
                  : BorderSide.none,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Day header
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isToday 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    _formatDayHeader(day),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: isToday 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black87,
                    ),
                  ),
                ),
                
                // Schedules list
                if (daySchedules.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No hay horarios disponibles'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: daySchedules.length,
                    itemBuilder: (context, index) {
                      final horario = daySchedules[index];
                      return ListTile(
                        title: Text(
                          '${horario.horaInicio} - ${horario.horaFin}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(horario.tipoJornada.toString().split('.').last),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navegar al detalle del horario
                        },
                      );
                    },
                  ),
                
                // Add button for admin users
                if (_isAdminUser)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          // TODO: Implementar añadir horario
                        },
                        tooltip: 'Añadir horario',
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Check if current user is admin
  bool get _isAdminUser {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.currentUser?.roles.any((role) => 
      role == 'ROLE_ADMIN' || role == 'ADMIN' || role == 'ADMINISTRADOR'
    ) ?? false;
  }
  
  // Format day header with weekday and date
  String _formatDayHeader(DateTime date) {
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    
    final weekday = _getWeekdayName(date.weekday);
    final dateStr = '${date.day}/${date.month}/${date.year}';
    
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Hoy - $dateStr';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Mañana - $dateStr';
    } else {
      return '$weekday - $dateStr';
    }
  }
  
  // Get weekday name in Spanish
  String _getWeekdayName(int weekday) {
    const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return weekdays[weekday - 1];
  }
}
