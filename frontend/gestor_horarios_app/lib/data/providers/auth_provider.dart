import 'package:flutter/foundation.dart';
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
  
  // Inicializar el provider verificando si el usuario ya ha iniciado sesión
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final userData = await _authRepository.getCurrentUser();
        if (userData != null) {
          _currentUser = User.fromJson(userData);
        } else {
          // Si hay un problema con los datos del usuario, forzar cierre de sesión
          await _authRepository.logout();
        }
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error al inicializar la autenticación: $e';
      debugPrint(_errorMessage);
      await _authRepository.logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Iniciar sesión con nombre de usuario y contraseña
  Future<Map<String, dynamic>> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _errorMessage = 'Por favor, complete todos los campos';
      notifyListeners();
      return {'success': false, 'isAdmin': false, 'message': _errorMessage};
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _authRepository.login(username, password);
      
      if (response['success'] == true) {
        final userData = await _authRepository.getCurrentUser();
        if (userData != null) {
          _currentUser = User.fromJson(userData);
          _errorMessage = null;
          
          // Verificar si es administrador
          final bool isAdmin = response['isAdmin'] == true;
          
          return {
            'success': true,
            'isAdmin': isAdmin,
            'message': response['message'] ?? 'Inicio de sesión exitoso',
          };
        } else {
          _errorMessage = 'No se pudieron cargar los datos del usuario';
          await _authRepository.logout();
          return {'success': false, 'isAdmin': false, 'message': _errorMessage};
        }
      } else {
        _errorMessage = response['message'] ?? 'Usuario o contraseña incorrectos';
        return {'success': false, 'isAdmin': false, 'message': _errorMessage};
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Por favor, intente nuevamente.';
      debugPrint('Error en login: $e');
      return {'success': false, 'isAdmin': false, 'message': _errorMessage};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Logout the current user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authRepository.logout();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
