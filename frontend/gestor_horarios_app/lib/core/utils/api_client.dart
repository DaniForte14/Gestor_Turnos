import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestor_horarios_app/core/constants/api_constants.dart';

class ApiClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  ApiClient() {
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Añadir token de autenticación si existe
          final token = await _secureStorage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
        onError: (DioError error, handler) async {
          if (error.response?.statusCode == 401) {
            // Intentar refrescar el token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Reintentar la petición original
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
  
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return false;
      
      final response = await _dio.post(
        ApiConstants.baseUrl + ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final newToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];
        
        await _secureStorage.write(key: 'access_token', value: newToken);
        await _secureStorage.write(key: 'refresh_token', value: newRefreshToken);
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Métodos para realizar peticiones HTTP
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    return await _dio.get(
      ApiConstants.baseUrl + endpoint,
      queryParameters: queryParams,
    );
  }
  
  Future<Response> post(String endpoint, {dynamic data}) async {
    return await _dio.post(
      ApiConstants.baseUrl + endpoint,
      data: data,
    );
  }
  
  Future<Response> put(String endpoint, {dynamic data}) async {
    return await _dio.put(
      ApiConstants.baseUrl + endpoint,
      data: data,
    );
  }
  
  Future<Response> delete(String endpoint) async {
    return await _dio.delete(
      ApiConstants.baseUrl + endpoint,
    );
  }
}
