import 'package:flutter/foundation.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';
import 'package:gestor_horarios_app/data/services/vehicle_service.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';

class VehicleProvider with ChangeNotifier {
  final VehicleService _vehicleService;
  AuthProvider _authProvider;
  
  // Method to update auth provider reference
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    // Optionally reload data if needed when auth changes
    if (_authProvider.isAuthenticated) {
      loadVehicles();
      loadMyVehicles();
    } else {
      _vehicles = [];
      _myVehicles = [];
      notifyListeners();
    }
  }

  VehicleProvider(this._authProvider) : _vehicleService = VehicleService();
  
  List<Vehiculo> _vehicles = [];
  List<Vehiculo> _myVehicles = [];
  bool _isLoading = false;
  String? _error;

  List<Vehiculo> get vehicles => _vehicles;
  List<Vehiculo> get myVehicles => _myVehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all available vehicles
  Future<void> loadVehicles() async {
    if (!_authProvider.isAuthenticated) {
      _error = 'No autenticado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicles = await _vehicleService.getVehicles();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load vehicles of the current user
  Future<void> loadMyVehicles() async {
    if (!_authProvider.isAuthenticated) {
      _error = 'No autenticado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myVehicles = await _vehicleService.getUserVehicles();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new vehicle
  Future<bool> addVehicle({
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
      final newVehicle = await _vehicleService.createVehicle(
        marca: marca,
        modelo: modelo,
        matricula: matricula,
        color: color,
        asientosDisponibles: asientosDisponibles,
        observaciones: observaciones,
      );
      
      _myVehicles.add(newVehicle);
      _vehicles.add(newVehicle);
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
      
      final index = _myVehicles.indexWhere((v) => v.id == id);
      if (index != -1) {
        _myVehicles[index] = updatedVehicle;
      }
      
      final allIndex = _vehicles.indexWhere((v) => v.id == id);
      if (allIndex != -1) {
        _vehicles[allIndex] = updatedVehicle;
      }
      
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

  // Reserve a seat in a vehicle
  Future<bool> reserveSeat(int vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedVehicle = await _vehicleService.reserveSeat(vehicleId);
      
      // Update in vehicles list
      final vehicleIndex = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (vehicleIndex != -1) {
        _vehicles[vehicleIndex] = updatedVehicle;
      }
      
      // If it's in myVehicles list, update it there too
      final myVehicleIndex = _myVehicles.indexWhere((v) => v.id == vehicleId);
      if (myVehicleIndex != -1) {
        _myVehicles[myVehicleIndex] = updatedVehicle;
      }
      
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

  // Join a vehicle as a passenger
  Future<bool> joinVehicle(int vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedVehicle = await _vehicleService.joinVehicle(vehicleId);
      
      // Update in vehicles list
      final vehicleIndex = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (vehicleIndex != -1) {
        _vehicles[vehicleIndex] = updatedVehicle;
      }
      
      // If it's in myVehicles list, update it there too
      final myVehicleIndex = _myVehicles.indexWhere((v) => v.id == vehicleId);
      if (myVehicleIndex != -1) {
        _myVehicles[myVehicleIndex] = updatedVehicle;
      }
      
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

  // Leave a vehicle
  Future<bool> leaveVehicle(int vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedVehicle = await _vehicleService.leaveVehicle(vehicleId);
      
      // Update in vehicles list
      final vehicleIndex = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (vehicleIndex != -1) {
        _vehicles[vehicleIndex] = updatedVehicle;
      }
      
      // If it's in myVehicles list, update it there too
      final myVehicleIndex = _myVehicles.indexWhere((v) => v.id == vehicleId);
      if (myVehicleIndex != -1) {
        _myVehicles[myVehicleIndex] = updatedVehicle;
      }
      
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
