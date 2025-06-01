import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:gestor_horarios_app/data/providers/vehicle_provider.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';

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

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final marca = _marcaController.text.trim();
      final modelo = _modeloController.text.trim();
      final matricula = _matriculaController.text.trim().toUpperCase();
      final color = _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : null;
      final asientosDisponibles = int.tryParse(_asientosController.text) ?? 4;

      final provider = Provider.of<VehicleProvider>(context, listen: false);
      
      if (widget.vehicle == null) {
        // Adding a new vehicle
        await provider.addVehicle(
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
              content: Text('Vehículo añadido correctamente'),
              backgroundColor: Colors.green,
            ),
          );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Añadir Vehículo' : 'Editar Vehículo'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveForm,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text(
                    'Información del Vehículo',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _marcaController,
                    decoration: const InputDecoration(
                      labelText: 'Marca *',
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingrese la marca';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _modeloController,
                    decoration: const InputDecoration(
                      labelText: 'Modelo *',
                      prefixIcon: Icon(Icons.model_training),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingrese el modelo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _matriculaController,
                    decoration: const InputDecoration(
                      labelText: 'Matrícula *',
                      prefixIcon: Icon(Icons.confirmation_number),
                      hintText: 'Ej: ABC123',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingrese la matrícula';
                      }
                      if (value.trim().length < 4) {
                        return 'La matrícula debe tener al menos 4 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _colorController,
                    decoration: const InputDecoration(
                      labelText: 'Color',
                      prefixIcon: Icon(Icons.color_lens),
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _asientosController,
                    decoration: const InputDecoration(
                      labelText: 'Asientos Disponibles *',
                      prefixIcon: Icon(Icons.people),
                      suffixText: 'asientos',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el número de asientos';
                      }
                      final seats = int.tryParse(value) ?? 0;
                      if (seats < 1 || seats > 50) {
                        return 'Ingrese un valor entre 1 y 50';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveForm,
                      icon: const Icon(Icons.save),
                      label: Text(
                        widget.vehicle == null ? 'GUARDAR VEHÍCULO' : 'ACTUALIZAR VEHÍCULO',
                        style: const TextStyle(fontSize: 16, letterSpacing: 0.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (widget.vehicle?.id != null) ...[  
                    const SizedBox(height: 16),
                    Text(
                      'ID del vehículo: ${widget.vehicle!.id}',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
