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
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.horarios}/disponibles',
        queryParams: {
          'fecha': fecha.toIso8601String().split('T')[0],
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Horario.fromJson(item)).toList();
      }
      return [];
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
