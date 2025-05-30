import 'package:gestor_horarios_app/core/constants/api_constants.dart';
import 'package:gestor_horarios_app/core/utils/api_client.dart';
import 'package:gestor_horarios_app/data/models/solicitud_cambio.dart';

class SolicitudCambioRepository {
  final ApiClient _apiClient;
  
  SolicitudCambioRepository(this._apiClient);
  
  Future<List<SolicitudCambio>> getMisSolicitudes() async {
    try {
      final response = await _apiClient.get(ApiConstants.misSolicitudes);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => SolicitudCambio.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo mis solicitudes: $e');
      return [];
    }
  }
  
  Future<List<SolicitudCambio>> getSolicitudesRecibidas() async {
    try {
      final response = await _apiClient.get('${ApiConstants.solicitudes}/recibidas');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => SolicitudCambio.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo solicitudes recibidas: $e');
      return [];
    }
  }
  
  Future<SolicitudCambio?> getSolicitudPorId(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.solicitudes}/$id');
      
      if (response.statusCode == 200) {
        return SolicitudCambio.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error obteniendo solicitud por ID: $e');
      return null;
    }
  }
  
  Future<SolicitudCambio?> crearSolicitud(SolicitudCambio solicitud) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.solicitudes,
        data: solicitud.toJson(),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return SolicitudCambio.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error creando solicitud: $e');
      return null;
    }
  }
  
  Future<SolicitudCambio?> responderSolicitud(int id, bool aceptada, String? respuesta) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.solicitudResponder}/$id',
        data: {
          'aceptada': aceptada,
          'respuesta': respuesta,
        },
      );
      
      if (response.statusCode == 200) {
        return SolicitudCambio.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error respondiendo solicitud: $e');
      return null;
    }
  }
  
  Future<bool> cancelarSolicitud(int id) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.solicitudCancelar}/$id',
        data: {},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error cancelando solicitud: $e');
      return false;
    }
  }
}
