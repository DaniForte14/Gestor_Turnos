import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_horarios_app/data/providers/vehicle_provider.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';
import 'package:gestor_horarios_app/screens/vehicles/add_edit_vehicle_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehiculo? vehicle;

  const VehicleDetailScreen({Key? key, this.vehicle}) : super(key: key);

  @override
  _VehicleDetailScreenState createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  bool _isLoading = false;
  late Vehiculo? _vehicle;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
  }

  Future<void> _reserveSeat() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    if (_vehicle?.id == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: ID de vehículo no válido'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final success = await Provider.of<VehicleProvider>(
        context,
        listen: false,
      ).reserveSeat(_vehicle!.id!);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success && _vehicle != null) {
        // Update the local vehicle data using copyWith
        if (_vehicle != null) {
          setState(() {
            _vehicle = _vehicle!.copyWith(
              asientosDisponibles: (_vehicle!.asientosDisponibles ?? 0) - 1,
            );
          });
        }
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Asiento reservado con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<VehicleProvider>(context, listen: false).error ??
                  'Error al reservar el asiento',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteVehicle() async {
    if (_vehicle?.id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID de vehículo no válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool? hardDelete = false;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Eliminar vehículo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Estás seguro de que quieres eliminar este vehículo?'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: hardDelete,
                    onChanged: (value) {
                      setState(() {
                        hardDelete = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Eliminación permanente (no se podrá recuperar)',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await Provider.of<VehicleProvider>(
          context,
          listen: false,
        ).deleteVehicle(_vehicle!.id!, hardDelete: hardDelete ?? false);

        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });

        if (success) {
          if (!mounted) return;
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                hardDelete ?? false 
                  ? 'Vehículo eliminado permanentemente' 
                  : 'Vehículo eliminado correctamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Provider.of<VehicleProvider>(context, listen: false).error ??
                    'Error al eliminar el vehículo',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar el vehículo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _vehicle;
    final isOwner = vehicle != null &&
        Provider.of<VehicleProvider>(context, listen: false)
            .myVehicles
            .any((v) => v.id == vehicle.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_vehicle?.marca} ${_vehicle?.modelo}'),
        actions: [
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _isLoading
                  ? null
                  : () async {
                      final updatedVehicle = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => AddEditVehicleScreen(
                            vehicle: _vehicle,
                          ),
                        ),
                      );
                      if (updatedVehicle != null && mounted) {
                        setState(() {
                          _vehicle = updatedVehicle;
                        });
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteVehicle,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Matrícula', _vehicle?.matricula ?? ''),
                  _buildDetailRow('Marca', _vehicle?.marca ?? ''),
                  _buildDetailRow('Modelo', _vehicle?.modelo ?? ''),
                  if (_vehicle?.color != null)
                    _buildDetailRow('Color', _vehicle!.color!),
                  _buildDetailRow(
                    'Asientos disponibles',
                    _vehicle?.asientosDisponibles?.toString() ?? '0',
                    valueStyle: TextStyle(
                      color: (_vehicle?.asientosDisponibles ?? 0) > 0
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_vehicle?.observaciones != null &&
                      _vehicle!.observaciones!.isNotEmpty)
                    _buildDetailRow(
                      'Observaciones',
                      _vehicle!.observaciones!,
                    ),

                  if (!isOwner && _vehicle?.asientosDisponibles != null &&
                      _vehicle!.asientosDisponibles! > 0) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _reserveSeat,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('RESERVAR ASIENTO'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isLast = false,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: valueStyle ?? Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
