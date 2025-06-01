import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/data/models/horario.dart';
import 'package:gestor_horarios_app/data/repositories/horario_repository.dart';
import 'package:gestor_horarios_app/data/services/horario_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HorariosDisponiblesScreen extends StatefulWidget {
  const HorariosDisponiblesScreen({Key? key}) : super(key: key);

  @override
  _HorariosDisponiblesScreenState createState() => _HorariosDisponiblesScreenState();
}

class _HorariosDisponiblesScreenState extends State<HorariosDisponiblesScreen> {
  late final HorarioService _horarioService;
  bool _isLoading = true;
  List<Horario> _horarios = [];
  DateTime _fecha = DateTime.now();
  
  // Helper method to parse time string to TimeOfDay
  TimeOfDay _parseTimeOfDay(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  void initState() {
    super.initState();
    _inicializarServicios();
  }

  Future<void> _inicializarServicios() async {
    // Get the repository from the provider
    final repository = Provider.of<HorarioRepository>(context, listen: false);
    _horarioService = HorarioService(repository);
    
    if (mounted) {
      await _cargarHorarios();
    }
  }

  Future<void> _cargarHorarios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final horarios = await _horarioService.getHorariosDisponibles(fecha: _fecha);
      setState(() {
        _horarios = horarios;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar los horarios: $e')),
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

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fechaSeleccionada != null && fechaSeleccionada != _fecha) {
      setState(() {
        _fecha = fechaSeleccionada;
      });
      _cargarHorarios();
    }
  }

  Future<void> _solicitarHorario(int horarioId) async {
    try {
      await _horarioService.solicitarHorario(horarioId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horario solicitado exitosamente')),
        );
        _cargarHorarios();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al solicitar el horario: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios Disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _seleccionarFecha(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarHorarios,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _horarios.isEmpty
              ? const Center(child: Text('No hay horarios disponibles para la fecha seleccionada'))
              : ListView.builder(
                  itemCount: _horarios.length,
                  itemBuilder: (context, index) {
                    final horario = _horarios[index];
                    Widget _buildHorarioCard(Horario horario) {
                      final horaInicio = _parseTimeOfDay(horario.horaInicio);
                      final horaFin = _parseTimeOfDay(horario.horaFin);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(
                            '${horaInicio.format(context)} - ${horaFin.format(context)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Turno: ${horario.tipoJornada.toString().split('.').last}'),
                              if (horario.roles.isNotEmpty)
                                Text(
                                  'Roles: ${horario.roles.map((r) => _formatearRol(r)).join(', ')}',
                                  style: const TextStyle(fontStyle: FontStyle.italic),
                                ),
                              if (horario.usuario != null)
                                Text('Asignado a: ${horario.usuario!.username}'),
                              if (horario.notas?.isNotEmpty ?? false)
                                Text('Notas: ${horario.notas}'),
                            ],
                          ),
                          trailing: horario.usuarioId == null
                              ? ElevatedButton(
                                  onPressed: () => _solicitarHorario(horario.id ?? 0),
                                  child: const Text('Solicitar'),
                                )
                              : const Text('Ocupado', style: TextStyle(color: Colors.grey)),
                        ),
                      );
                    }
                    return _buildHorarioCard(horario);
                  },
                ),
    );
  }
  String _formatearHora(TimeOfDay hora) {
    final now = DateTime.now();
    final fecha = DateTime(now.year, now.month, now.day, hora.hour, hora.minute);
    return DateFormat('HH:mm').format(fecha);
  }

  String _formatearTipoTurno(String tipo) {
    switch (tipo) {
      case 'MANANA':
        return 'Mañana';
      case 'TARDE':
        return 'Tarde';
      case 'NOCHE':
        return 'Noche';
      case 'COMPLETO':
        return 'Jornada Completa';
      default:
        return 'Otro';
    }
  }

  String _formatearRol(String rol) {
    switch (rol) {
      case 'ROLE_MEDICO':
        return 'Médico';
      case 'ROLE_ENFERMERO':
        return 'Enfermero/a';
      case 'ROLE_TCAE':
        return 'TCAE';
      default:
        return rol;
    }
  }
}
