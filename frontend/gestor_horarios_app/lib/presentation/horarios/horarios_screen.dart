import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/core/theme/app_theme.dart';
import 'package:gestor_horarios_app/data/models/horario.dart';
import 'package:gestor_horarios_app/data/repositories/horario_repository.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({Key? key}) : super(key: key);

  @override
  _HorariosScreenState createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late Future<List<Horario>> _horariosFuture;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Horario> _horarios = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHorarios();
  }

  void _loadHorarios() {
    setState(() {
      _isLoading = true;
    });

    final horarioRepository = Provider.of<HorarioRepository>(context, listen: false);

    // Obtener el primer y último día del mes actual
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    _horariosFuture = horarioRepository.getHorariosPorFecha(firstDay, lastDay);

    _horariosFuture.then((horarios) {
      if (mounted) {
        setState(() {
          _horarios = horarios;
          _isLoading = false;
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando horarios: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
    _loadHorarios();
  }

  List<Horario> _getHorariosForDay(DateTime day) {
    return _horarios.where((horario) =>
        horario.fecha.year == day.year &&
        horario.fecha.month == day.month &&
        horario.fecha.day == day.day).toList();
  }

  Color _getColorForTipoJornada(TipoJornada tipo) {
    switch (tipo) {
      case TipoJornada.MANANA:
        return Colors.blue;
      case TipoJornada.TARDE:
        return Colors.orange;
      case TipoJornada.NOCHE:
        return Colors.indigo;
      case TipoJornada.COMPLETA:
        return Colors.green;
      case TipoJornada.GUARDIA:
        return Colors.red;
    }
  }

  void _showAddHorarioDialog() {
    // Aquí implementaremos la funcionalidad para añadir un nuevo horario
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Horario'),
        content: const Text('Esta funcionalidad estará disponible próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Mis Horarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddHorarioDialog,
            tooltip: 'Añadir horario',
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            onPageChanged: _onPageChanged,
            eventLoader: _getHorariosForDay,
            calendarStyle: CalendarStyle(
              markersMaxCount: 3,
              markerDecoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: const BoxDecoration(
                color: AppTheme.secondaryColor,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildHorariosList(),
          ),
        ],
      ),

    );
  }

  Widget _buildHorariosList() {
    final horariosDelDia = _getHorariosForDay(_selectedDay);

    if (horariosDelDia.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay horarios para este día',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: horariosDelDia.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final horario = horariosDelDia[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: _getColorForTipoJornada(horario.tipoJornada),
              child: Icon(
                _getTipoJornadaIcon(horario.tipoJornada),
                color: Colors.white,
              ),
            ),
            title: Text(
              horario.tipoJornada.displayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Horario: ${horario.horarioFormateado}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duración: ${horario.duracion}',
                  style: const TextStyle(fontSize: 14),
                ),
                if (horario.notas != null && horario.notas!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Notas: ${horario.notas}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Mostrar opciones para el horario
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Editar'),
                        onTap: () {
                          Navigator.pop(context);
                          // Implementar edición de horario
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.swap_horiz),
                        title: const Text('Solicitar cambio'),
                        onTap: () {
                          Navigator.pop(context);
                          // Implementar solicitud de cambio
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Navigator.pop(context);
                          // Implementar eliminación de horario
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  IconData _getTipoJornadaIcon(TipoJornada tipo) {
    switch (tipo) {
      case TipoJornada.MANANA:
        return Icons.wb_sunny;
      case TipoJornada.TARDE:
        return Icons.wb_twilight;
      case TipoJornada.NOCHE:
        return Icons.nights_stay;
      case TipoJornada.COMPLETA:
        return Icons.access_time;
      case TipoJornada.GUARDIA:
        return Icons.local_hospital;
    }
  }
}