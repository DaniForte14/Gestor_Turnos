class ApiConstants {
  // Base URL de la API
  static const String baseUrl = 'http://192.168.1.40:8080';
  
  // Endpoints de autenticación
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  
  // Endpoints de usuarios
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  
  // Endpoints de horarios
  static const String horarios = '/horarios';
  static const String horariosByUser = '/horarios/mis-horarios';
  static const String horariosByDate = '/horarios/fecha';
  
  // Endpoints de solicitudes de cambio
  static const String solicitudes = '/solicitudes';
  static const String misSolicitudes = '/solicitudes/mis-solicitudes';
  static const String solicitudResponder = '/solicitudes/responder';
  static const String solicitudCancelar = '/solicitudes/cancelar';
  
  // Endpoints de vehículos
  static const String vehiculos = '/vehiculos';
  static const String misVehiculos = '/vehiculos/mis-vehiculos';
  
  // HTTP Status codes
  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int internalServerError = 500;
}
