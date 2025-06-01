import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestor_horarios_app/data/models/user.dart';
import 'package:gestor_horarios_app/data/repositories/auth_repository.dart';

/// Provider para gestionar el estado de autenticación en la aplicación
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;
  
  // Inicializar el proveedor de autenticación
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    _currentUser = null;
    notifyListeners();
    
    try {
      // Forzar cierre de sesión al iniciar la aplicación
      debugPrint('=== INICIALIZANDO APLICACIÓN ===');
      debugPrint('Forzando cierre de sesión al iniciar...');
      await _authRepository.logout();
      
      // Verificar si hay un token válido (debería ser falso después del logout)
      final isTokenValid = await _authRepository.isTokenValid();
      debugPrint('Token válido después de logout: $isTokenValid');
      
      if (isTokenValid) {
        debugPrint('Error: El token sigue siendo válido después del logout');
        await _authRepository.logout(); // Forzar nuevamente por si acaso
      }
      
      // Limpiar cualquier dato de usuario
      _currentUser = null;
      _errorMessage = null;
      
      debugPrint('=== SESIÓN CERRADA CORRECTAMENTE AL INICIAR ===');
      debugPrint('Estado actual - Autenticado: ${_currentUser != null}');
      debugPrint('Token válido: $isTokenValid');
      
    } catch (e) {
      _errorMessage = 'Error al inicializar la autenticación';
      debugPrint('Error en initialize: $e');
      
      // Asegurarse de que el estado sea consistente
      try {
        await _authRepository.logout();
      } catch (e2) {
        debugPrint('Error al forzar cierre de sesión: $e2');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('=== INICIALIZACIÓN COMPLETADA ===');
      debugPrint('Usuario autenticado: ${_currentUser != null}');
      if (_currentUser != null) {
        debugPrint('Roles del usuario actual: ${_currentUser!.roles}');
      }
    }
  }
  
  // Iniciar sesión con nombre de usuario y contraseña
  Future<Map<String, dynamic>> login(String username, String password) async {
    debugPrint('=== INICIO DE SESIÓN ===');
    debugPrint('Usuario: $username');
    debugPrint('Iniciando proceso de login...');
    
    if (username.isEmpty || password.isEmpty) {
      _errorMessage = 'Por favor, complete todos los campos';
      debugPrint(_errorMessage);
      notifyListeners();
      return {'success': false, 'isAdmin': false, 'message': _errorMessage};
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // 1. Llamar al repositorio para iniciar sesión
      final response = await _authRepository.login(username, password);
      debugPrint('=== RESPUESTA DEL SERVIDOR ===');
      debugPrint('Respuesta completa: ${response.toString()}');
      
      if (response['success'] == true) {
        // 2. Obtener los datos del usuario después del inicio de sesión exitoso
        final userData = await _authRepository.getCurrentUser();
        debugPrint('=== DATOS DEL USUARIO ===');
        debugPrint('Datos del usuario obtenidos: ${userData?.toString() ?? 'nulos'}');
        
        if (userData == null) {
          debugPrint('ERROR: No se pudieron obtener los datos del usuario');
          throw Exception('No se pudieron obtener los datos del usuario');
        }
        
        // 3. Obtener los roles del usuario
        List<String> userRoles = [];
        
        // Primero intentar obtener los roles de la respuesta del login
        if (response['roles'] != null && response['roles'] is List) {
          userRoles = (response['roles'] as List<dynamic>)
              .map((role) => role.toString().toUpperCase())
              .where((role) => role.isNotEmpty)
              .toList();
          debugPrint('Roles de la respuesta del login: $userRoles');
        } 
        // Si no hay roles en la respuesta, intentar obtenerlos de userData
        if (userRoles.isEmpty && userData['roles'] != null && userData['roles'] is List) {
          userRoles = (userData['roles'] as List<dynamic>)
              .map((role) => role.toString().toUpperCase())
              .where((role) => role.isNotEmpty)
              .toList();
          debugPrint('Roles de userData: $userRoles');
        }
        
        // Si no hay roles, asignar ROLE_USER por defecto
        if (userRoles.isEmpty) {
          userRoles = ['ROLE_USER'];
          debugPrint('No se encontraron roles, usando valor por defecto: $userRoles');
        }
            
        debugPrint('=== ROLES PROCESADOS ===');
        debugPrint('Roles finales del usuario: $userRoles');
        debugPrint('Número de roles: ${userRoles.length}');
        debugPrint('Contiene ADMIN: ${userRoles.any((role) => role.contains('ADMIN'))}');
        debugPrint('Contiene ROLE_ADMIN: ${userRoles.any((role) => role == 'ROLE_ADMIN')}');
        debugPrint('Contiene ADMINISTRADOR: ${userRoles.any((role) => role == 'ADMINISTRADOR')}');
        
        // 4. Verificar si es administrador (solo usuario 'admin')
        final bool isAdmin = userData['username'] == 'admin';
        
        debugPrint('=== VERIFICACIÓN DE ADMINISTRADOR ===');
        debugPrint('Solo el usuario "admin" es considerado administrador');
        debugPrint('Usuario actual: ${userData['username']}');
        debugPrint('Es administrador: $isAdmin');
            
        debugPrint('=== VERIFICACIÓN DE ADMINISTRADOR ===');
        debugPrint('Usuario es administrador: $isAdmin');
        
        // 5. Actualizar el usuario actual en el proveedor con los roles correctos
        _currentUser = User.fromJson(userData).copyWith(
          roles: userRoles,
        );
        
        debugPrint('Roles finales del usuario: ${_currentUser?.roles}');
        debugPrint('=== FIN DEL PROCESO DE LOGIN ===');
        
        _errorMessage = null;
        
        // 6. Notificar a los oyentes del cambio
        notifyListeners();
        debugPrint('Login exitoso para el usuario: ${_currentUser?.username}');
        
        // 7. Guardar los datos del usuario en SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode({
            ...userData,
            'roles': userRoles,
            'isAdmin': isAdmin,
          }));
          debugPrint('Datos del usuario guardados en SharedPreferences');
        } catch (e) {
          debugPrint('Error al guardar los datos del usuario: $e');
        }
        
        // 8. Retornar la respuesta con la información del usuario
        return {
          'success': true,
          'isAdmin': isAdmin,
          'userId': userData['id'],
          'username': userData['username'],
          'email': userData['email'],
          'nombre': userData['nombre'],
          'apellidos': userData['apellidos'],
          'roles': userRoles,
          'message': 'Inicio de sesión exitoso',
        };
      } else {
        _errorMessage = response['message'] ?? 'Usuario o contraseña incorrectos';
        debugPrint('Error en el login: $_errorMessage');
        await _authRepository.logout(); // Asegurarse de limpiar cualquier estado
        notifyListeners();
        return {'success': false, 'isAdmin': false, 'message': _errorMessage};
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Por favor, intente nuevamente.';
      debugPrint('Error en login: $e');
      await _authRepository.logout(); // Asegurarse de limpiar cualquier estado
      notifyListeners();
      return {'success': false, 'isAdmin': false, 'message': _errorMessage};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Logout the current user
  Future<void> logout() async {
    debugPrint('=== INICIANDO CIERRE DE SESIÓN ===');
    _isLoading = true;
    _errorMessage = null;
    _currentUser = null; // Limpiar el usuario actual de inmediato
    notifyListeners();
    
    try {
      // Forzar la limpieza de la caché
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await prefs.reload();
      
      // Llamar al logout del repositorio
      await _authRepository.logout();
      
      debugPrint('=== SESIÓN CERRADA CORRECTAMENTE ===');
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión';
      debugPrint('Error en logout: $e');
      
      // Forzar limpieza incluso si hay error
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await prefs.reload();
      } catch (e2) {
        debugPrint('Error al limpiar preferencias: $e2');
      }
    } finally {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      debugPrint('=== ESTADO FINAL ===');
      debugPrint('Usuario actual: ${_currentUser?.username ?? "null"}');
      debugPrint('Autenticado: ${isAuthenticated}');
    }
  }
  
  // Verificar si el usuario es administrador
  bool get isAdmin {
    if (_currentUser == null) {
      debugPrint('isAdmin: No hay usuario actual');
      return false;
    }
    
    final isAdmin = _currentUser!.roles.any((role) => role.toUpperCase() == 'ROLE_ADMIN');
    debugPrint('isAdmin: ${_currentUser!.username} - Roles: ${_currentUser!.roles} - Es admin: $isAdmin');
    return isAdmin;
  }
  
  // Update the current user profile
  Future<bool> updateProfile({
    required int userId,
    required String email,
    required String nombre,
    required String apellidos,
  }) async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final userData = {
        'email': email,
        'nombre': nombre,
        'apellidos': apellidos,
      };
      
      final success = await _authRepository.updateProfile(userId, userData);
      
      if (success) {
        // Update the local user data
        _currentUser = _currentUser!.copyWith(
          email: email,
          nombre: nombre,
          apellidos: apellidos,
        );
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = 'Error al actualizar el perfil';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Clear any error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String nombre,
    required String apellidos,
    required String telefono,
    required String rol,
    required String localidad,
    required String centroTrabajo,
    required String password,
    String? email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Asegurarse de que el email no sea nulo
      final userEmail = email ?? '$username@example.com';
      
      debugPrint('Datos de registro antes de enviar: ${{
        'username': username,
        'email': userEmail,
        'nombre': nombre,
        'apellidos': apellidos,
        'telefono': telefono,
        'rol': rol,
        'localidad': localidad,
        'centroTrabajo': centroTrabajo,
        'password': '******', // No mostrar la contraseña en los logs
      }}');
      
      final userData = {
        'username': username,
        'email': userEmail,
        'nombre': nombre,
        'apellidos': apellidos,
        'telefono': telefono,
        'role': rol,  // El rol ya viene con el prefijo 'ROLE_' desde la pantalla
        'localidad': localidad,
        'centroTrabajo': centroTrabajo,
        'password': password,
      };
      
      final response = await _authRepository.register(userData);
      
      if (response['success'] == true) {
        // Actualizar el usuario actual si el registro fue exitoso
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          _currentUser = User.fromJson(user);
        }
      } else {
        _errorMessage = response['message'] ?? 'Error al registrar el usuario';
      }
      
      return response;
    } catch (e) {
      final errorMessage = 'Error de registro: $e';
      _errorMessage = errorMessage;
      debugPrint(errorMessage);
      return {
        'success': false,
        'isAdmin': false,
        'message': errorMessage,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
