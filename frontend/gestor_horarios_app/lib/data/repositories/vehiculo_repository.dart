import 'package:gestor_horarios_app/core/constants/api_constants.dart';
import 'package:gestor_horarios_app/core/utils/api_client.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';

class VehiculoRepository {
  final ApiClient _apiClient;
  
  VehiculoRepository(this._apiClient);
  
  Future<List<Vehiculo>> getVehiculosDisponibles() async {
    try {
      final response = await _apiClient.get(ApiConstants.vehiculos);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Vehiculo.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo vehículos disponibles: $e');
      return [];
    }
  }
  
  Future<List<Vehiculo>> getMisVehiculos() async {
    try {
      final response = await _apiClient.get(ApiConstants.misVehiculos);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Vehiculo.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo mis vehículos: $e');
      return [];
    }
  }
  
  Future<Vehiculo?> getVehiculoPorId(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.vehiculos}/$id');
      
      if (response.statusCode == 200) {
        return Vehiculo.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error obteniendo vehículo por ID: $e');
      return null;
    }
  }
  
  Future<Vehiculo?> getVehiculoPorMatricula(String matricula) async {
    try {
      final response = await _apiClient.get('${ApiConstants.vehiculos}/matricula/$matricula');
      
      if (response.statusCode == 200) {
        return Vehiculo.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error obteniendo vehículo por matrícula: $e');
      return null;
    }
  }
  
  Future<Vehiculo?> registrarVehiculo(Vehiculo vehiculo) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.vehiculos,
        data: vehiculo.toJson(),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Vehiculo.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error registrando vehículo: $e');
      return null;
    }
  }
  
  Future<Vehiculo?> actualizarVehiculo(Vehiculo vehiculo) async {
    try {
      if (vehiculo.id == null) return null;
      
      final response = await _apiClient.put(
        '${ApiConstants.vehiculos}/${vehiculo.id}',
        data: vehiculo.toJson(),
      );
      
      if (response.statusCode == 200) {
        return Vehiculo.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error actualizando vehículo: $e');
      return null;
    }
  }
  
  Future<bool> eliminarVehiculo(int id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.vehiculos}/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('Error eliminando vehículo: $e');
      return false;
    }
  }
  
  Future<bool> cambiarEstadoActivo(int id, bool activo) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.vehiculos}/$id/activo/$activo',
        data: {},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error cambiando estado activo: $e');
      return false;
    }
  }
}
