import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestor_horarios_app/data/models/schedule_model.dart';
import 'package:gestor_horarios_app/data/services/api_service.dart';

class ScheduleRepository {
  final ApiService _apiService = ApiService();
  final String _schedulesKey = 'saved_schedules';

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

  // Crear un nuevo horario (solo admin)
  Future<Schedule> createSchedule(Schedule schedule) async {
    try {
      final response = await _apiService.post(
        'schedules',
        schedule.toJson(),
      );
      return Schedule.fromJson(response);
    } catch (e) {
      debugPrint('Error creating schedule: $e');
      rethrow;
    }
  }

  // Solicitar un horario disponible
  Future<Schedule> requestSchedule({
    required String scheduleId,
    required String userId,
  }) async {
    try {
      final response = await _apiService.post(
        'schedules/$scheduleId/request',
        {'userId': userId},
      );
      return Schedule.fromJson(response);
    } catch (e) {
      debugPrint('Error requesting schedule: $e');
      rethrow;
    }
  }

  // Obtener mis horarios asignados
  Future<List<Schedule>> getMySchedules(String userId) async {
    try {
      final response = await _apiService.get('users/$userId/schedules');
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
