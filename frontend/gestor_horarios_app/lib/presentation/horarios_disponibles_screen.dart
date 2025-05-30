import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/data/models/horario.dart';
import 'package:gestor_horarios_app/data/repositories/horario_repository.dart';
import 'package:provider/provider.dart';

class HorariosDisponiblesScreen extends StatefulWidget {
  final DateTime selectedDate;

  const HorariosDisponiblesScreen({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _HorariosDisponiblesScreenState createState() =>
      _HorariosDisponiblesScreenState();
}

class _HorariosDisponiblesScreenState extends State<HorariosDisponiblesScreen> {
  bool _isLoading = true;
  List<Horario> _horarios = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHorariosDisponibles();
  }

  Future<void> _loadHorariosDisponibles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final horarioRepository =
          Provider.of<HorarioRepository>(context, listen: false);
      final horarios = await horarioRepository.getHorariosDisponibles(
        fecha: widget.selectedDate,
      );

      setState(() {
        _horarios = horarios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los horarios: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios Disponibles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _horarios.isEmpty
                  ? const Center(
                      child: Text('No hay horarios disponibles para esta fecha'),
                    )
                  : ListView.builder(
                      itemCount: _horarios.length,
                      itemBuilder: (context, index) {
                        final horario = _horarios[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              '${horario.tipoJornada.displayName}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Hora: ${horario.horaInicio} - ${horario.horaFin}'),
                                if (horario.usuario != null)
                                  Text(
                                      'Asignado a: ${horario.usuario!.nombre} ${horario.usuario!.apellidos}'),
                                if (horario.notas != null &&
                                    horario.notas!.isNotEmpty)
                                  Text('Notas: ${horario.notas}'),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Aquí puedes agregar la lógica para solicitar el horario
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
