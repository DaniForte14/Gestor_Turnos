import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:gestor_horarios_app/core/constants/api_constants.dart';
import 'package:gestor_horarios_app/data/models/schedule_model.dart';
import 'package:gestor_horarios_app/data/services/api_service.dart';

class ScheduleRepository {
  final ApiService _apiService = ApiService();
  final String _schedulesKey = 'saved_schedules';

  // Obtener los horarios del usuario actual
  Future<List<Schedule>> getSchedules() async {
    try {
      debugPrint('🔍 Obteniendo horarios del usuario...');
      
      // Primero intentamos obtener los horarios del endpoint de mis-turnos
      try {
        final response = await _apiService.get('api/horarios/mis-turnos');
        if (response is List) {
          final schedules = response.map((json) => Schedule.fromJson(json)).toList();
          await saveSchedulesLocally(schedules);
          debugPrint('✅ Se obtuvieron ${schedules.length} horarios de mis-turnos');
          return schedules;
        }
      } on DioError catch (e) {
        debugPrint('⚠️ Error de red/API en mis-turnos: ${e.message}');
        if (e.response != null) {
          debugPrint('Status: ${e.response?.statusCode}');
          debugPrint('Datos: ${e.response?.data}');
        }
        // Continuamos al siguiente intento
      } catch (e) {
        debugPrint('⚠️ Error inesperado en mis-turnos: $e');
        // Continuamos al siguiente intento
      }
      
      // Si llegamos aquí, el primer intento falló, intentamos con el segundo endpoint
      try {
        final response = await _apiService.get('api/users/me/schedules');
        if (response is List) {
          final schedules = response.map((json) => Schedule.fromJson(json)).toList();
          await saveSchedulesLocally(schedules);
          debugPrint('✅ Se obtuvieron ${schedules.length} horarios de users/me/schedules');
          return schedules;
        }
      } on DioError catch (e) {
        debugPrint('⚠️ Error de red/API en users/me/schedules: ${e.message}');
        if (e.response != null) {
          debugPrint('Status: ${e.response?.statusCode}');
          debugPrint('Datos: ${e.response?.data}');
        }
        // Continuamos al manejo de error final
      } catch (e) {
        debugPrint('⚠️ Error inesperado en users/me/schedules: $e');
        // Continuamos al manejo de error final
      }
      
      // Si llegamos aquí, ambos intentos fallaron, intentamos cargar datos locales
      debugPrint('⚠️ No se pudieron obtener los horarios de los endpoints, cargando locales...');
      return await loadLocalSchedules();
      
    } catch (e) {
      debugPrint('❌ Error general al obtener horarios: $e');
      // Como último recurso, intentamos cargar datos locales
      try {
        return await loadLocalSchedules();
      } catch (e) {
        debugPrint('❌ Error al cargar horarios locales: $e');
        rethrow;
      }
    }
  }

  // Obtener horarios disponibles para un rol específico
  Future<List<Schedule>> getPublishedSchedules({
    required DateTime date,
    required String role,
  }) async {
    try {
      final response = await _apiService.get(
        'api/horarios/disponibles',
        queryParams: {
          'rol': role,
          'fecha': date.toIso8601String().split('T')[0],
        },
      );
      
      if (response is List) {
        return response.map((json) => Schedule.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
      rethrow;
    }
  }

  // Eliminar un turno por su ID
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      debugPrint('🚀 Intentando eliminar turno con ID: $scheduleId');
      final response = await _apiService.delete('api/horarios/$scheduleId');
      debugPrint('✅ Turno eliminado correctamente: $response');
      
      // Actualizar la caché local eliminando el turno
      try {
        final prefs = await SharedPreferences.getInstance();
        final schedulesJson = prefs.getStringList(_schedulesKey) ?? [];
        schedulesJson.removeWhere((json) {
          try {
            final schedule = Schedule.fromJson(jsonDecode(json));
            return schedule.id == scheduleId;
          } catch (e) {
            return false;
          }
        });
        await prefs.setStringList(_schedulesKey, schedulesJson);
        debugPrint('🔄 Caché local actualizada después de eliminar el turno');
      } catch (e) {
        debugPrint('⚠️ Error al actualizar caché local: $e');
        // No relanzamos la excepción ya que la operación principal fue exitosa
      }
    } on DioError catch (e) {
      final errorMessage = e.response?.data?.toString() ?? e.message ?? 'Error desconocido';
      debugPrint('❌ Error al eliminar turno (${e.response?.statusCode}): $errorMessage');
      if (e.response != null) {
        debugPrint('URL: ${e.requestOptions.path}');
        debugPrint('Headers: ${e.requestOptions.headers}');
      }
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inesperado al eliminar turno: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Crear un nuevo horario
  Future<Schedule> createSchedule(Schedule schedule) async {
    try {
      final response = await _apiService.post(
        'api/horarios',
        schedule.toJson(),
      );
      return Schedule.fromJson(response);
    } catch (e) {
      debugPrint('Error creating schedule: $e');
      rethrow;
    }
  }

  // Actualizar un horario existente
  Future<Schedule> updateSchedule(Schedule schedule) async {
    try {
      final response = await _apiService.put(
        'api/horarios/${schedule.id}',
        schedule.toJson(),
      );
      return Schedule.fromJson(response);
    } catch (e) {
      debugPrint('Error updating schedule: $e');
      rethrow;
    }
  }

  // Solicitar un horario disponible
  Future<Schedule> requestSchedule({
    required String scheduleId,
    required String userId,
  }) async {
    try {
      debugPrint('Iniciando solicitud de horario: ID=$scheduleId, UserID=$userId');
      
      final horario = await _apiService.get('api/horarios/$scheduleId');
      
      if (horario['disponible'] == false) {
        throw Exception('El horario seleccionado ya no está disponible');
      }
      
      final response = await _apiService.put(
        'api/horarios/$scheduleId/disponible/false',
        {},
      );
      
      debugPrint('Horario actualizado: $response');
      return Schedule.fromJson(response);
    } catch (e) {
      debugPrint('Error al solicitar horario: $e');
      rethrow;
    }
  }

  // Obtener mis horarios asignados
  Future<List<Schedule>> getMySchedules(String userId) async {
    try {
      final response = await _apiService.get('api/users/$userId/schedules');
      if (response is List) {
        return response.map((json) => Schedule.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching my schedules: $e');
      rethrow;
    }
  }

  // Guardar horarios localmente
  Future<void> saveSchedulesLocally(List<Schedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = schedules.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_schedulesKey, schedulesJson);
  }

  // Cargar horarios guardados localmente
  Future<List<Schedule>> loadLocalSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = prefs.getStringList(_schedulesKey) ?? [];
    return schedulesJson
        .map((json) => Schedule.fromJson(jsonDecode(json)))
        .toList();
  }
}
