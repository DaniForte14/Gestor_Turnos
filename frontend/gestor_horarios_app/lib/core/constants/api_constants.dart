class ApiConstants {
  // Base URL de la API
  static const String baseUrl = 'http://192.168.1.40:8080';
  
  // Endpoints de autenticación
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refreshToken = '/api/auth/refresh';
  
  // Endpoints de usuarios
  static const String users = '/api/users';
  static const String userProfile = '/api/users/profile';
  
  // Endpoints de horarios
  static const String horarios = '/api/horarios';
  static const String horariosByUser = '/api/horarios/mis-horarios';
  static const String horariosByDate = '/api/horarios/fecha';
  static const String horariosDisponibles = '/api/horarios/disponibles';
  static const String horariosDisponiblesPorRol = '/api/horarios/disponibles/rol';
  
  // Endpoints de solicitudes de cambio
  static const String solicitudes = '/solicitudes';
  static const String misSolicitudes = '/solicitudes/mis-solicitudes';
  static const String solicitudResponder = '/solicitudes/responder';
  static const String solicitudCancelar = '/solicitudes/cancelar';
  
  // Endpoints de vehículos
  static const String vehicles = '/api/vehicles';
  static const String myVehicles = '/api/vehicles/my-vehicles'; // Endpoint for getting user's vehicles
  
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
