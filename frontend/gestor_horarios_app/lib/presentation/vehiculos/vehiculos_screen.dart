import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';
import 'package:gestor_horarios_app/data/repositories/vehiculo_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simple Usuario model for the current user
class Usuario {
  final int? id;
  final String? nombre;
  final String? apellidos;
  final String? email;

  Usuario({
    this.id,
    this.nombre,
    this.apellidos,
    this.email,
  });

  factory Usuario.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Usuario(
      id: json['id'] as int?,
      nombre: json['nombre'] as String?,
      apellidos: json['apellidos'] as String?,
      email: json['email'] as String?,
    );
  }
}

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({Key? key}) : super(key: key);

  @override
  VehiculosScreenState createState() => VehiculosScreenState();
}

class VehiculosScreenState extends State<VehiculosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // State variables
  late Future<List<Vehiculo>> _vehiculosFuture;
  late Future<List<Vehiculo>> _availableVehiclesFuture;
  Usuario? _currentUser;
  bool _isLoading = false;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _matriculaController = TextEditingController();
  final _colorController = TextEditingController();
  final _plazasController = TextEditingController();
  final _observacionesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVehiculos();
    _loadAvailableVehicles();
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _matriculaController.dispose();
    _colorController.dispose();
    _plazasController.dispose();
    _observacionesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Helper methods for state management
  void _setLoading(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  void _setSaving(bool saving) {
    if (mounted) {
      setState(() => _isSaving = saving);
    }
  }

  // Show error message
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show success message
  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Clear form fields
  void _limpiarFormulario() {
    _marcaController.clear();
    _modeloController.clear();
    _matriculaController.clear();
    _colorController.clear();
    _plazasController.clear();
    _observacionesController.clear();
  }

  // Load user's vehicles
  Future<void> _loadVehiculos() async {
    if (!mounted) return;
    _setLoading(true);

    try {
      final repository = Provider.of<VehiculoRepository>(context, listen: false);
      _vehiculosFuture = repository.obtenerVehiculos();
      await _vehiculosFuture;
      
      // Load current user data
      await _loadCurrentUser();
    } catch (e) {
      if (!mounted) return;
      _showError('Error cargando vehículos: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load available vehicles from other users
  Future<void> _loadAvailableVehicles() async {
    if (!mounted) return;
    _setLoading(true);

    try {
      final repository = Provider.of<VehiculoRepository>(context, listen: false);
      _availableVehiclesFuture = repository.obtenerVehiculosDisponibles();
      await _availableVehiclesFuture;
    } catch (e) {
      if (!mounted) return;
      _showError('Error cargando vehículos disponibles: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load current user data from shared preferences
  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        setState(() {
          _currentUser = Usuario.fromJson(userJson);
        });
      }
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  // Join a vehicle
  Future<void> _unirseAVehiculo(Vehiculo vehiculo) async {
    if (_isLoading) return;
    
    _setLoading(true);

    try {
      final repository = Provider.of<VehiculoRepository>(context, listen: false);
      await repository.unirseAVehiculo(vehiculo.id!);

      if (!mounted) return;

      _showSuccess('¡Te has unido al vehículo correctamente!');
      
      // Recargar la lista de vehículos disponibles y los del usuario
      await Future.wait([
        _loadAvailableVehicles(),
        _loadVehiculos(),
      ]);
      
      // Actualizar la interfaz de usuario
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al unirse al vehículo: ${e.toString().replaceAll('Exception: ', '')}');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Leave a vehicle
  Future<void> _salirDeVehiculo(Vehiculo vehiculo) async {
    _setLoading(true);

    try {
      final repository = Provider.of<VehiculoRepository>(context, listen: false);
      final success = await repository.salirDeVehiculo(vehiculo.id!);

      if (!mounted) return;

      if (success) {
        _showSuccess('Has salido del vehículo correctamente');
        await _loadAvailableVehicles();
      } else {
        _showError('No se pudo salir del vehículo');
      }
    } catch (e) {
      _showError('Error al salir del vehículo: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle vehicle active status
  Future<void> _cambiarEstadoActivo(Vehiculo vehiculo, bool nuevoEstado) async {
    _setLoading(true);

    try {
      final repository = Provider.of<VehiculoRepository>(context, listen: false);
      final success = await repository.cambiarEstadoActivo(vehiculo.id!, nuevoEstado);

      if (!mounted) return;

      if (success) {
        _showSuccess('Vehículo ${nuevoEstado ? 'activado' : 'desactivado'} correctamente');
        await _loadVehiculos();
      } else {
        _showError('Error al cambiar el estado del vehículo');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Build delete confirmation dialog
  Widget _buildDeleteConfirmationDialog(Vehiculo vehiculo) {
    return AlertDialog(
      title: const Text('Confirmar eliminación'),
      content: Text('¿Estás seguro de que deseas eliminar el vehículo ${vehiculo.marca} ${vehiculo.modelo}?'),
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
    );
  }

  // Delete vehicle with confirmation
  Future<void> _eliminarVehiculo(Vehiculo vehiculo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteConfirmationDialog(vehiculo),
    );

    if (confirm != true) return;
    if (!mounted) return;

    _setLoading(true);

    try {
      final repository = Provider.of<VehiculoRepository>(context, listen: false);
      final success = await repository.eliminarVehiculo(vehiculo.id!);

      if (!mounted) return;

      if (success) {
        _showSuccess('Vehículo eliminado correctamente');
        await _loadVehiculos();
      } else {
        _showError('No se pudo eliminar el vehículo');
      }
    } catch (e) {
      _showError('Error al eliminar el vehículo: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Save new vehicle
  Future<void> _guardarVehiculo() async {
    if (!_formKey.currentState!.validate()) return;
    _setSaving(true);

    try {
      final repository = Provider.of<VehiculoRepository>(context, listen: false);
      
      final totalAsientos = int.tryParse(_plazasController.text.trim()) ?? 0;
      if (totalAsientos <= 0) {
        _showError('El número de plazas debe ser mayor que cero');
        _setSaving(false);
        return;
      }

      final nuevoVehiculo = Vehiculo(
        id: 0,
        marca: _marcaController.text.trim(),
        modelo: _modeloController.text.trim(),
        matricula: _matriculaController.text.trim().toUpperCase(),
        color: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : null,
        asientosDisponibles: totalAsientos,
        totalSeats: totalAsientos, // Set both available and total seats to the same value
        observaciones: _observacionesController.text.trim().isNotEmpty 
            ? _observacionesController.text.trim() 
            : null,
        activo: true,
      );

      // Convert Vehiculo to Map before sending to repository
      final vehiculoMap = {
        'licensePlate': nuevoVehiculo.matricula,
        'brand': nuevoVehiculo.marca,
        'model': nuevoVehiculo.modelo,
        'totalSeats': nuevoVehiculo.totalSeats,
        'availableSeats': nuevoVehiculo.asientosDisponibles,
        'color': nuevoVehiculo.color,
        'observations': nuevoVehiculo.observaciones,
        'active': nuevoVehiculo.activo,
      };
      
      await repository.crearVehiculo(vehiculoMap);

      if (!mounted) return;

      Navigator.of(context).pop();
      _limpiarFormulario();
      _showSuccess('Vehículo agregado correctamente');
      await _loadVehiculos();
    } catch (e) {
      _showError('Error al guardar el vehículo: ${e.toString()}');
    } finally {
      _setSaving(false);
    }
  }

  // Build vehicle list item
  Widget _buildVehiculoItem(Vehiculo vehiculo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('${vehiculo.marca} ${vehiculo.modelo}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Matrícula: ${vehiculo.matricula}'),
            if (vehiculo.color != null) Text('Color: ${vehiculo.color}'),
            Text('Plazas: ${vehiculo.asientosDisponibles}'),
            if (vehiculo.observaciones != null) Text('Obs: ${vehiculo.observaciones}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: vehiculo.activo,
              onChanged: (value) => _cambiarEstadoActivo(vehiculo, value),
            ),
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: Text('Editar'),
                ),
                const PopupMenuItem(
                  value: 'eliminar',
                  child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                ),
              ],
              onSelected: (value) {
                if (value == 'eliminar') {
                  _eliminarVehiculo(vehiculo);
                } else if (value == 'editar') {
                  // TODO: Implementar edición
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show add vehicle dialog
  Future<void> _showAgregarVehiculoDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Vehículo'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _marcaController,
                  decoration: const InputDecoration(labelText: 'Marca'),
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _modeloController,
                  decoration: const InputDecoration(labelText: 'Modelo'),
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _matriculaController,
                  decoration: const InputDecoration(labelText: 'Matrícula'),
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Color (opcional)'),
                ),
                TextFormField(
                  controller: _plazasController,
                  decoration: const InputDecoration(labelText: 'Plazas'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Campo requerido';
                    if (int.tryParse(value!) == null) return 'Ingrese un número válido';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _observacionesController,
                  decoration: const InputDecoration(labelText: 'Observaciones (opcional)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _guardarVehiculo,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Build available vehicle list item
  Widget _buildAvailableVehicleItem(Vehiculo vehiculo) {
    final bool isUserInVehicle = _currentUser?.id != null && 
                               vehiculo.pasajeros?.any((p) => p.id == _currentUser?.id) == true;
    final int availableSeats = vehiculo.asientosDisponibles ?? 0;
    final bool hasAvailableSeats = availableSeats > 0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('${vehiculo.marca} ${vehiculo.modelo}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conductor: ${vehiculo.propietario?.nombre ?? 'Desconocido'}'),
            Text('Plazas disponibles: $availableSeats'),
            if (vehiculo.color != null) Text('Color: ${vehiculo.color}'),
          ],
        ),
        trailing: isUserInVehicle
            ? ElevatedButton.icon(
                onPressed: () => _salirDeVehiculo(vehiculo),
                icon: const Icon(Icons.exit_to_app, size: 16),
                label: const Text('Salir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              )
            : ElevatedButton.icon(
                onPressed: ((vehiculo.asientosDisponibles ?? 0) > 0) ? () => _unirseAVehiculo(vehiculo) : null,
                icon: const Icon(Icons.directions_car, size: 16),
                label: Text(hasAvailableSeats ? 'Unirse' : 'Sin plazas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasAvailableSeats ? Theme.of(context).primaryColor : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
      ),
    );
  }

  // Build loading indicator
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // Build error message
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  // Build empty state
  Widget _buildEmptyState(String message, {VoidCallback? onPressed}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          if (onPressed != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              child: const Text('Agregar vehículo'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vehículos'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.directions_car), text: 'Mis vehículos'),
              Tab(icon: Icon(Icons.group), text: 'Unirse a vehículo'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : () {
                _loadVehiculos();
                _loadAvailableVehicles();
              },
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // My vehicles tab
            _isLoading
                ? _buildLoadingIndicator()
                : FutureBuilder<List<Vehiculo>>(
                    future: _vehiculosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _buildErrorWidget('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData) {
                        return _buildLoadingIndicator();
                      }

                      final vehiculos = snapshot.data!;

                      if (vehiculos.isEmpty) {
                        return _buildEmptyState(
                          'No tienes vehículos registrados',
                          onPressed: _showAgregarVehiculoDialog,
                        );
                      }

                      return ListView.builder(
                        itemCount: vehiculos.length,
                        itemBuilder: (context, index) {
                          return _buildVehiculoItem(vehiculos[index]);
                        },
                      );
                    },
                  ),

            // Available vehicles tab
            _isLoading
                ? _buildLoadingIndicator()
                : FutureBuilder<List<Vehiculo>>(
                    future: _availableVehiclesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _buildErrorWidget('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData) {
                        return _buildLoadingIndicator();
                      }

                      final vehiculos = snapshot.data!;

                      if (vehiculos.isEmpty) {
                        return _buildEmptyState(
                          'No hay vehículos disponibles para unirse',
                        );
                      }

                      return ListView.builder(
                        itemCount: vehiculos.length,
                        itemBuilder: (context, index) {
                          return _buildAvailableVehicleItem(vehiculos[index]);
                        },
                      );
                    },
                  ),
          ],
        ),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton(
                onPressed: _showAgregarVehiculoDialog,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
