import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestor_horarios_app/core/constants/api_constants.dart';

class ApiService {
  // URL base del backend
  static const String baseUrl = ApiConstants.baseUrl;

  // Get headers for API requests
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          debugPrint('Añadido token de autorización a la cabecera');
        } else {
          debugPrint('No se encontró token de autenticación para la solicitud');
        }
      } catch (e) {
        debugPrint('Error al obtener token de autenticación: $e');
      }
    }

    debugPrint('Cabeceras de la solicitud: $headers');
    return headers;
  }

  // Make a GET request with optional query parameters and authentication
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final uri = Uri.parse('$baseUrl/$endpoint').replace(
        queryParameters: queryParams,
      );
      
      debugPrint('GET: $uri');
      
      // If auth is required but no token is available, throw an exception
      if (requiresAuth && !headers.containsKey('Authorization')) {
        throw Exception('Authentication required');
      }
      
      final response = await http.get(
        uri,
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error en GET $endpoint: $e');
      rethrow;
    }
  }

  // Make a POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data, {bool requiresAuth = true}) async {
    try {
      debugPrint('Iniciando POST a $baseUrl/$endpoint');
      debugPrint('Datos: ${jsonEncode(data)}');
      
      final headers = await _getHeaders();
      
      // If auth is required but no token is available, throw an exception
      if (requiresAuth && !headers.containsKey('Authorization')) {
        throw Exception('Authentication required');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('Timeout en petición POST a $endpoint');
          throw Exception('Tiempo de espera agotado. Verifica la conexión con el servidor.');
        },
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error en POST $endpoint: $e');
      rethrow;
    }
  }

  // Make a PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error en PUT $endpoint: $e');
      rethrow;
    }
  }

  // Make a DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error en DELETE $endpoint: $e');
      rethrow;
    }
  }

  // Método para manejar la respuesta HTTP
  dynamic _handleResponse(http.Response response) {
    debugPrint('Respuesta HTTP: ${response.statusCode} - ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      String errorMessage;
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorData['error'] ?? 'Error desconocido';
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : 'Error ${response.statusCode}';
      }
      throw Exception('Error HTTP ${response.statusCode}: $errorMessage');
    }
  }

  // Método para el registro de usuarios
  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      // Asegurarse de que el email está incluido (es requerido en el backend)
      if (!userData.containsKey('email') && userData.containsKey('username')) {
        userData['email'] = '${userData['username']}@gestor-horarios.com';
      }
      
      // Corregir el nombre del campo de roles para que coincida con el backend
      if (userData.containsKey('roles')) {
        userData['roleNames'] = userData['roles'];
        userData.remove('roles');
      }
      
      // Depuración para ver qué se está enviando
      debugPrint('Datos de registro modificados: ${jsonEncode(userData)}');
      
      // Usar el endpoint de prueba simplificado para diagnóstico
      debugPrint('Intentando registro con endpoint simplificado');
      final response = await post('test/registro-simple', userData);
      debugPrint('Respuesta del endpoint simplificado: $response');
      
      return true;
    } catch (e) {
      debugPrint('Error en registro: $e');
      rethrow;
    }
  }
  
  // Método alternativo para probar el registro simplificado directamente
  Future<Map<String, dynamic>> registroSimplificado(Map<String, dynamic> userData) async {
    try {
      debugPrint('Intentando registro simplificado con: ${jsonEncode(userData)}');
      final response = await post('test/registro-simple', userData);
      debugPrint('Respuesta del registro simplificado: $response');
      return response;
    } catch (e) {
      debugPrint('Error en registro simplificado: $e');
      rethrow;
    }
  }
}
