import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestor_horarios_app/core/constants/api_constants.dart';

class VehiculoRepository {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> crearVehiculo(Map<String, dynamic> vehiculo) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/vehicles');
    
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(vehiculo),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al crear el vehículo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerVehiculos() async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/vehicles');
    
    try {
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener los vehículos: ${response.body}');
      }
    } catch (e) {
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
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}/api/vehicles/$vehiculoId/join');
    
    try {
      final response = await http.post(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Error al unirse al vehículo: ${response.body}');
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
}