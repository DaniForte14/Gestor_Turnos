import 'package:flutter/foundation.dart';
import 'package:gestor_horarios_app/core/constants/api_constants.dart';
import 'package:gestor_horarios_app/core/utils/api_client.dart';
import 'package:gestor_horarios_app/data/models/horario.dart';

class HorarioRepository {
  final ApiClient _apiClient;
  
  HorarioRepository(this._apiClient);
  
  Future<List<Horario>> getMisHorarios() async {
    try {
      final response = await _apiClient.get(ApiConstants.horariosByUser);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Horario.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo mis horarios: $e');
      return [];
    }
  }
  
  Future<List<Horario>> getHorariosPorFecha(DateTime fechaInicio, DateTime fechaFin) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.horariosByDate,
        queryParams: {
          'fechaInicio': fechaInicio.toIso8601String().split('T')[0],
          'fechaFin': fechaFin.toIso8601String().split('T')[0],
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Horario.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo horarios por fecha: $e');
      return [];
    }
  }
  
  Future<List<Horario>> getHorariosDisponibles({
    required DateTime fecha,
    String? rol,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      String endpoint;
      
      // Debug log the incoming role
      debugPrint('getHorariosDisponibles - Rol recibido: $rol');
      
      if (rol != null && rol.isNotEmpty) {
        // Usar el endpoint basado en rol con rol y fecha
        endpoint = ApiConstants.horariosDisponiblesPorRol;
        
        // Normalizar el rol para el backend
        String normalizedRol = rol.trim().toUpperCase();
        
        // Asegurar que el rol tenga el prefijo ROLE_ y esté en mayúsculas
        if (!normalizedRol.startsWith('ROLE_')) {
          normalizedRol = 'ROLE_$normalizedRol';
        }
        
        // Mapear variantes de roles a los valores esperados
        final roleMappings = {
          'ROLE_MÉDICO': 'ROLE_MEDICO',
          'ROLE_MEDICO': 'ROLE_MEDICO',
          'ROLE_ENFERMERO': 'ROLE_ENFERMERO',
          'ROLE_TCAE': 'ROLE_TCAE',
        };
        
        // Verificar si el rol está en los mapeos, si no, lanzar un error
        normalizedRol = roleMappings[normalizedRol] ?? normalizedRol;
        
        // Validar que el rol sea uno de los permitidos
        if (!['ROLE_MEDICO', 'ROLE_ENFERMERO', 'ROLE_TCAE'].contains(normalizedRol)) {
          debugPrint('Error: Rol no válido: $normalizedRol. Se usará el rol sin modificar: $rol');
          // En lugar de usar ROLE_USER, mantenemos el rol original para ver el error en el backend
          normalizedRol = rol; // Mantenemos el rol original para ver el error
        }
        
        debugPrint('Rol normalizado: $normalizedRol');
        
        queryParams['rol'] = normalizedRol;
        queryParams['fecha'] = fecha.toIso8601String().split('T')[0];
        
        debugPrint('Usando endpoint con rol específico. Rol normalizado: $normalizedRol');
      } else {
        // Usar el endpoint general de horarios disponibles con rango de fechas
        endpoint = ApiConstants.horariosDisponibles;
        final startDate = fecha.toIso8601String().split('T')[0];
        final endDate = fecha.add(const Duration(days: 7)).toIso8601String().split('T')[0];
        queryParams['inicio'] = startDate;
        queryParams['fin'] = endDate;
        debugPrint('Usando endpoint general sin rol específico');
      }
      
      debugPrint('Solicitando horarios disponibles...');
      debugPrint('Endpoint: ${ApiConstants.baseUrl}$endpoint');
      debugPrint('Parámetros: $queryParams');
      
      final response = await _apiClient.get(
        endpoint,
        queryParams: queryParams,
      );
      
      debugPrint('Respuesta recibida - Código: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        if (response.data == null) {
          debugPrint('La respuesta está vacía (null)');
          return [];
        }
        
        final List<dynamic> data = response.data is List ? response.data : [];
        debugPrint('Se recibieron ${data.length} horarios');
        
        if (data.isEmpty) {
          debugPrint('No hay horarios disponibles para los criterios de búsqueda');
          return [];
        }
        
        try {
          return data.map((item) => Horario.fromJson(item)).toList();
        } catch (e) {
          debugPrint('Error al procesar los datos de los horarios: $e');
          debugPrint('Datos recibidos: ${response.data}');
          return [];
        }
      } else {
        debugPrint('Error en la respuesta: ${response.statusCode} - ${response.statusMessage}');
        return [];
      }
    } catch (e) {
      print('Error obteniendo horarios disponibles: $e');
      rethrow;
    }
  }
  
  Future<Horario?> getHorarioPorId(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.horarios}/$id');
      
      if (response.statusCode == 200) {
        return Horario.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error obteniendo horario por ID: $e');
      return null;
    }
  }
  
  /// Crea un nuevo horario disponible en el servidor
  Future<Horario> crearHorarioDisponible(Horario horario) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.horarios,
        data: horario.toJson(),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Horario.fromJson(response.data);
      } else {
        throw Exception('Error al crear el horario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en HorarioRepository.crearHorarioDisponible: $e');
      rethrow;
    }
  }
  
  Future<Horario?> crearHorario(Horario horario) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.horarios,
        data: horario.toJson(),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Horario.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error creando horario: $e');
      return null;
    }
  }
  
  Future<Horario?> actualizarHorario(Horario horario) async {
    try {
      if (horario.id == null) return null;
      
      final response = await _apiClient.put(
        '${ApiConstants.horarios}/${horario.id}',
        data: horario.toJson(),
      );
      
      if (response.statusCode == 200) {
        return Horario.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error actualizando horario: $e');
      return null;
    }
  }
  
  Future<bool> eliminarHorario(int id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.horarios}/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('Error eliminando horario: $e');
      return false;
    }
  }
}
