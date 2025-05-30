import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:gestor_horarios_app/data/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  
  // Método de login simplificado
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        'api/auth/signin',
        {
          'usernameOrEmail': username,
          'password': password,
        },
        requiresAuth: false,
      );
      
      if (response['success'] == true) {
        // Guardar estado de sesión
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        
        // Verificar si es administrador
        final bool isAdmin = response['isAdmin'] == true;
        await prefs.setBool('isAdmin', isAdmin);
        
        // Guardar datos del usuario
        final userData = {
          'id': response['userId'],
          'username': response['username'],
          'email': response['email'],
          'nombre': response['nombre'] ?? '',
          'apellidos': response['apellidos'] ?? '',
          'isAdmin': isAdmin,
        };
        
        await prefs.setString('user_data', jsonEncode(userData));
        
        // Devolver información adicional sobre el login
        return {
          'success': true,
          'isAdmin': isAdmin,
          'message': response['message'] ?? 'Inicio de sesión exitoso',
        };
      } else {
        debugPrint('Error en login: ${response['message'] ?? 'Credenciales inválidas'}');
        return {
          'success': false,
          'message': response['message'] ?? 'Credenciales inválidas',
        };
      }
    } catch (e) {
      debugPrint('Error en login: $e');
      return {
        'success': false,
        'isAdmin': false,
        'message': 'Error de conexión. Por favor, intente nuevamente.',
      };
    }
  }
  
  // Método de registro simplificado
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post(
        'api/auth/signup',
        {
          'username': userData['username'],
          'email': userData['email'],
          'password': userData['password'],
          'nombre': userData['nombre'] ?? '',
          'apellidos': userData['apellidos'] ?? '',
          'centroTrabajo': userData['centroTrabajo'] ?? 'Por definir',
          'localidad': userData['localidad'] ?? 'Por definir',
          'telefono': userData['telefono'] ?? '',
          'roleNames': [userData['role']?.toString() ?? 'ROLE_USER'],
        },
        requiresAuth: false,
      );

      if (response['success'] == true) {
        // Iniciar sesión automáticamente después del registro
        final loginResponse = await login(
          userData['username'],
          userData['password'],
        );
        
        return {
          'success': true,
          'isAdmin': loginResponse['isAdmin'] ?? false,
          'message': 'Registro exitoso. Iniciando sesión...',
        };
      } else {
        final errorMessage = response['message'] ?? 'Error en el registro';
        debugPrint('Error en registro: $errorMessage');
        return {
          'success': false,
          'isAdmin': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      debugPrint('Error en registro: $e');
      return {
        'success': false,
        'isAdmin': false,
        'message': 'Error de conexión. Por favor, intente nuevamente.',
      };
    }
  }
  
  // Verificar si el usuario está autenticado
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false;
    } catch (e) {
      debugPrint('Error verificando estado de sesión: $e');
      return false;
    }
  }
  
  // Verificar si el usuario es administrador
  Future<bool> isAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isAdmin') ?? false;
    } catch (e) {
      debugPrint('Error verificando rol de administrador: $e');
      return false;
    }
  }
  
  // Cerrar sesión
  Future<void> logout() async {
    try {
      // Eliminar preferencias de usuario
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('user_data');
      await prefs.remove('auth_token');
      
      debugPrint('Sesión cerrada correctamente');
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
      // Asegurarse de limpiar las preferencias incluso si hay un error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('user_data');
      await prefs.remove('auth_token');
      rethrow;
    }
  }
  
  // Obtener información del usuario actual
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      
      if (userData != null) {
        return jsonDecode(userData);
      }
      return null;
    } catch (e) {
      debugPrint('Error obteniendo usuario actual: $e');
      return null;
    }
  }
  
  /// Updates the user profile information
  /// Returns true if the update was successful, false otherwise
  Future<bool> updateProfile(int userId, Map<String, dynamic> userData) async {
    try {
      // Validate required fields
      if (userId <= 0) {
        throw Exception('ID de usuario no válido');
      }
      
      if (userData.isEmpty) {
        throw Exception('No se proporcionaron datos para actualizar');
      }
      
      // Make the API call to update the profile
      final response = await _apiService.put(
        'api/users/$userId',
        userData,
      );
      
      if (response['success'] == true) {
        // Update local storage with new user data
        final prefs = await SharedPreferences.getInstance();
        final currentUser = await getCurrentUser();
        
        if (currentUser != null) {
          // Create a new map to avoid modifying the original
          final updatedUser = Map<String, dynamic>.from(currentUser);
          updatedUser.addAll({
            'email': userData['email'] ?? currentUser['email'],
            'nombre': userData['nombre'] ?? currentUser['nombre'],
            'apellidos': userData['apellidos'] ?? currentUser['apellidos'],
            'updatedAt': DateTime.now().toIso8601String(),
          });
          
          // Save the updated user data
          await prefs.setString('user_data', jsonEncode(updatedUser));
          debugPrint('Perfil actualizado correctamente');
          return true;
        }
      } else {
        debugPrint('Error en la respuesta del servidor: ${response['message']}');
      }
      
      return false;
    } catch (e) {
      debugPrint('Error al actualizar el perfil: $e');
      rethrow; // Re-throw to allow proper error handling in the provider
    }
  }
  
  // Obtener ID del usuario actual
  Future<int?> getCurrentUserId() async {
    try {
      final userData = await getCurrentUser();
      return userData?['id'];
    } catch (e) {
      debugPrint('Error obteniendo ID del usuario: $e');
      return null;
    }
  }
}
