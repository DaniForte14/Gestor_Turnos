import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestor_horarios_app/core/constants/api_constants.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';

class VehicleService {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  VehicleService() : _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authentication token if exists
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) async {
          // Handle 401 Unauthorized
          if (e.response?.statusCode == 401) {
            // Try to refresh token or handle logout
            debugPrint('Authentication error: ${e.message}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<List<Vehiculo>> getVehicles() async {
    try {
      final response = await _dio.get('/api/vehicles');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => Vehiculo.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load vehicles');
      }
    } catch (e) {
      debugPrint('Error getting vehicles: $e');
      rethrow;
    }
  }

  Future<List<Vehiculo>> getUserVehicles() async {
    try {
      final response = await _dio.get('/api/vehicles/my-vehicles');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => Vehiculo.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load user vehicles');
      }
    } catch (e) {
      debugPrint('Error getting user vehicles: $e');
      rethrow;
    }
  }

  Future<Vehiculo> createVehicle({
    required String marca,
    required String modelo,
    required String matricula,
    String? color,
    required int asientosDisponibles,
    String? observaciones,
  }) async {
    try {
      debugPrint('Enviando solicitud para crear vehículo con datos:');
      debugPrint('Marca: $marca');
      debugPrint('Modelo: $modelo');
      debugPrint('Matrícula: $matricula');
      debugPrint('Color: $color');
      debugPrint('Asientos: $asientosDisponibles');
      debugPrint('Observaciones: $observaciones');
      
      final Map<String, dynamic> requestData = {
        'marca': marca,
        'modelo': modelo,
        'matricula': matricula,
        'color': color,
        'totalAsientos': asientosDisponibles, // Use the same value for total and available seats initially
        'asientosDisponibles': asientosDisponibles,
        'observaciones': observaciones,
        'activo': true
      };
      
      debugPrint('Datos de la solicitud: $requestData');
      
      final response = await _dio.post<dynamic>(
        '/api/vehicles',
        data: requestData,
        options: Options(
          responseType: ResponseType.json,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('Respuesta del servidor: ${response.data}');
      debugPrint('Código de estado: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');

      // Handle error responses
      if (response.statusCode == 400) {
        throw Exception(response.data.toString());
      }

      if (response.statusCode == 201) {
        if (response.data == null) {
          throw Exception('La respuesta del servidor está vacía');
        }
        return Vehiculo.fromJson(response.data!);
      } else {
        final errorMessage = response.data?['message'] ?? response.statusMessage ?? 'Error desconocido';
        debugPrint('Error al crear vehículo: $errorMessage');
        throw Exception('Error al crear el vehículo: $errorMessage');
      }
    } on DioException catch (e) {
      debugPrint('Error de DioException: ${e.message}');
      debugPrint('Tipo de error: ${e.type}');
      debugPrint('Datos de error: ${e.response?.data}');
      debugPrint('Código de estado: ${e.response?.statusCode}');
      debugPrint('Headers: ${e.response?.headers}');
      
      String errorMessage = 'Error al conectar con el servidor';
      if (e.response != null) {
        if (e.response!.data != null) {
          if (e.response!.data is Map) {
            errorMessage = e.response!.data['message'] ?? e.response!.data.toString();
          } else {
            errorMessage = e.response!.data.toString();
          }
        } else {
          errorMessage = 'Error del servidor: ${e.response!.statusCode} - ${e.response!.statusMessage}';
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Excepción inesperada al crear vehículo: $e');
      rethrow;
    }
  }

  Future<Vehiculo> updateVehicle(int id, {
    required String marca,
    required String modelo,
    required String matricula,
    String? color,
    required int asientosDisponibles,
    String? observaciones,
  }) async {
    try {
      final response = await _dio.put(
        '/api/vehicles/$id',
        data: {
          'marca': marca,
          'modelo': modelo,
          'matricula': matricula,
          'color': color,
          'asientosDisponibles': asientosDisponibles,
          'observaciones': observaciones,
        },
      );

      if (response.statusCode == 200) {
        return Vehiculo.fromJson(response.data);
      } else {
        throw Exception('Failed to update vehicle');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteVehicle(int id, {bool hardDelete = false}) async {
    try {
      debugPrint('🔄 [VehicleService] Iniciando eliminación de vehículo ID: $id, hardDelete: $hardDelete');
      
      // Obtener token para depuración
      final token = await _storage.read(key: 'access_token');
      debugPrint('🔑 Token de autenticación: ${token != null ? 'Presente' : 'Ausente'}');
      
      final response = await _dio.delete(
        '/api/vehicles/$id',
        queryParameters: {
          'hardDelete': hardDelete.toString(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          // Aceptar respuesta vacía (204 No Content)
          receiveDataWhenStatusError: true,
          validateStatus: (status) => status! < 300,
        ),
      );

      debugPrint('✅ [VehicleService] Respuesta del servidor:');
      debugPrint('   Status: ${response.statusCode}');
      debugPrint('   Data: ${response.data}');
      debugPrint('   Headers: ${response.headers}');

      // Considerar exitoso cualquier código 2xx (incluyendo 204 No Content)
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        debugPrint('✅ [VehicleService] Vehículo eliminado correctamente');
        return true;
      } else {
        debugPrint('❌ [VehicleService] Error en la respuesta del servidor');
        throw Exception('Error al eliminar el vehículo: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('❌ [VehicleService] Error de conexión:');
      debugPrint('   Tipo: ${e.type}');
      debugPrint('   Mensaje: ${e.message}');
      
      String errorMessage = 'Error de conexión al eliminar el vehículo';
      
      if (e.response != null) {
        debugPrint('   Status code: ${e.response!.statusCode}');
        debugPrint('   Response data: ${e.response!.data}');
        
        // Extraer mensaje de error del servidor si está disponible
        if (e.response!.data != null) {
          if (e.response!.data is Map) {
            errorMessage = e.response!.data['message'] ?? e.response!.data.toString();
          } else {
            errorMessage = e.response!.data.toString();
          }
        } else {
          errorMessage = 'Error del servidor: ${e.response!.statusCode} - ${e.response!.statusMessage}';
        }
      }
      
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      debugPrint('❌ [VehicleService] Error inesperado al eliminar vehículo:');
      debugPrint('   Error: $e');
      debugPrint('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Vehiculo> reserveSeat(int vehicleId) async {
    try {
      final response = await _dio.post(
        '/api/vehicles/$vehicleId/reserve-seat',
        data: {},
      );

      if (response.statusCode == 200) {
        return Vehiculo.fromJson(response.data);
      } else {
        throw Exception('Failed to reserve seat');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Vehiculo> joinVehicle(int vehicleId) async {
    try {
      final response = await _dio.post(
        '/api/vehicles/$vehicleId/join',
        data: {},
      );

      if (response.statusCode == 200) {
        return Vehiculo.fromJson(response.data);
      } else {
        throw Exception('Failed to join vehicle');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'No se pudo unir al vehículo');
      }
      rethrow;
    }
  }

  Future<Vehiculo> leaveVehicle(int vehicleId) async {
    try {
      final response = await _dio.post(
        '/api/vehicles/$vehicleId/leave',
        data: {},
      );

      if (response.statusCode == 200) {
        return Vehiculo.fromJson(response.data);
      } else {
        throw Exception('Failed to leave vehicle');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'No se pudo salir del vehículo');
      }
      rethrow;
    }
  }

  Future<bool> isUserInVehicle(int vehicleId) async {
    try {
      final response = await _dio.get(
        '/api/vehicles/$vehicleId/is-passenger',
      );

      if (response.statusCode == 200) {
        return response.data as bool;
      } else {
        throw Exception('Failed to check passenger status');
      }
    } catch (e) {
      rethrow;
    }
  }
}
