import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:dio/dio.dart' show Dio, DioException, DioExceptionType, InterceptorsWrapper, LogInterceptor, Options, ResponseType;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestor_horarios_app/core/constants/api_constants.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';

class VehicleService {
  final Dio _dio;
  final FlutterSecureStorage _storage;


  VehicleService({Dio? dio}) 
    : _dio = dio ?? Dio()
      ..options.baseUrl = ApiConstants.baseUrl
      ..options.headers['Content-Type'] = 'application/json'
      ..options.headers['Accept'] = 'application/json',
      _storage = const FlutterSecureStorage() {
    _dio.options.validateStatus = (status) => status != null && status < 500;
    
    debugPrint('🚀 VehicleService initialized with baseUrl: ${_dio.options.baseUrl}');
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// Checks if the current user is a passenger in the specified vehicle.
  ///
  /// [vehicleId] - The ID of the vehicle to check
  /// Returns `true` if the user is a passenger in the vehicle, `false` otherwise
  /// Throws an exception if the operation fails
  Future<bool> isUserInVehicle(int vehicleId) async {
    try {
      final response = await _dio.get('${ApiConstants.vehicles}/$vehicleId');
      
      if (response.statusCode == 200) {
        final vehicle = Vehiculo.fromJson(response.data);
        final userId = await _storage.read(key: 'user_id');
        
        if (userId == null) return false;
        
        // Check if the current user is in the passengers list
        return vehicle.pasajeros?.any((p) => p.id.toString() == userId) ?? false;
      }
      
      return false;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception('No se pudo conectar al servidor. Por favor, verifica tu conexión a internet.');
      }
      throw Exception('Error al verificar el estado del vehículo: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Permite a un usuario unirse a un vehículo como pasajero.
  ///
  /// [vehicleId] - El ID del vehículo al que se desea unir
  /// Devuelve el objeto [Vehiculo] actualizado
  /// Lanza una excepción si la operación falla
  Future<Vehiculo> joinVehicle(int vehicleId) async {
    try {
      debugPrint('🚗 [VehicleService] Uniendo al vehículo $vehicleId');
      
      // Get the current user's ID
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) {
        throw Exception('No se pudo obtener el ID del usuario actual');
      }
      
      debugPrint('🚗 [VehicleService] ID del usuario actual: $userId');
      
      final url = '${ApiConstants.vehicles}/$vehicleId/join/$userId';
      debugPrint('🌐 [VehicleService] URL de la petición: $url');
      
      // Get the auth token for debugging
      final token = await _storage.read(key: 'access_token');
      debugPrint('🔑 [VehicleService] Token de autenticación: ${token != null ? 'Presente' : 'Ausente'}');
      
      try {
        final response = await _dio.post(
          url,
          options: Options(
            responseType: ResponseType.plain, // Changed to plain to handle any response
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        debugPrint('✅ [VehicleService] Respuesta del servidor:');
        debugPrint('   Estado: ${response.statusCode}');
        debugPrint('   Tipo de respuesta: ${response.data.runtimeType}');
        debugPrint('   Datos: ${response.data}');
        debugPrint('   Headers: ${response.headers}');

        // If the request was successful (200-299)
        if (response.statusCode! >= 200 && response.statusCode! < 300) {
          try {
            // If we have a response body, try to parse it
            if (response.data != null && response.data.toString().isNotEmpty) {
              final responseData = response.data is Map 
                  ? response.data 
                  : (response.data is String && response.data.isNotEmpty)
                      ? jsonDecode(response.data) 
                      : null;
                      
              if (responseData != null) {
                return Vehiculo.fromJson(responseData);
              }
            }
            
            // If we get here, either the response was empty or couldn't be parsed
            debugPrint('ℹ️ [VehicleService] Respuesta vacía o no JSON, obteniendo vehículo actualizado...');
            return await getVehicleById(vehicleId);
            
          } catch (parseError) {
            debugPrint('⚠️ [VehicleService] Error al procesar la respuesta: $parseError');
            debugPrint('⚠️ [VehicleService] Datos de respuesta: ${response.data}');
            // Continue to try getting the updated vehicle
            return await getVehicleById(vehicleId);
          }
        } else {
          // Handle error responses
          String errorMessage;
          try {
            final responseText = response.data?.toString() ?? '';
            
            // Check for stack overflow error specifically
            if (responseText.contains('StackOverflowError')) {
              errorMessage = 'Error en el servidor: Desbordamiento de pila. Por favor, inténtalo de nuevo más tarde.';
              debugPrint('⚠️ [VehicleService] Error de desbordamiento de pila en el servidor');
            } else {
              // Try to parse the error response
              final errorData = response.data is Map 
                  ? response.data 
                  : (response.data is String && response.data.isNotEmpty)
                      ? jsonDecode(response.data)
                      : null;
                      
              errorMessage = errorData is Map 
                  ? (errorData['message'] ?? 'Error al unirse al vehículo')
                  : 'Error al unirse al vehículo (${response.statusCode})';
            }
          } catch (e) {
            errorMessage = 'Error al procesar la respuesta del servidor (${response.statusCode})';
          }
          throw Exception(errorMessage);
        }
      } on DioException catch (dioError) {
        debugPrint('❌ [VehicleService] Error de Dio:');
        debugPrint('   Tipo: ${dioError.type}');
        debugPrint('   Mensaje: ${dioError.message}');
        debugPrint('   Respuesta: ${dioError.response?.data}');
        debugPrint('   StackTrace: ${dioError.stackTrace}');
        
        if (dioError.type == DioExceptionType.connectionError ||
            dioError.type == DioExceptionType.connectionTimeout) {
          throw Exception('No se pudo conectar al servidor. Verifica tu conexión a internet.');
        } else if (dioError.response != null) {
          String errorMessage;
          try {
            final errorData = dioError.response?.data is Map 
                ? dioError.response?.data 
                : (dioError.response?.data is String && dioError.response?.data.toString().isNotEmpty == true)
                    ? jsonDecode(dioError.response!.data.toString())
                    : null;
                    
            errorMessage = errorData is Map 
                ? (errorData['message'] ?? 'Error en el servidor (${dioError.response?.statusCode})')
                : 'Error en el servidor (${dioError.response?.statusCode})';
          } catch (e) {
            errorMessage = 'Error al procesar la respuesta del servidor (${dioError.response?.statusCode})';
          }
          throw Exception(errorMessage);
        }
        throw Exception('Error de red: ${dioError.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [VehicleService] Error inesperado al unirse al vehículo: $e');
      debugPrint('📝 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Permite a un usuario salir de un vehículo en el que es pasajero.
  ///
  /// [vehicleId] - El ID del vehículo del que se desea salir
  /// Devuelve el objeto [Vehiculo] actualizado
  /// Lanza una excepción si la operación falla
  /// Deletes a vehicle from the system
  ///
  /// [id] - The ID of the vehicle to delete
  /// [hardDelete] - If true, permanently deletes the vehicle. If false, performs a soft delete.
  /// Throws an exception if the operation fails
  Future<void> deleteVehicle(int id, {bool hardDelete = false}) async {
    try {
      debugPrint('🗑️ [VehicleService] Deleting vehicle $id (hardDelete: $hardDelete)');
      
      final response = await _dio.delete(
        '${ApiConstants.vehicles}/$id',
        queryParameters: {'hardDelete': hardDelete},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete vehicle: ${response.statusCode}');
      }
      
      debugPrint('✅ [VehicleService] Vehicle $id deleted successfully');
    } on DioException catch (e) {
      debugPrint('❌ [VehicleService] Error deleting vehicle: ${e.message}');
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No se pudo conectar al servidor. Verifica tu conexión a internet.');
      }
      rethrow;
    } catch (e) {
      debugPrint('❌ [VehicleService] Unexpected error deleting vehicle: $e');
      rethrow;
    }
  }

  /// Allows a user to leave a vehicle they are a passenger in.
  ///
  /// [vehicleId] - The ID of the vehicle to leave
  /// Returns the updated [Vehiculo] object
  /// Throws an exception if the operation fails
  Future<Vehiculo> leaveVehicle(int vehicleId) async {
    try {
      debugPrint('🔄 [VehicleService] Intentando salir del vehículo $vehicleId');
      final token = await _storage.read(key: 'access_token');
      
      if (token == null) {
        throw Exception('No se encontró el token de autenticación');
      }
      
      final response = await _dio.post(
        '/api/vehicles/$vehicleId/leave',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status! < 300 || status == 400,
        ),
      );

      debugPrint('✅ [VehicleService] Respuesta al salir del vehículo:');
      debugPrint('   Estado: ${response.statusCode}');
      debugPrint('   Datos: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return await getVehicleById(vehicleId);
      } else if (response.statusCode == 400) {
        throw Exception(response.data ?? 'No se pudo salir del vehículo');
      } else {
        throw Exception('Error inesperado al salir del vehículo');
      }
    } on DioException catch (e) {
      debugPrint('❌ [VehicleService] Error al salir del vehículo:');
      debugPrint('   Tipo: ${e.type}');
      debugPrint('   Mensaje: ${e.message}');
      
      String errorMessage = 'No se pudo salir del vehículo';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? e.response!.data.toString();
        } else {
          errorMessage = e.response!.data.toString();
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('❌ [VehicleService] Error inesperado al salir del vehículo: $e');
      rethrow;
    }
  }

  /// Fetches a list of all vehicles from the API.
  ///
  /// Returns a list of [Vehiculo] objects.
  /// Throws an exception if the request fails.
  Future<List<Vehiculo>> getVehicles() async {
    try {
      debugPrint('🔄 [VehicleService] Fetching vehicles...');
      
      final response = await _dio.get(
        '/api/vehicles',
        options: Options(
          headers: await _getAuthHeaders(),
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('✅ [VehicleService] Vehicles fetched successfully');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data.map((json) => Vehiculo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load vehicles: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ [VehicleService] Error fetching vehicles:');
      debugPrint('   Type: ${e.type}');
      debugPrint('   Message: ${e.message}');
      
      String errorMessage = 'Failed to load vehicles';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? e.response!.data.toString();
        } else {
          errorMessage = e.response!.data.toString();
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('❌ [VehicleService] Unexpected error: $e');
      rethrow;
    }
  }

  /// Fetches vehicles owned by the currently authenticated user.
  ///
  /// Returns a list of [Vehiculo] objects owned by the current user.
  /// Throws an exception if the request fails.
  Future<List<Vehiculo>> getUserVehicles() async {
    try {
      debugPrint('🔄 [VehicleService] Fetching user vehicles...');
      
      final response = await _dio.get(
        '${ApiConstants.vehicles}/my-vehicles',
        options: Options(
          headers: await _getAuthHeaders(),
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('✅ [VehicleService] User vehicles fetched successfully');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data.map((json) => Vehiculo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user vehicles: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ [VehicleService] Error fetching user vehicles:');
      debugPrint('   Type: ${e.type}');
      debugPrint('   Message: ${e.message}');
      
      String errorMessage = 'Failed to load user vehicles';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? e.response!.data.toString();
        } else {
          errorMessage = e.response!.data.toString();
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('❌ [VehicleService] Unexpected error fetching user vehicles: $e');
      rethrow;
    }
  }

  Future<Vehiculo> getVehicleById(int id) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        throw Exception('No se encontró el token de autenticación');
      }

      final response = await _dio.get(
        '/api/vehicles/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Vehiculo.fromJson(response.data);
      } else {
        throw Exception('Error al obtener el vehículo: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Error al obtener el vehículo: ${e.message}');
      rethrow;
    }
  }

  /// Creates a new vehicle with the provided details.
  ///
  /// Returns the created [Vehiculo] object if successful.
  /// Throws an exception if the operation fails.
  /// Updates an existing vehicle with the provided details.
  ///
  /// [id] - The ID of the vehicle to update
  /// Returns the updated [Vehiculo] object if successful.
  /// Throws an exception if the operation fails.
  Future<Vehiculo> updateVehicle(
    int id, {
    required String marca,
    required String modelo,
    required String matricula,
    String? color,
    required int asientosDisponibles,
    String? observaciones,
  }) async {
    try {
      debugPrint('🔄 [VehicleService] Updating vehicle $id...');
      
      final response = await _dio.put(
        '${ApiConstants.vehicles}/$id',
        data: {
          'marca': marca,
          'modelo': modelo,
          'matricula': matricula,
          if (color != null) 'color': color,
          'asientosDisponibles': asientosDisponibles,
          if (observaciones != null) 'observaciones': observaciones,
        },
        options: Options(
          headers: await _getAuthHeaders(),
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('✅ [VehicleService] Vehicle updated successfully');
      
      if (response.statusCode == 200) {
        return Vehiculo.fromJson(response.data);
      } else {
        final errorMessage = response.data?['message'] ?? 'Error al actualizar el vehículo';
        debugPrint('❌ [VehicleService] Error updating vehicle: $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('❌ [VehicleService] Error de conexión al actualizar vehículo:');
      debugPrint('   Tipo: ${e.type}');
      debugPrint('   Mensaje: ${e.message}');
      
      if (e.response?.data != null) {
        final errorMessage = e.response!.data is Map 
            ? e.response!.data['message'] ?? 'Error al actualizar el vehículo'
            : e.response!.data.toString();
        throw Exception(errorMessage);
      }
      throw Exception('Error de conexión al actualizar el vehículo');
    } catch (e) {
      debugPrint('❌ [VehicleService] Error inesperado al actualizar vehículo: $e');
      rethrow;
    }
  }

  /// Creates a new vehicle with the provided details.
  ///
  /// Returns the created [Vehiculo] object if successful.
  /// Throws an exception if the operation fails.
  Future<Vehiculo> createVehicle({
    required String marca,
    required String modelo,
    required String matricula,
    String? color,
    required int asientosDisponibles,
    String? observaciones,
  }) async {
    try {
      debugPrint('🚗 [VehicleService] Creando nuevo vehículo...');
      
      final response = await _dio.post(
        ApiConstants.vehicles, // Usamos la constante base sin /create
        data: {
          'brand': marca,
          'model': modelo,
          'licensePlate': matricula,
          if (color != null) 'color': color,
          'totalSeats': asientosDisponibles,
          'availableSeats': asientosDisponibles, // Inicialmente igual a totalSeats
          if (observaciones != null) 'observations': observaciones,
          'active': true,
        },
        options: Options(
          headers: await _getAuthHeaders(),
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('✅ [VehicleService] Vehículo creado exitosamente');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Vehiculo.fromJson(response.data);
      } else {
        final errorMessage = response.data?['message'] ?? 'Error al crear el vehículo';
        debugPrint('❌ [VehicleService] Error al crear vehículo: $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('❌ [VehicleService] Error de conexión al crear vehículo:');
      debugPrint('   Tipo: ${e.type}');
      debugPrint('   Mensaje: ${e.message}');
      
      final errorMessage = _getErrorMessage(e, 'No se pudo crear el vehículo');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('❌ [VehicleService] Error inesperado al crear vehículo: $e');
      rethrow;
    }
  }

  // Add other methods from the original file here...
  
  // Helper method to get authentication headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method to extract error message from DioException
  String _getErrorMessage(DioException e, String defaultMessage) {
    if (e.response?.data != null) {
      if (e.response!.data is Map) {
        return e.response!.data['message'] ?? 
               e.response!.data['error'] ?? 
               e.response!.data.toString();
      }
      return e.response!.data.toString();
    }
    return defaultMessage;
  }
}
