import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_horarios_app/data/providers/vehicle_provider.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';
import 'package:gestor_horarios_app/screens/vehicles/add_edit_vehicle_screen.dart';
import 'package:gestor_horarios_app/screens/vehicles/vehicle_detail_screen.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';

class VehicleListScreen extends StatefulWidget {
  static const routeName = '/vehicles';

  const VehicleListScreen({Key? key}) : super(key: key);

  @override
  _VehicleListScreenState createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  bool _isLoading = false;
  bool _showMyVehicles = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<VehicleProvider>(context, listen: false);
    await provider.loadVehicles();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteVehicle(Vehiculo vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar vehículo'),
        content: const Text('¿Estás seguro de que deseas eliminar este vehículo?'),
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
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)),
            SizedBox(width: 16),
            Text('Eliminando vehículo...'),
          ],
        ),
        duration: Duration(seconds: 5),
      ),
    );

    try {
      final provider = Provider.of<VehicleProvider>(context, listen: false);
      final success = await provider.deleteVehicle(vehicle.id!);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Vehículo eliminado correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          )
        );
      } else {
        throw Exception(provider.error ?? 'Error desconocido al eliminar el vehículo');
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al eliminar el vehículo: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: () => _deleteVehicle(vehicle),
          ),
        ),
      );
    }
  }

  Widget _buildVehicleItem(Vehiculo vehicle) {
    // Get the current user ID from the auth provider
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    
    // Check if the vehicle belongs to the current user
    final isMyVehicle = vehicle.propietarioId == currentUser?.id;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => VehicleDetailScreen(vehicle: vehicle),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${vehicle.marca} ${vehicle.modelo}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  // Show delete button if viewing my vehicles and it's my vehicle
                  if (isMyVehicle)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteVehicle(vehicle),
                      tooltip: 'Eliminar vehículo',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Matrícula: ${vehicle.matricula}'),
              if (vehicle.color != null) Text('Color: ${vehicle.color}'),
              Text(
                'Asientos disponibles: ${vehicle.asientosDisponibles ?? 0}',
                style: TextStyle(
                  color: (vehicle.asientosDisponibles ?? 0) > 0
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos Disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AddEditVehicleScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(_showMyVehicles ? Icons.directions_car : Icons.person),
            onPressed: () {
              setState(() {
                _showMyVehicles = !_showMyVehicles;
                if (_showMyVehicles) {
                  _loadMyVehicles();
                } else {
                  _loadVehicles();
                }
              });
            },
            tooltip: _showMyVehicles
                ? 'Mostrar todos los vehículos'
                : 'Mostrar mis vehículos',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<VehicleProvider>(
              builder: (ctx, provider, _) {
                final vehicles = _showMyVehicles
                    ? provider.myVehicles
                    : provider.vehicles;

                if (vehicles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showMyVehicles
                              ? 'No has publicado ningún vehículo'
                              : 'No hay vehículos disponibles',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (!_showMyVehicles)
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) =>
                                      const AddEditVehicleScreen(),
                                ),
                              );
                            },
                            child: const Text('Publicar un vehículo'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _showMyVehicles
                      ? _loadMyVehicles
                      : _loadVehicles,
                  child: ListView.builder(
                    itemCount: vehicles.length,
                    itemBuilder: (ctx, i) => _buildVehicleItem(vehicles[i]),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _loadMyVehicles() async {
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<VehicleProvider>(context, listen: false);
    await provider.loadMyVehicles();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
