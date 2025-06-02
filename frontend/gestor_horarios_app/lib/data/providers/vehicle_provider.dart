import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';
import 'package:gestor_horarios_app/data/services/vehicle_service.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';

class VehicleProvider with ChangeNotifier {
  final VehicleService _vehicleService;
  final AuthProvider _authProvider;
  
  // Track the currently selected vehicle
  Vehiculo? _currentVehicle;
  
  // Track if the provider is still mounted
  bool _isDisposed = false;
  
  // Check if the provider is still mounted
  bool get mounted => !_isDisposed;
  
  VehicleProvider(this._authProvider, {VehicleService? vehicleService}) 
    : _vehicleService = vehicleService ?? VehicleService();
  
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
  
  // Method to update auth provider reference
  void updateAuth(AuthProvider authProvider) {
    // No need to update _authProvider as it's final now
    // Optionally reload data if needed when auth changes
    if (authProvider.isAuthenticated) {
      loadVehicles();
      loadMyVehicles();
      loadUserVehicles();
    } else {
      _vehicles = [];
      _myVehicles = [];
      _userVehicles = [];
      notifyListeners();
    }
  }

  // Constructor is now defined above with dependency injection for VehicleService
  
  List<Vehiculo> _vehicles = [];
  List<Vehiculo> _myVehicles = [];
  List<Vehiculo> _userVehicles = [];
  bool _isLoading = false;
  String? _error;

  List<Vehiculo> get vehicles => _vehicles;
  List<Vehiculo> get userVehicles => _userVehicles;
  List<Vehiculo> get myVehicles => _myVehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar todos los vehículos disponibles
  Future<void> loadVehicles() async {
    try {
      if (!_authProvider.isAuthenticated) {
        _error = 'No autenticado';
        if (mounted) notifyListeners();
        return;
      }

      // No hacer nada si ya se está cargando
      if (_isLoading) return;
      
      _isLoading = true;
      _error = null;
      if (mounted) notifyListeners();

      try {
        _vehicles = await _vehicleService.getVehicles();
        _error = null;
      } catch (e) {
        _error = 'Error al cargar vehículos: ${e.toString()}';
        debugPrint('❌ Error en loadVehicles: $e');
        rethrow;
      }
    } finally {
      _isLoading = false;
      if (mounted) notifyListeners();
    }
  }

  // Join a vehicle as a passenger
  Future<bool> joinVehicleAsPassenger(Vehiculo vehicle) async {
    try {
      if (!_authProvider.isAuthenticated) {
        _error = 'No autenticado';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        // Convert vehicle ID to int for the service layer
        final vehicleId = vehicle.id;
        if (vehicleId == null) {
          throw Exception('ID de vehículo inválido');
        }

        // Log the action for debugging
        debugPrint('🔄 [VehicleProvider] Uniendo al usuario al vehículo $vehicleId');
        
        // Call the joinVehicle method that includes user ID in the URL
        // The user ID will be retrieved from secure storage in the VehicleService
        final updatedVehicle = await _vehicleService.joinVehicle(vehicleId);
        
        // Update the vehicle in the lists
        updateVehicleInLists(updatedVehicle);
        
        debugPrint('✅ [VehicleProvider] Usuario unido exitosamente al vehículo $vehicleId');
        notifyListeners();
        return true;
      } catch (e) {
        _error = e.toString();
        debugPrint('❌ [VehicleProvider] Error al unirse al vehículo: $e');
        rethrow;
      } finally {
        _isLoading = false;
        if (mounted) notifyListeners();
      }
    } catch (e) {
      _error = 'Error al unirse al vehículo: $e';
      rethrow;
    } finally {
      _isLoading = false;
      if (mounted) notifyListeners();
    }
  }
  
  // Helper method to update a vehicle in all lists
  void updateVehicleInLists(Vehiculo updatedVehicle) {
    if (updatedVehicle.id == null) return;
    
    // Update in vehicles list
    final vehicleIndex = _vehicles.indexWhere((v) => v.id == updatedVehicle.id);
    if (vehicleIndex != -1) {
      _vehicles[vehicleIndex] = updatedVehicle;
    }
    
    // Update in myVehicles list
    final myVehicleIndex = _myVehicles.indexWhere((v) => v.id == updatedVehicle.id);
    if (myVehicleIndex != -1) {
      _myVehicles[myVehicleIndex] = updatedVehicle;
    }
    
    // Update in userVehicles list
    final userVehicleIndex = _userVehicles.indexWhere((v) => v.id == updatedVehicle.id);
    if (userVehicleIndex != -1) {
      _userVehicles[userVehicleIndex] = updatedVehicle;
    }
  }

  // Leave a vehicle
  Future<bool> leaveVehicleAsPassenger(Vehiculo vehicle) async {
    try {
      if (!_authProvider.isAuthenticated) {
        _error = 'No autenticado';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        // Get the vehicle ID
        final vehicleId = vehicle.id;
        if (vehicleId == null) {
          throw Exception('ID de vehículo inválido');
        }

        final updatedVehicle = await _vehicleService.leaveVehicle(vehicleId);
        
        // Update the vehicle in the lists
        updateVehicleInLists(updatedVehicle);
        
        if (mounted) notifyListeners();
        return true;
      } catch (e) {
        _error = e.toString();
        rethrow;
      } finally {
        _isLoading = false;
        if (mounted) notifyListeners();
      }
    } catch (e) {
      _error = 'Error al salir del vehículo: $e';
      rethrow;
    } finally {
      _isLoading = false;
      if (mounted) notifyListeners();
    }
  }

  // Cargar vehículos del usuario actual
  Future<void> loadMyVehicles() async {
    try {
      if (!_authProvider.isAuthenticated) {
        _error = 'No autenticado';
        if (mounted) notifyListeners();
        return;
      }

      // No hacer nada si ya se está cargando
      if (_isLoading) return;
      
      _isLoading = true;
      _error = null;
      if (mounted) notifyListeners();

      try {
        _myVehicles = await _vehicleService.getUserVehicles();
        _error = null;
      } catch (e) {
        _error = 'Error al cargar tus vehículos: ${e.toString()}';
        debugPrint('❌ Error en loadMyVehicles: $e');
        rethrow;
      }
    } finally {
      _isLoading = false;
      if (mounted) notifyListeners();
    }
  }

  // Cargar vehículos del usuario (alias de loadMyVehicles para compatibilidad)
  Future<void> loadUserVehicles() async {
    try {
      if (!mounted) return;
      
      await loadMyVehicles();
      
      if (!mounted) return;
      _userVehicles = List.from(_myVehicles);
      
      if (mounted) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error en loadUserVehicles: $e');
      if (mounted) {
        _error = 'Error al cargar vehículos del usuario: ${e.toString()}';
        notifyListeners();
      }
      rethrow;
    }
  }
  
  // Helper method to update a vehicle in the provider's state
  void _updateVehicleInLists(Vehiculo updatedVehicle) {
    // Update in vehicles list
    final vehicleIndex = _vehicles.indexWhere((v) => v.id == updatedVehicle.id);
    if (vehicleIndex != -1) {
      _vehicles[vehicleIndex] = updatedVehicle;
    }
    
    // Update in user vehicles list if present
    final userVehicleIndex = _userVehicles.indexWhere((v) => v.id == updatedVehicle.id);
    if (userVehicleIndex != -1) {
      _userVehicles[userVehicleIndex] = updatedVehicle;
    }
    
    // Update current vehicle if it's the one being updated
    if (_currentVehicle?.id == updatedVehicle.id) {
      _currentVehicle = updatedVehicle;
    }
    
    notifyListeners();
  }

  /// Adds a new vehicle to the system.
  ///
  /// Returns `true` if the vehicle was added successfully, `false` otherwise.
  /// If an error occurs, the error message will be stored in the [_error] field.
  Future<bool> addVehicle({
    required String marca,
    required String modelo,
    required String matricula,
    String? color,
    required int asientosDisponibles,
    String? observaciones,
  }) async {
    log('🚗 Iniciando proceso de adición de vehículo');
    log('🔹 Marca: $marca');
    log('🔹 Modelo: $modelo');
    log('🔹 Matrícula: $matricula');
    log('🔹 Color: $color');
    log('🔹 Asientos disponibles: $asientosDisponibles');
    log('🔹 Observaciones: $observaciones');

    // Update loading state
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('📡 Llamando al servicio para crear vehículo...');
      final newVehicle = await _vehicleService.createVehicle(
        marca: marca,
        modelo: modelo,
        matricula: matricula,
        color: color,
        asientosDisponibles: asientosDisponibles,
        observaciones: observaciones,
      );
      
      log('✅ Vehículo creado exitosamente', error: newVehicle.toString());
      
      // Update local state optimistically
      _vehicles.add(newVehicle);
      _myVehicles.add(newVehicle);
      _error = null;
      
      // Actualizar datos del servidor para asegurar consistencia
      log('🔄 Sincronizando datos con el servidor...');
      try {
        // Actualizar solo la lista de mis vehículos, ya que es el único que debería cambiar
        await loadMyVehicles();
        log('✅ Datos sincronizados correctamente');
      } catch (syncError) {
        log('⚠️ Error al sincronizar datos después de crear vehículo: $syncError');
        // Continuar incluso si falla la sincronización, ya actualizamos localmente
      }
      
      return true;
      
    } catch (e, stackTrace) {
      log('❌ Error al crear vehículo', error: e, stackTrace: stackTrace);
      _error = e is String ? e : e.toString();
      
      // Provide more user-friendly error messages
      if (e.toString().contains('matricula')) {
        _error = 'La matrícula ya está en uso. Por favor, verifica e intenta de nuevo.';
      } else if (e.toString().contains('No autenticado') || e.toString().contains('401')) {
        _error = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
      } else if (e.toString().contains('timeout') || e.toString().contains('SocketException')) {
        _error = 'No se pudo conectar al servidor. Verifica tu conexión a Internet.';
      }
      
      return false;
      
    } finally {
      // Always update the UI when done
      _isLoading = false;
      notifyListeners();
      log('🏁 Proceso de adición de vehículo finalizado');
    }
  }

  // Update an existing vehicle
  Future<bool> updateVehicle({
    required int id,
    required String marca,
    required String modelo,
    required String matricula,
    String? color,
    required int asientosDisponibles,
    String? observaciones,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedVehicle = await _vehicleService.updateVehicle(
        id,
        marca: marca,
        modelo: modelo,
        matricula: matricula,
        color: color,
        asientosDisponibles: asientosDisponibles,
        observaciones: observaciones,
      );
      
      _updateVehicleInLists(updatedVehicle);
      
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a vehicle
  Future<bool> deleteVehicle(int id, {bool hardDelete = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _vehicleService.deleteVehicle(id, hardDelete: hardDelete);
      
      // Remove from vehicles list
      _vehicles.removeWhere((v) => v.id == id);
      
      // Remove from myVehicles list
      _myVehicles.removeWhere((v) => v.id == id);
      
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reserve a seat in a vehicle by joining it
  Future<bool> reserveSeat(int vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedVehicle = await _vehicleService.joinVehicle(vehicleId);
      
      _updateVehicleInLists(updatedVehicle);
      
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Joins a vehicle as a passenger.
  ///
  /// Returns the updated [Vehiculo] if successful.
  /// Throws an exception if the operation fails.
  Future<Vehiculo> joinVehicle(int vehicleId) async {
    log('🚗 Iniciando proceso de unión a vehículo ID: $vehicleId');
    
    // Show loading state
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      log('📡 Solicitando unión al vehículo...');
      final vehicle = await _vehicleService.joinVehicle(vehicleId);
      log('✅ Unión exitosa al vehículo ID: ${vehicle.id}');
      
      // Update the vehicle in the vehicles list
      final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        _vehicles[index] = vehicle;
        log('🔄 Vehículo actualizado en la lista general');
      }
      
      // Add to user's vehicles if not already there
      if (!_userVehicles.any((v) => v.id == vehicle.id)) {
        _userVehicles.add(vehicle);
        log('➕ Vehículo añadido a la lista del usuario');
      }
      
      // Update current vehicle if it's the one being joined
      if (_currentVehicle?.id == vehicle.id) {
        _currentVehicle = vehicle;
        log('🔄 Vehículo actual establecido como vehículo actual');
      }
      
      // Refresh data from server to ensure consistency
      log('🔄 Sincronizando datos con el servidor...');
      try {
        await Future.wait([
          loadVehicles(),
          loadUserVehicles(),
        ]);
        log('✅ Datos sincronizados correctamente');
      } catch (syncError) {
        log('⚠️ Error al sincronizar datos después de unirse al vehículo: $syncError');
        // Continue even if sync fails, as we've already updated locally
      }
      
      return vehicle;
      
    } catch (e, stackTrace) {
      log('❌ Error al unirse al vehículo', error: e, stackTrace: stackTrace);
      
      // Provide more user-friendly error messages
      if (e.toString().contains('No hay plazas disponibles')) {
        _error = 'No hay plazas disponibles en este vehículo.';
      } else if (e.toString().contains('Ya estás en este vehículo')) {
        _error = 'Ya formas parte de este vehículo.';
      } else if (e.toString().contains('No autenticado') || e.toString().contains('401')) {
        _error = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
      } else if (e.toString().contains('timeout') || e.toString().contains('SocketException')) {
        _error = 'No se pudo conectar al servidor. Verifica tu conexión a Internet.';
      } else {
        _error = 'Error al unirse al vehículo: ${e.toString()}';
      }
      
      notifyListeners();
      rethrow;
      
    } finally {
      // Always update the UI when done
      _isLoading = false;
      notifyListeners();
      log('🏁 Proceso de unión a vehículo finalizado');
    }
  }

  // Leave a vehicle
  Future<Vehiculo> leaveVehicle(int vehicleId) async {
    try {
      // Show loading state
      _isLoading = true;
      notifyListeners();
      
      // Call the service to leave the vehicle
      final vehicle = await _vehicleService.leaveVehicle(vehicleId);
      
      // Update the vehicle in the vehicles list
      final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        _vehicles[index] = vehicle;
      }
      
      // Remove from user's vehicles
      _userVehicles.removeWhere((v) => v.id == vehicle.id);
      
      // Clear current vehicle if it's the one being left
      if (_currentVehicle?.id == vehicle.id) {
        _currentVehicle = null;
      }
      
      // Update state
      _isLoading = false;
      notifyListeners();
      
      return vehicle;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Check if current user is a passenger in a vehicle
  Future<bool> checkIfUserInVehicle(int vehicleId) async {
    try {
      return await _vehicleService.isUserInVehicle(vehicleId);
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
