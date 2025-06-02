import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:gestor_horarios_app/data/providers/vehicle_provider.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';

class AddEditVehicleScreen extends StatefulWidget {
  static const routeName = '/add-edit-vehicle';
  final Vehiculo? vehicle;

  const AddEditVehicleScreen({Key? key, this.vehicle}) : super(key: key);

  @override
  _AddEditVehicleScreenState createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Form controllers
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _matriculaController = TextEditingController();
  final _colorController = TextEditingController();
  final _asientosController = TextEditingController(text: '4'); // Default value

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      // If editing an existing vehicle, populate the form
      final vehicle = widget.vehicle!;
      _marcaController.text = vehicle.marca;
      _modeloController.text = vehicle.modelo;
      _matriculaController.text = vehicle.matricula;
      _colorController.text = vehicle.color ?? '';
      _asientosController.text = vehicle.asientosDisponibles.toString();
    }
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _matriculaController.dispose();
    _colorController.dispose();
    _asientosController.dispose();
    super.dispose();
  }

  /// Validates and saves the vehicle form
  ///
  /// Returns a [Future] that completes when the form is saved or when an error occurs.
  /// If the form is saved successfully, the screen is popped and returns `true`.
  /// If an error occurs, an error message is shown to the user.
  Future<void> _saveForm() async {
    log('💾 Iniciando proceso de guardado de vehículo');
    
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      log('❌ Validación del formulario fallida');
      return;
    }

    // Dismiss keyboard before saving
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // Get form values
      final marca = _marcaController.text.trim();
      final modelo = _modeloController.text.trim();
      final matricula = _matriculaController.text.trim().toUpperCase();
      final color = _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : null;
      final asientosDisponibles = int.tryParse(_asientosController.text) ?? 4;

      log('📋 Datos del formulario validados:');
      log('🔹 Marca: $marca');
      log('🔹 Modelo: $modelo');
      log('🔹 Matrícula: $matricula');
      log('🔹 Color: $color');
      log('🔹 Asientos disponibles: $asientosDisponibles');

      final provider = Provider.of<VehicleProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Check if user is authenticated
      if (!authProvider.isAuthenticated) {
        log('🔒 Usuario no autenticado');
        if (!mounted) return;
        _showError('Sesión expirada. Por favor, inicia sesión nuevamente.');
        // Optionally, navigate to login screen
        // Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
      
      if (widget.vehicle == null) {
        // Adding a new vehicle
        log('➕ Creando nuevo vehículo...');
        
        final success = await provider.addVehicle(
          marca: marca,
          modelo: modelo,
          matricula: matricula,
          color: color,
          asientosDisponibles: asientosDisponibles,
          observaciones: null,
        );
        
        if (!mounted) return;
        
        if (success) {
          log('✅ Vehículo creado exitosamente');
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vehículo añadido correctamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            
            // Pop the screen and return true to indicate success
            Navigator.of(context).pop(true);
          }
        } else {
          // Handle specific error messages from the provider
          final errorMessage = provider.error ?? 'Error desconocido al guardar el vehículo';
          log('❌ Error al guardar el vehículo: $errorMessage');
          
          if (mounted) {
            _showError(errorMessage);
          }
        }
      } else {
        // Updating existing vehicle
        await provider.updateVehicle(
          id: widget.vehicle!.id!,
          marca: marca,
          modelo: modelo,
          matricula: matricula,
          color: color,
          asientosDisponibles: asientosDisponibles,
          observaciones: null,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehículo actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
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

  /// Shows an error message to the user
  void _showError(String message) {
    log('❌ Error: $message');
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'CERRAR',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Shows a dialog to confirm vehicle deletion
  Future<void> _confirmDelete() async {
    log('🗑️ Mostrando diálogo de confirmación de eliminación');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar vehículo'),
        content: const Text('¿Estás seguro de que quieres eliminar este vehículo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteVehicle();
    }
  }
  
  /// Deletes the current vehicle
  Future<void> _deleteVehicle() async {
    if (widget.vehicle == null) return;
    
    log('🗑️ Eliminando vehículo ID: ${widget.vehicle!.id}');
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final provider = Provider.of<VehicleProvider>(context, listen: false);
      final success = await provider.deleteVehicle(widget.vehicle!.id!);
      
      if (!mounted) return;
      
      if (success) {
        log('✅ Vehículo eliminado exitosamente');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehículo eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        final errorMessage = provider.error ?? 'Error desconocido al eliminar el vehículo';
        log('❌ Error al eliminar vehículo: $errorMessage');
        if (mounted) {
          _showError(errorMessage);
        }
      }
    } catch (e) {
      log('❌ Error inesperado al eliminar vehículo', error: e);
      if (mounted) {
        _showError('Error inesperado al eliminar el vehículo');
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
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Añadir Vehículo' : 'Editar Vehículo'),
        actions: [
          if (widget.vehicle != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _isLoading ? null : _confirmDelete,
              tooltip: 'Eliminar vehículo',
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand field
                  TextFormField(
                    controller: _marcaController,
                    decoration: const InputDecoration(
                      labelText: 'Marca *',
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                    textCapitalization: TextCapitalization.words,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa la marca';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Model field
                  TextFormField(
                    controller: _modeloController,
                    decoration: const InputDecoration(
                      labelText: 'Modelo *',
                      prefixIcon: Icon(Icons.model_training),
                    ),
                    textCapitalization: TextCapitalization.words,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa el modelo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // License plate field
                  TextFormField(
                    controller: _matriculaController,
                    decoration: const InputDecoration(
                      labelText: 'Matrícula *',
                      hintText: 'Ej: 1234ABC',
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    enabled: !_isLoading,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      LengthLimitingTextInputFormatter(7),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa la matrícula';
                      }
                      if (value.trim().length < 6) {
                        return 'La matrícula debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Color field (optional)
                  TextFormField(
                    controller: _colorController,
                    decoration: const InputDecoration(
                      labelText: 'Color (opcional)',
                      prefixIcon: Icon(Icons.color_lens),
                    ),
                    textCapitalization: TextCapitalization.words,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  
                  // Available seats field
                  TextFormField(
                    controller: _asientosController,
                    decoration: const InputDecoration(
                      labelText: 'Asientos disponibles *',
                      hintText: 'Ej: 4',
                      prefixIcon: Icon(Icons.event_seat),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_isLoading,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el número de asientos';
                      }
                      final seats = int.tryParse(value) ?? 0;
                      if (seats <= 0) {
                        return 'Debe haber al menos 1 asiento';
                      }
                      if (seats > 9) {
                        return 'El máximo es 9 asientos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Submit button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveForm,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: _isLoading
                          ? const SizedBox.shrink()
                          : Icon(
                              widget.vehicle == null ? Icons.add_circle_outline : Icons.save,
                              size: 24,
                            ),
                      label: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.vehicle == null 
                                  ? 'AÑADIR VEHÍCULO' 
                                  : 'GUARDAR CAMBIOS',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  // Help text
                  if (widget.vehicle == null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Los campos marcados con * son obligatorios. Asegúrate de que la información es correcta antes de guardar.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Loading overlay
          if (_isLoading)
            const AbsorbPointer(
              child: ModalBarrier(
                dismissible: false,
                color: Colors.black45,
              ),
            ),
        ],
      ),
    );
  }
}
