import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_horarios_app/data/providers/vehicle_provider.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';
import 'package:gestor_horarios_app/screens/vehicles/add_edit_vehicle_screen.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';

// Ensure AddEditVehicleScreen is imported correctly and supports editing

class VehicleListScreen extends StatefulWidget {
  static const routeName = '/vehicles';

  const VehicleListScreen({Key? key}) : super(key: key);

  @override
  _VehicleListScreenState createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  bool _isLoading = false;
  bool _showMyVehicles = false;
  bool _isJoining = false;
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  // Mostrar mensaje de error
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Mostrar mensaje de éxito
  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _loadInitialData() async {
    if (!mounted || _isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<VehicleProvider>(context, listen: false);
    
    try {
      // Cargar primero los vehículos del usuario y luego los disponibles
      await provider.loadMyVehicles();
      await provider.loadVehicles();
      
      if (mounted) {
        // Verificar si el usuario tiene un vehículo después de cargar
        final hasVehicles = provider.myVehicles.isNotEmpty;
        setState(() {
          // Mostrar la lista de vehículos del usuario si tiene alguno
          _showMyVehicles = hasVehicles;
        });
      }
    } catch (e) {
      debugPrint('Error en _loadInitialData: $e');
      if (mounted) {
        _showError('Error al cargar los vehículos. Por favor, inténtalo de nuevo.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadVehicles() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<VehicleProvider>(context, listen: false);
      await provider.loadVehicles();
    } catch (e) {
      debugPrint('Error en _loadVehicles: $e');
      if (mounted) {
        _showError('No se pudieron cargar los vehículos disponibles');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _unirseAVehiculo(int vehicleId) async {
    if (_isJoining) return;
    
    try {
      setState(() {
        _isJoining = true;
      });

      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
      // Get the full vehicle object from the provider
      final vehicle = vehicleProvider.vehicles.firstWhere(
        (v) => v.id == vehicleId,
        orElse: () => vehicleProvider.myVehicles.firstWhere(
          (v) => v.id == vehicleId,
          orElse: () => throw Exception('Vehículo no encontrado'),
        ),
      );

      final success = await vehicleProvider.joinVehicleAsPassenger(vehicle);

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Te has unido al vehículo')),
        );
        // Refresh the vehicle lists
        await _loadInitialData();
      } else if (!success) {
        throw Exception('No se pudo unir al vehículo. Inténtalo de nuevo.');
      }
    } catch (e) {
      debugPrint('Error al unirse al vehículo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al unirse al vehículo: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  // Salir de un vehículo
  Future<void> _salirDeVehiculo(int vehicleId) async {
    if (_isLeaving) return;
    
    try {
      setState(() {
        _isLeaving = true;
      });

      final provider = Provider.of<VehicleProvider>(context, listen: false);
      // Get the full vehicle object from the provider
      final vehicle = provider.vehicles.firstWhere(
        (v) => v.id == vehicleId,
        orElse: () => provider.myVehicles.firstWhere(
          (v) => v.id == vehicleId,
          orElse: () => throw Exception('Vehículo no encontrado'),
        ),
      );

      final success = await provider.leaveVehicleAsPassenger(vehicle);
      
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Has salido del vehículo')),
        );
        // Refresh the vehicle lists
        await _loadInitialData();
      } else if (!success) {
        throw Exception('No se pudo salir del vehículo. Inténtalo de nuevo.');
      }
    } catch (e) {
      debugPrint('Error al salir del vehículo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al salir del vehículo: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLeaving = false;
        });
      }
    }
  }

  // Verificar si el usuario actual está en un vehículo específico
  bool _estaUsuarioEnVehiculo(Vehiculo vehiculo) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (currentUser == null) return false;
    
    // Verificar si el usuario es el propietario o un pasajero
    return vehiculo.propietarioId == currentUser.id || 
           (vehiculo.pasajeros?.any((p) => p.id == currentUser.id) ?? false);
  }

  // Verificar si el vehículo tiene asientos disponibles
  bool _tieneAsientosDisponibles(Vehiculo vehiculo) {
    return (vehiculo.asientosDisponibles ?? 0) > 0;
  }

  // Verificar si el usuario es el propietario del vehículo
  bool _esPropietario(Vehiculo vehiculo) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    return currentUser != null && vehiculo.propietarioId == currentUser.id;
  }

  // Build the vehicle list widget
  Widget _buildVehicleList(List<Vehiculo> vehicles) {
    if (vehicles.isEmpty) {
      return const Center(
        child: Text('No hay vehículos disponibles'),
      );
    }

    return ListView.builder(
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        final isUserInVehicle = _estaUsuarioEnVehiculo(vehicle);
        final hasAvailableSeats = _tieneAsientosDisponibles(vehicle);
        final isOwner = _esPropietario(vehicle);
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text('${vehicle.marca} ${vehicle.modelo}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Matrícula: ${vehicle.matricula}'),
                Text('Asientos: ${vehicle.asientosDisponibles} disponibles de ${vehicle.totalSeats}'),
                if (vehicle.propietario != null) 
                  Text('Propietario: ${vehicle.propietario!.nombre} ${vehicle.propietario!.apellidos}'),
                if (vehicle.pasajeros != null && vehicle.pasajeros!.isNotEmpty)
                  Text('Pasajeros: ${vehicle.pasajeros!.length}'),
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUserInVehicle && !isOwner)
                  IconButton(
                    icon: _isLeaving 
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.exit_to_app, color: Colors.red),
                    onPressed: _isLeaving || vehicle.id == null
                        ? null 
                        : () => _salirDeVehiculo(vehicle.id!),
                    tooltip: 'Salir del vehículo',
                  )
                else if (!isUserInVehicle && hasAvailableSeats && !isOwner)
                  IconButton(
                    icon: _isJoining 
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.directions_car, color: Colors.green),
                    onPressed: _isJoining || vehicle.id == null
                        ? null 
                        : () => _unirseAVehiculo(vehicle.id!),
                    tooltip: 'Unirse al vehículo',
                  ),
                if (isOwner)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteVehicle(vehicle),
                    tooltip: 'Eliminar vehículo',
                  ),
              ],
            ),
            onTap: () {
              // Mostrar detalles del vehículo
              _showVehicleDetails(vehicle);
            },
          ),
        );
      },
    );
  }

  // Mostrar detalles del vehículo
  void _showVehicleDetails(Vehiculo vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${vehicle.marca} ${vehicle.modelo}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Matrícula: ${vehicle.matricula}'),
              if (vehicle.color != null) Text('Color: ${vehicle.color}'),
              Text('Asientos: ${vehicle.asientosDisponibles} disponibles de ${vehicle.totalSeats}'),
              const SizedBox(height: 8),
              const Text('Propietario:', style: TextStyle(fontWeight: FontWeight.bold)),
              if (vehicle.propietario != null) 
                Text('${vehicle.propietario!.nombre} ${vehicle.propietario!.apellidos}'),
              if (vehicle.pasajeros != null && vehicle.pasajeros!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Pasajeros:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...vehicle.pasajeros!.map((p) => Text('• ${p.nombre} ${p.apellidos}')).toList(),
              ],
              if (vehicle.observaciones != null && vehicle.observaciones!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(vehicle.observaciones!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Eliminar vehículo
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
    
    // Mostrar indicador de carga
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
        _showSuccess('Vehículo eliminado correctamente');
        await _loadInitialData();
      } else {
        throw Exception(provider.error ?? 'Error desconocido al eliminar el vehículo');
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showError('Error al eliminar el vehículo: $e');
    }
  }

  Widget _buildVehicleCard(Vehiculo vehiculo) {
    final bool esMiVehiculo = _estaUsuarioEnVehiculo(vehiculo);
    final bool tieneCupo = vehiculo.asientosDisponibles != null && vehiculo.asientosDisponibles! > 0;
    final bool puedeUnirse = !esMiVehiculo && tieneCupo;
    final bool isLoading = _isJoining || _isLeaving;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${vehiculo.marca} ${vehiculo.modelo}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Text('Matrícula: ${vehiculo.matricula}'),
            if (vehiculo.color != null) Text('Color: ${vehiculo.color}'),
            if (vehiculo.asientosDisponibles != null)
              Text('Asientos disponibles: ${vehiculo.asientosDisponibles}'),
            if (vehiculo.observaciones != null && vehiculo.observaciones!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Observaciones: ${vehiculo.observaciones}'),
              ),
            const SizedBox(height: 16.0),
            if (isLoading && (esMiVehiculo || puedeUnirse))
              const Center(child: CircularProgressIndicator())
            else if (esMiVehiculo)
              ElevatedButton(
                onPressed: () => _salirDeVehiculo(vehiculo.id!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salir del vehículo'),
              )
            else if (puedeUnirse)
              ElevatedButton(
                onPressed: () => _unirseAVehiculo(vehiculo.id!),
                child: const Text('Unirse al vehículo'),
              )
            else if (!tieneCupo)
              const Text(
                'No hay asientos disponibles',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  // Add a new vehicle
  Future<void> _addNewVehicle() async {
    if (_isLoading) return;
    
    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const AddEditVehicleScreen(),
        ),
      );
      
      // If the result is true, it means a vehicle was successfully added
      if (result == true) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehículo creado correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Refresh both vehicle lists
          await _loadInitialData();
          
          // Switch to show my vehicles
          if (mounted) {
            setState(() {
              _showMyVehicles = true;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el vehículo: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
        title: const Text('Vehículos Disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewVehicle,
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

                return RefreshIndicator(
                  onRefresh: _showMyVehicles
                      ? _loadMyVehicles
                      : _loadVehicles,
                  child: _buildVehicleList(vehicles),
                );
              },
            ),
    );
  }

  Future<void> _loadMyVehicles() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<VehicleProvider>(context, listen: false);
      await provider.loadMyVehicles();
      
      // Verificar si el usuario tiene vehículos después de cargar
      if (mounted && provider.myVehicles.isEmpty) {
        // Si no tiene vehículos, mostrar la lista de vehículos disponibles
        setState(() {
          _showMyVehicles = false;
        });
      }
    } catch (e) {
      debugPrint('Error en _loadMyVehicles: $e');
      if (mounted) {
        _showError('No se pudieron cargar tus vehículos');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
