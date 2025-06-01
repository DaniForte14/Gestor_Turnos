import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';
import 'package:gestor_horarios_app/data/repositories/vehiculo_repository.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({Key? key}) : super(key: key);

  @override
  VehiculosScreenState createState() => VehiculosScreenState();
}

class VehiculosScreenState extends State<VehiculosScreen> {
  // State variables
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isJoining = false;
  bool _isLeaving = false;
  Vehiculo? _miVehiculoCreado; // Vehículo creado por el usuario actual
  List<Vehiculo> _vehiculosDisponibles = [];
  final Map<int, int> _plazasOriginales = {};
  final Map<int, bool> _usuarioEnVehiculo = {};

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
    _loadVehiculos();
  }



  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _matriculaController.dispose();
    _colorController.dispose();
    _plazasController.dispose();
    _observacionesController.dispose();
    _plazasOriginales.clear();
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

  // Show confirmation dialog for vehicle deletion
  Future<bool?> _mostrarDialogoConfirmacionEliminar(Vehiculo vehiculo) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar el vehículo ${vehiculo.marca} ${vehiculo.modelo}?'),
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
  }

  // Delete vehicle with confirmation
  Future<void> _eliminarVehiculo(Vehiculo vehiculo) async {
    final confirm = await _mostrarDialogoConfirmacionEliminar(vehiculo);
    if (confirm != true) return;

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
      
      final asientosDisponibles = int.tryParse(_plazasController.text.trim()) ?? 0;
      if (asientosDisponibles <= 0) {
        _showError('El número de plazas debe ser mayor que cero');
        return;
      }
      
      final nuevoVehiculo = Vehiculo(
        id: 0,
        marca: _marcaController.text.trim(),
        modelo: _modeloController.text.trim(),
        matricula: _matriculaController.text.trim().toUpperCase(),
        color: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : null,
        asientosDisponibles: asientosDisponibles,
        observaciones: _observacionesController.text.trim().isNotEmpty 
            ? _observacionesController.text.trim() 
            : null,
        activo: true,
      );

      try {
        final response = await repository.crearVehiculo(nuevoVehiculo.toJson());
        final vehiculoCreado = Vehiculo.fromJson(response);

        if (!mounted) return;

        if (vehiculoCreado != null) {
          setState(() {
            _miVehiculoCreado = vehiculoCreado;
            _vehiculosDisponibles = [];
          });
          if (mounted) {
            Navigator.of(context).pop();
            _limpiarFormulario();
            _showSuccess('Vehículo agregado correctamente');
          }
        } else {
          _showError('No se pudo guardar el vehículo');
        }
      } catch (e) {
        if (mounted) {
          _showError('Error al conectar con el servidor: $e');
        }
      }
    } catch (e) {
      _showError('Error al guardar el vehículo: ${e.toString()}');
    } finally {
      _setSaving(false);
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

  // Clear the vehicle form
  void _limpiarFormulario() {
    _marcaController.clear();
    _modeloController.clear();
    _matriculaController.clear();
    _colorController.clear();
    _plazasController.clear();
    _observacionesController.clear();
  }

  // Unirse a un vehículo
  Future<void> _unirseAVehiculo(Vehiculo vehiculo) async {
    if (_isJoining || _isLeaving) return;
    
    setState(() => _isJoining = true);
    
    try {
      final repository = Provider.of<VehiculoRepository>(context, listen: false);
      final success = await repository.unirseAVehiculo(vehiculo.id!);
      
      if (!mounted) return;
      
      if (success) {
        _showSuccess('¡Te has unido al vehículo exitosamente!');
        await _loadVehiculos();
      } else {
        _showError('No se pudo unir al vehículo. Inténtalo de nuevo.');
      }
    } catch (e) {
      _showError('Error al unirse al vehículo: $e');
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }
  
  // Salir de un vehículo
  Future<void> _salirDeVehiculo(Vehiculo vehiculo) async {
    if (_isJoining || _isLeaving) return;
    
    setState(() => _isLeaving = true);
    
    try {
      final repository = Provider.of<VehiculoRepository>(context, listen: false);
      final success = await repository.salirDeVehiculo(vehiculo.id!);
      
      if (!mounted) return;
      
      if (success) {
        _showSuccess('Has salido del vehículo exitosamente');
        await _loadVehiculos();
      } else {
        _showError('No se pudo salir del vehículo. Inténtalo de nuevo.');
      }
    } catch (e) {
      _showError('Error al salir del vehículo: $e');
    } finally {
      if (mounted) {
        setState(() => _isLeaving = false);
      }
    }
  }
  
  // Check if user is in any vehicle
  Future<void> _verificarEstadoUsuarioEnVehiculos() async {
    if (_vehiculosDisponibles.isEmpty) return;
    
    try {
      final repository = Provider.of<VehiculoRepository>(context, listen: false);
      
      for (var vehiculo in _vehiculosDisponibles) {
        if (vehiculo.id != null) {
          final estaDentro = await repository.estaVehiculo(vehiculo.id!);
          if (mounted) {
            setState(() {
              _usuarioEnVehiculo[vehiculo.id!] = estaDentro;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al verificar estado del usuario en vehículos: ${e.toString()}');
      }
    }
  }

  // Load vehicles from repository
  Future<void> _loadVehiculos() async {
    if (!mounted) return;
    _setLoading(true);

    try {
      final repository = Provider.of<VehiculoRepository>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Get current user from auth provider
      final currentUser = authProvider.currentUser;
      if (currentUser == null) {
        if (mounted) {
          _showError('Usuario no autenticado');
        }
        return;
      }

      // Load all vehicles
      final allVehiculosData = await repository.obtenerVehiculos();
      if (!mounted) return;

      // Convert to Vehiculo objects
      final allVehiculos = allVehiculosData.map((v) => Vehiculo.fromJson(v)).toList();
      
      // Find if current user has a vehicle
      // First check if any vehicle has the current user as owner
      Vehiculo? userVehiculo;
      try {
        userVehiculo = allVehiculos.firstWhere(
          (v) => v.propietarioId == currentUser.id,
        );
      } catch (e) {
        // No vehicle found for this user
        userVehiculo = null;
      }

      setState(() {
        _miVehiculoCreado = userVehiculo;
        _vehiculosDisponibles = userVehiculo != null ? [] : allVehiculos;
      });

      // Verify user status in vehicles if there are available vehicles
      if (_vehiculosDisponibles.isNotEmpty) {
        await _verificarEstadoUsuarioEnVehiculos();
      }
    } catch (e) {
      if (mounted) {
        _showError('Error cargando vehículos: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  // Delete user's vehicle
  Future<void> _eliminarMiVehiculo() async {
    if (_miVehiculoCreado == null) return;
    
    final confirm = await _mostrarDialogoConfirmacionEliminar(_miVehiculoCreado!);
    if (confirm != true) return;
    
    _setLoading(true);
    try {
      final repository = Provider.of<VehiculoRepository>(context, listen: false);
      final success = await repository.eliminarVehiculo(_miVehiculoCreado!.id!);

      if (!mounted) return;

      if (success) {
        _showSuccess('Vehículo eliminado correctamente');
        setState(() {
          _miVehiculoCreado = null;
        });
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

  // Build info row helper method
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Build user's vehicle view
  Widget _buildMiVehiculoView() {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    
    if (currentUser == null) {
      return const Center(child: Text('No has iniciado sesión'));
    }
    
    if (_miVehiculoCreado == null) {
      return const Center(child: Text('No tienes ningún vehículo registrado'));
    }
    
    final isOwner = _miVehiculoCreado!.isOwner(currentUser.id);
        
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mi Vehículo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Marca', _miVehiculoCreado!.marca),
            _buildInfoRow('Modelo', _miVehiculoCreado!.modelo),
            _buildInfoRow('Matrícula', _miVehiculoCreado!.matricula),
            if (_miVehiculoCreado!.color != null)
              _buildInfoRow('Color', _miVehiculoCreado!.color!),
            _buildInfoRow('Plazas disponibles', _miVehiculoCreado!.asientosDisponibles.toString()),
            if (_miVehiculoCreado!.observaciones != null && _miVehiculoCreado!.observaciones!.isNotEmpty)
              _buildInfoRow('Observaciones', _miVehiculoCreado!.observaciones!),
            const SizedBox(height: 16),
            if (isOwner)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Lógica para editar vehículo
                    },
                    child: const Text('Editar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _eliminarMiVehiculo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Build vehicle item
  Widget _buildVehiculoItem(Vehiculo vehiculo) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final isOwner = vehiculo.isOwner(currentUser?.id);
    final estaEnEsteVehiculo = _usuarioEnVehiculo[vehiculo.id] ?? false;
    final plazasDisponibles = vehiculo.asientosDisponibles ?? 0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('${vehiculo.marca} ${vehiculo.modelo}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Matrícula: ${vehiculo.matricula}'),
            if (vehiculo.color != null) Text('Color: ${vehiculo.color}'),
            Text('Plazas disponibles: ${plazasDisponibles}'),
            if (vehiculo.propietarioNombre != null) 
              Text('Propietario: ${vehiculo.propietarioNombre}'),
          ],
        ),
        trailing: isOwner
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _eliminarVehiculo(vehiculo),
              )
            : _isJoining || _isLeaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: plazasDisponibles <= 0 && !estaEnEsteVehiculo
                        ? null
                        : () => estaEnEsteVehiculo
                            ? _salirDeVehiculo(vehiculo)
                            : _unirseAVehiculo(vehiculo),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: estaEnEsteVehiculo ? Colors.orange : Theme.of(context).primaryColor,
                    ),
                    child: Text(estaEnEsteVehiculo ? 'Salir' : 'Unirse'),
                  ),
      ),
    );
  }

  // Build list of available vehicles
  Widget _buildListaVehiculos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'Vehículos disponibles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (_vehiculosDisponibles.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No hay vehículos disponibles')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _vehiculosDisponibles.length,
            itemBuilder: (context, index) {
              return _buildVehiculoItem(_vehiculosDisponibles[index]);
            },
          ),
      ],
    );
  }

  // Show add vehicle dialog
  void _showAgregarVehiculoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar vehículo'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _marcaController,
                  decoration: const InputDecoration(labelText: 'Marca'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'La marca es obligatoria' : null,
                ),
                TextFormField(
                  controller: _modeloController,
                  decoration: const InputDecoration(labelText: 'Modelo'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'El modelo es obligatorio' : null,
                ),
                TextFormField(
                  controller: _matriculaController,
                  decoration: const InputDecoration(labelText: 'Matrícula'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'La matrícula es obligatoria' : null,
                ),
                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Color (opcional)'),
                ),
                TextFormField(
                  controller: _plazasController,
                  decoration: const InputDecoration(labelText: 'Plazas disponibles'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'El número de plazas es obligatorio';
                    }
                    final plazas = int.tryParse(value!);
                    if (plazas == null || plazas <= 0) {
                      return 'Debe ser un número mayor que cero';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _observacionesController,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones (opcional)',
                  ),
                  maxLines: 3,
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
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Vehículos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _miVehiculoCreado != null
              ? _buildMiVehiculoView()
              : _buildListaVehiculos(),
      floatingActionButton: _miVehiculoCreado == null
          ? FloatingActionButton(
              onPressed: _showAgregarVehiculoDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
