import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:gestor_horarios_app/data/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  
  // Método de login mejorado con manejo de roles
  // Método auxiliar para obtener los roles de un usuario
  Future<List<String>> _fetchUserRoles(int userId) async {
    try {
      debugPrint('Obteniendo roles para el usuario ID: $userId');
      
      // Obtener el perfil del usuario actual primero
      try {
        final response = await _apiService.get(
          'api/users/$userId',
          requiresAuth: true,
        );
        
        debugPrint('Respuesta del perfil del usuario: $response');
        
        if (response != null && response is Map) {
          // Intentar obtener roles de diferentes formatos de respuesta
          if (response['roles'] != null && response['roles'] is List) {
            final roles = (response['roles'] as List).map((r) => r.toString()).toList();
            if (roles.isNotEmpty) {
              debugPrint('Roles obtenidos del perfil: $roles');
              return roles;
            }
          }
          
          // Verificar si hay un campo 'role' individual
          if (response['role'] != null) {
            final role = response['role'].toString();
            debugPrint('Rol obtenido: $role');
            return [role];
          }
        }
      } catch (e) {
        debugPrint('Error al obtener perfil del usuario: $e');
      }
      
      // Si no se pudo obtener del perfil, intentar con el endpoint de roles
      try {
        final response = await _apiService.get(
          'api/users/$userId/roles',
          requiresAuth: true,
        );
        
        debugPrint('Respuesta de roles: $response');
        
        if (response != null) {
          if (response is List) {
            final roles = response.map((r) => r.toString()).toList();
            if (roles.isNotEmpty) {
              debugPrint('Roles obtenidos: $roles');
              return roles;
            }
          } else if (response is Map && response['roles'] is List) {
            final roles = (response['roles'] as List).map((r) => r.toString()).toList();
            if (roles.isNotEmpty) {
              debugPrint('Roles obtenidos del mapa: $roles');
              return roles;
            }
          }
        }
      } catch (e) {
        debugPrint('Error al obtener roles: $e');
      }
      
      debugPrint('No se encontraron roles para el usuario ID: $userId');
      return [];
    } catch (e) {
      debugPrint('Error al obtener roles del usuario: $e');
      return [];
    }
  }

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
        
        // Guardar el token JWT si está presente
        if (response['token'] != null) {
          final token = response['token'];
          await prefs.setString('auth_token', token);
          // Guardar también en SecureStorage para el ApiClient
          final secureStorage = FlutterSecureStorage();
          await secureStorage.write(key: 'access_token', value: token);
          debugPrint('Token JWT guardado correctamente en ambos almacenamientos');
        }
        
        // Obtener el ID del usuario de la respuesta
        final userId = response['userId'];
        
        // Obtener roles de la respuesta del servidor
        List<String> roles = [];
        
        // Verificar si hay roles en la respuesta
        if (response['roles'] != null && response['roles'] is List) {
          roles = (response['roles'] as List<dynamic>)
              .map((role) => role.toString())
              .where((role) => role.isNotEmpty)
              .toList();
        }
        
        // Si no hay roles en la respuesta, intentar obtenerlos de la API
        if (roles.isEmpty && userId != null) {
          debugPrint('No hay roles en la respuesta, buscando en la API...');
          final apiRoles = await _fetchUserRoles(userId);
          if (apiRoles.isNotEmpty) {
            roles = apiRoles;
            debugPrint('Roles obtenidos de la API: $roles');
          }
        }
        
        debugPrint('Roles finales del usuario: $roles');
        
        // Verificar si es administrador basado en los roles o en el flag isAdmin
        bool isAdmin = response['isAdmin'] == true;
        
        // Si no se determinó que es admin por el flag, verificar en los roles
        if (!isAdmin && roles.isNotEmpty) {
          isAdmin = roles.any((role) => 
              role.toUpperCase().contains('ADMIN') || 
              role.toUpperCase() == 'ROLE_ADMIN' || 
              role.toUpperCase() == 'ADMINISTRADOR');
        }
        
        await prefs.setBool('isAdmin', isAdmin);
        debugPrint('Usuario es administrador: $isAdmin');
        
        // Para el usuario admin, usar valores por defecto si no están en la respuesta
        final username = response['username'] ?? 'admin';
        
        // Guardar datos del usuario
        final userData = {
          'id': response['userId'] ?? 1, // Usar ID 1 para admin si no está presente
          'username': username,
          'email': response['email'] ?? '$username@example.com',
          'nombre': response['nombre'] ?? username,
          'apellidos': response['apellidos'] ?? '',
          'roles': roles,
          'isAdmin': isAdmin,
        };
        
        await prefs.setString('user_data', jsonEncode(userData));
        
        // Devolver información adicional sobre el login, incluyendo los roles
        final loginResponse = {
          'success': true,
          'isAdmin': isAdmin,
          'userId': response['userId'],
          'username': response['username'],
          'email': response['email'],
          'nombre': response['nombre'],
          'apellidos': response['apellidos'],
          'roles': roles, // Asegurarse de incluir los roles en la respuesta
          'message': response['message'] ?? 'Inicio de sesión exitoso',
        };
        
        debugPrint('Respuesta de login que se envía al proveedor: $loginResponse');
        return loginResponse;
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
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      
      // Si no está marcado como logueado, no hay necesidad de verificar más
      if (!isLoggedIn) {
        debugPrint('No hay sesión activa (isLoggedIn = false)');
        return false;
      }
      
      // Verificar si hay datos de usuario
      final userData = prefs.getString('user_data');
      if (userData == null || userData.isEmpty) {
        debugPrint('No hay datos de usuario en SharedPreferences');
        await logout();
        return false;
      }
      
      // Verificar que los datos del usuario sean válidos
      try {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        if (userMap['username'] == null) {
          debugPrint('Datos de usuario inválidos: falta el nombre de usuario');
          await logout();
          return false;
        }
        
        debugPrint('Usuario autenticado: ${userMap['username']}');
        return true;
      } catch (e) {
        debugPrint('Error al decodificar datos de usuario: $e');
        await logout();
        return false;
      }
    } catch (e) {
      debugPrint('Error verificando estado de sesión: $e');
      await logout();
      return false;
    }
  }
  
  // Verificar si el usuario es administrador
  Future<bool> isAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      
      if (userData == null) return false;
      
      try {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        
        // Verificar roles del usuario
        if (userMap['roles'] != null && userMap['roles'] is List) {
          final roles = (userMap['roles'] as List<dynamic>)
              .map((r) => r.toString().toUpperCase())
              .toList();
              
          debugPrint('Roles del usuario en isAdmin(): $roles');
          return roles.any((r) => r == 'ROLE_ADMIN');
        }
        
        // Para compatibilidad con versiones anteriores
        return userMap['isAdmin'] == true || 
               userMap['role']?.toString().toUpperCase() == 'ROLE_ADMIN';
      } catch (e) {
        debugPrint('Error al decodificar datos de usuario en isAdmin(): $e');
        return false;
      }
    } catch (e) {
      debugPrint('Error verificando rol de administrador: $e');
      return false;
    }
  }
  
  // Cerrar sesión
  Future<void> logout() async {
    try {
      debugPrint('Iniciando cierre de sesión...');
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar el estado de debug para no perderlo
      final bool? debugMode = prefs.getBool('debug_mode');
      
      // Limpiar todo el almacenamiento
      await prefs.clear();
      
      // Restaurar el modo debug si existía
      if (debugMode != null) {
        await prefs.setBool('debug_mode', debugMode);
      }
      
      // Forzar la sincronización
      await prefs.reload();
      
      debugPrint('Sesión cerrada correctamente');
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
      // Asegurarse de limpiar las preferencias incluso si hay un error
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await prefs.reload();
      } catch (e2) {
        debugPrint('Error al limpiar preferencias: $e2');
      }
      rethrow;
    }
  }
  
  // Verificar si el token JWT es válido
  Future<bool> isTokenValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        debugPrint('No se encontró token de autenticación');
        return false;
      }
      
      // Opcional: Verificar si el token está próximo a expirar
      // Esto requiere decodificar el JWT y verificar la fecha de expiración
      // Por ahora, simplemente verificamos que el token existe
      
      debugPrint('Token JWT válido encontrado');
      return true;
    } catch (e) {
      debugPrint('Error al validar token: $e');
      return false;
    }
  }
  
  // Obtener información del usuario actual
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      
      if (userData == null || userData.isEmpty) {
        debugPrint('No se encontraron datos de usuario en SharedPreferences');
        return null;
      }
      
      try {
        final Map<String, dynamic> userMap = jsonDecode(userData);
        debugPrint('=== DATOS DEL USUARIO DESDE SHARED PREFERENCES ===');
        debugPrint('Datos del usuario obtenidos: ${userMap['username'] ?? 'sin nombre de usuario'}');
        
        // Verificar que los datos mínimos requeridos estén presentes
        if (userMap['username'] == null) {
          debugPrint('Datos de usuario incompletos o inválidos');
          await logout(); // Forzar cierre de sesión si los datos son inválidos
          return null;
        }
        
        // Asegurarse de que los campos requeridos tengan valores por defecto
        userMap['id'] = userMap['id'] ?? 1; // ID por defecto para admin
        
        // Manejar los roles
        List<String> roles = [];
        
        // Obtener roles de userMap['roles'] si existe
        if (userMap['roles'] != null && userMap['roles'] is List) {
          roles = (userMap['roles'] as List<dynamic>)
              .map((role) => role.toString().toUpperCase())
              .where((role) => role.isNotEmpty)
              .toList();
        }
        
        // Si no hay roles, verificar isAdmin
        if (roles.isEmpty) {
          final isAdmin = userMap['isAdmin'] == true;
          roles = isAdmin 
              ? ['ROLE_ADMIN', 'ADMIN', 'ADMINISTRADOR'] 
              : ['ROLE_USER'];
        }
        
        // Actualizar los roles en el mapa
        userMap['roles'] = roles;
        
        // Actualizar el estado de isAdmin basado en los roles
        final bool isAdmin = roles.any((role) {
          final roleUpper = role.toString().toUpperCase();
          return roleUpper == 'ROLE_ADMIN' || 
                 roleUpper == 'ADMIN' || 
                 roleUpper == 'ADMINISTRADOR' ||
                 roleUpper.contains('ADMIN');
        });
        
        userMap['isAdmin'] = isAdmin;
        
        debugPrint('=== ROLES PROCESADOS ===');
        debugPrint('Roles finales: $roles');
        debugPrint('Es administrador: $isAdmin');
        debugPrint('Datos completos del usuario: $userMap');
        
        return userMap;
      } catch (e) {
        debugPrint('Error al decodificar datos del usuario: $e');
        await logout(); // Forzar cierre de sesión si hay un error en los datos
        return null;
      }
    } catch (e) {
      debugPrint('Error al obtener usuario actual: $e');
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
