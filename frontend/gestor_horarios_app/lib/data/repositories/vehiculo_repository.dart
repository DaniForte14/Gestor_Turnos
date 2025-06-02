import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestor_horarios_app/core/constants/api_constants.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';
import 'package:gestor_horarios_app/data/services/vehicle_service.dart';

class VehiculoRepository {
  final VehicleService _vehicleService;
  final FlutterSecureStorage _storage;

  VehiculoRepository({
    required VehicleService vehicleService,
    FlutterSecureStorage? storage,
  }) : _vehicleService = vehicleService,
       _storage = storage ?? const FlutterSecureStorage();
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<bool> crearVehiculo(Map<String, dynamic> vehiculo) async {
    try {
      debugPrint('Creating vehicle with data: $vehiculo');
      
      debugPrint('Validating vehicle data: $vehiculo');
      
      // Validar que los campos requeridos no sean nulos
      if (vehiculo['brand'] == null || 
          vehiculo['model'] == null || 
          vehiculo['licensePlate'] == null ||
          vehiculo['totalSeats'] == null) {
        final missingFields = [];
        if (vehiculo['brand'] == null) missingFields.add('brand');
        if (vehiculo['model'] == null) missingFields.add('model');
        if (vehiculo['licensePlate'] == null) missingFields.add('licensePlate');
        if (vehiculo['totalSeats'] == null) missingFields.add('totalSeats');
        
        throw Exception('Faltan campos requeridos: ${missingFields.join(', ')}');
      }
      
      // Convertir totalSeats a entero
      final asientos = int.tryParse(vehiculo['totalSeats'].toString()) ?? 0;
      if (asientos <= 0) {
        throw Exception('El número de asientos debe ser mayor a cero');
      }
      
      final createdVehicle = await _vehicleService.createVehicle(
        marca: vehiculo['brand'].toString(),
        modelo: vehiculo['model'].toString(),
        matricula: vehiculo['licensePlate'].toString(),
        color: vehiculo['color']?.toString(),
        asientosDisponibles: asientos,
        observaciones: vehiculo['observations']?.toString(),
      );
      
      debugPrint('✅ Vehicle created with ID: ${createdVehicle.id}');
      
      debugPrint('✅ Vehicle created successfully: ${createdVehicle.id}');
      return true;
    } on DioException catch (e) {
      debugPrint('❌ Error creating vehicle: ${e.message}');
      if (e.response?.data != null) {
        final errorMessage = e.response!.data is Map 
            ? e.response!.data['message'] ?? 'Error al crear el vehículo'
            : e.response!.data.toString();
        throw Exception(errorMessage);
      }
      throw Exception('Error de conexión al crear el vehículo: ${e.message}');
    } catch (e) {
      debugPrint('❌ Unexpected error creating vehicle: $e');
      throw Exception('Error inesperado al crear el vehículo: $e');
    }
  }

  Future<List<Vehiculo>> obtenerVehiculos() async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/vehicles');
    
    try {
      print('Sending request to: $url');
      final response = await http.get(url, headers: headers);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        // Add null check for the list
        if (jsonList == null) {
          print('Warning: Received null vehicle list from API');
          return [];
        }
        return jsonList.map((json) {
          try {
            return Vehiculo.fromJson(json);
          } catch (e) {
            print('Error parsing vehicle JSON: $e');
            print('Problematic JSON: $json');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Error al obtener los vehículos: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in obtenerVehiculos: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> eliminarVehiculo(int id) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/vehicles/$id');
    
    try {
      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al eliminar el vehículo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> unirseAVehiculo(int vehiculoId) async {
    try {
      debugPrint('🔄 [VehiculoRepository] Uniendo al vehículo $vehiculoId');
      
      try {
        await _vehicleService.joinVehicle(vehiculoId);
        debugPrint('✅ [VehiculoRepository] Usuario unido exitosamente al vehículo $vehiculoId');
        return true;
      } on DioException catch (dioError) {
        debugPrint('❌ [VehiculoRepository] Error de red al unirse al vehículo: ${dioError.message}');
        
        // Handle specific error cases
        if (dioError.response?.data?.toString().contains('StackOverflowError') == true) {
          debugPrint('⚠️ [VehiculoRepository] Error de desbordamiento de pila en el servidor');
          // Try to refresh the vehicle list and check if the user was actually added
          try {
            final vehicles = await obtenerVehiculos();
            final targetVehicle = vehicles.cast<Vehiculo?>().firstWhere(
              (v) => v?.id == vehiculoId,
              orElse: () => null,
            );
            
            if (targetVehicle != null && targetVehicle.pasajeros != null) {
              final userId = await _storage.read(key: 'user_id');
              final isUserInVehicle = targetVehicle.pasajeros?.any((p) => p.id.toString() == userId) ?? false;
              
              if (isUserInVehicle) {
                debugPrint('ℹ️ [VehiculoRepository] El usuario ya está en el vehículo a pesar del error');
                
                return true;
              }
            }
            
            throw Exception(
              'Error en el servidor al procesar la solicitud. ' +
              'Por favor, verifica si ya estás en el vehículo o inténtalo de nuevo más tarde.'
            );
          } catch (e) {
            debugPrint('⚠️ [VehiculoRepository] Error al verificar el estado del vehículo: $e');
            rethrow;
          }
        }
        
        // Handle other Dio errors
        if (dioError.response?.data != null) {
          final errorData = dioError.response!.data;
          final errorMessage = errorData is Map 
              ? errorData['message']?.toString() 
              : errorData.toString();
              
          final message = errorMessage?.isNotEmpty == true 
              ? errorMessage!
              : 'Error al unirse al vehículo (${dioError.response?.statusCode})';
          throw Exception(message);
        }
        
        throw Exception('Error de conexión al unirse al vehículo: ${dioError.message}');
      }
    } catch (e) {
      debugPrint('❌ [VehiculoRepository] Error inesperado al unirse al vehículo: $e');
      if (e is! Exception) {
        throw Exception('Error inesperado al unirse al vehículo');
      }
      rethrow;
    }
  }

  Future<bool> cambiarEstadoActivo(int vehiculoId, bool activo) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/vehicles/$vehiculoId/status');
    
    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({'activo': activo}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al actualizar el estado del vehículo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> salirDeVehiculo(int vehiculoId) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/vehicles/$vehiculoId/leave');
    
    try {
      final response = await http.post(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al salir del vehículo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> estaVehiculo(int vehiculoId) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/vehicles/$vehiculoId/check');
    
    try {
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        // The backend returns a raw boolean value
        return response.body.toLowerCase() == 'true';
      } else {
        throw Exception('Error al verificar el estado del vehículo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtiene la lista de vehículos disponibles a los que el usuario puede unirse
  ///
  /// Retorna una lista de [Vehiculo] que tienen asientos disponibles y
  /// a los que el usuario actual no se ha unido.
  Future<List<Vehiculo>> obtenerVehiculosDisponibles() async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/vehicles/available');
    
    try {
      print('Solicitando vehículos disponibles a: $url');
      final response = await http.get(url, headers: headers);
      
      print('Respuesta de vehículos disponibles:');
      print('  Status: ${response.statusCode}');
      print('  Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Vehiculo.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener vehículos disponibles: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en obtenerVehiculosDisponibles: $e');
      throw Exception('Error de conexión al obtener vehículos disponibles: $e');
    }
  }
}