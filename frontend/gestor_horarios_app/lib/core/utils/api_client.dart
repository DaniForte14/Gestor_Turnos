import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestor_horarios_app/core/constants/api_constants.dart';

// Helper function to print debug messages
void _debugPrint(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

class ApiClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Public getter for the Dio instance
  Dio get dio => _dio;
  
  ApiClient() {
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // Ensure content type is set first
            options.headers['Content-Type'] = 'application/json';
            options.headers['Accept'] = 'application/json';
            
            // Add authentication token if exists
            final token = await _secureStorage.read(key: 'access_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            } else {
              _debugPrint('No access token found in secure storage');
            }
            
            // Log request details (after setting all headers)
            _debugPrint('\n--- API Request ---');
            _debugPrint('${options.method}: ${options.uri}');
            if (options.queryParameters.isNotEmpty) {
              _debugPrint('Query Params: ${options.queryParameters}');
            }
            if (options.data != null) {
              _debugPrint('Request Data: ${options.data}');
            }
            if (options.headers['Authorization'] != null) {
              final authHeader = options.headers['Authorization'] as String;
              _debugPrint('Auth Token: ${authHeader.substring(0, authHeader.length > 20 ? 20 : authHeader.length)}...');
            } else {
              _debugPrint('No Auth Token in headers');
            }
            _debugPrint('Headers: ${options.headers}');
            _debugPrint('-------------------\n');
            
            return handler.next(options);
          } catch (e) {
            _debugPrint('Error in request interceptor: $e');
            return handler.next(options);
          }
        },
        onError: (DioException error, handler) async {
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
  Future<Response> _makeRequest(
    String method,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      // Ensure the endpoint doesn't have double slashes
      final cleanEndpoint = endpoint.startsWith('/') 
          ? endpoint.substring(1) 
          : endpoint;
      
      // Ensure baseUrl doesn't end with a slash
      final cleanBaseUrl = ApiConstants.baseUrl.endsWith('/')
          ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
          : ApiConstants.baseUrl;
          
      final url = '$cleanBaseUrl/$cleanEndpoint';
      
      _debugPrint('\n--- API Request ---');
      _debugPrint('$method: $url');
      if (queryParams != null && queryParams.isNotEmpty) {
        _debugPrint('Query parameters: $queryParams');
      }
      if (data != null) {
        _debugPrint('Request data: $data');
      }
      
      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      final Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(
            url,
            queryParameters: queryParams,
            options: options,
          );
          break;
        case 'POST':
          response = await _dio.post(
            url,
            data: data,
            queryParameters: queryParams,
            options: options,
          );
          break;
        case 'PUT':
          response = await _dio.put(
            url,
            data: data,
            queryParameters: queryParams,
            options: options,
          );
          break;
        case 'DELETE':
          response = await _dio.delete(
            url,
            data: data,
            queryParameters: queryParams,
            options: options,
          );
          break;
        default:
          throw UnsupportedError('HTTP method $method is not supported');
      }
      
      _debugPrint('Response status: ${response.statusCode}');
      _debugPrint('Response data: ${response.data}');
      _debugPrint('-------------------\n');
      
      return response;
    } on DioException catch (e) {
      _debugPrint('Error en la petición $method: ${e.message}');
      if (e.response != null) {
        _debugPrint('Error response status: ${e.response?.statusCode}');
        _debugPrint('Error response data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      _debugPrint('Error inesperado en la petición $method: $e');
      rethrow;
    }
  }
  
  // HTTP Methods
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    return _makeRequest('GET', endpoint, queryParams: queryParams);
  }
  
  Future<Response> post(String endpoint, {dynamic data, Map<String, dynamic>? queryParams}) async {
    return _makeRequest('POST', endpoint, data: data, queryParams: queryParams);
  }
  
  Future<Response> put(String endpoint, {dynamic data, Map<String, dynamic>? queryParams}) async {
    return _makeRequest('PUT', endpoint, data: data, queryParams: queryParams);
  }
  
  Future<Response> delete(String endpoint, {dynamic data, Map<String, dynamic>? queryParams}) async {
    return _makeRequest('DELETE', endpoint, data: data, queryParams: queryParams);
  }
}
