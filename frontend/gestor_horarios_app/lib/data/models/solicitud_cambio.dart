import 'horario.dart';
import 'user.dart';

class SolicitudCambio {
  final int? id;
  final User? solicitante;
  final int? solicitanteId;
  final User? destinatario;
  final int? destinatarioId;
  final Horario? horarioOrigen;
  final int? horarioOrigenId;
  final Horario? horarioDestino;
  final int? horarioDestinoId;
  final DateTime? fechaSolicitud;
  final DateTime? fechaRespuesta;
  final String? mensaje;
  final String? respuesta;
  final EstadoSolicitud estado;

  SolicitudCambio({
    this.id,
    this.solicitante,
    this.solicitanteId,
    this.destinatario,
    this.destinatarioId,
    this.horarioOrigen,
    this.horarioOrigenId,
    this.horarioDestino,
    this.horarioDestinoId,
    this.fechaSolicitud,
    this.fechaRespuesta,
    this.mensaje,
    this.respuesta,
    this.estado = EstadoSolicitud.PENDIENTE,
  });

  factory SolicitudCambio.fromJson(Map<String, dynamic> json) {
    return SolicitudCambio(
      id: json['id'],
      solicitante: json['solicitante'] != null ? User.fromJson(json['solicitante']) : null,
      solicitanteId: json['solicitanteId'],
      destinatario: json['destinatario'] != null ? User.fromJson(json['destinatario']) : null,
      destinatarioId: json['destinatarioId'],
      horarioOrigen: json['horarioOrigen'] != null ? Horario.fromJson(json['horarioOrigen']) : null,
      horarioOrigenId: json['horarioOrigenId'],
      horarioDestino: json['horarioDestino'] != null ? Horario.fromJson(json['horarioDestino']) : null,
      horarioDestinoId: json['horarioDestinoId'],
      fechaSolicitud: json['fechaSolicitud'] != null ? DateTime.parse(json['fechaSolicitud']) : null,
      fechaRespuesta: json['fechaRespuesta'] != null ? DateTime.parse(json['fechaRespuesta']) : null,
      mensaje: json['mensaje'],
      respuesta: json['respuesta'],
      estado: EstadoSolicitudExtension.fromString(json['estado'] ?? 'PENDIENTE'),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'estado': estado.toString().split('.').last,
    };

    if (id != null) data['id'] = id;
    if (solicitanteId != null) data['solicitanteId'] = solicitanteId;
    if (destinatarioId != null) data['destinatarioId'] = destinatarioId;
    if (horarioOrigenId != null) data['horarioOrigenId'] = horarioOrigenId;
    if (horarioDestinoId != null) data['horarioDestinoId'] = horarioDestinoId;
    if (mensaje != null) data['mensaje'] = mensaje;
    if (respuesta != null) data['respuesta'] = respuesta;

    return data;
  }

  SolicitudCambio copyWith({
    int? id,
    User? solicitante,
    int? solicitanteId,
    User? destinatario,
    int? destinatarioId,
    Horario? horarioOrigen,
    int? horarioOrigenId,
    Horario? horarioDestino,
    int? horarioDestinoId,
    DateTime? fechaSolicitud,
    DateTime? fechaRespuesta,
    String? mensaje,
    String? respuesta,
    EstadoSolicitud? estado,
  }) {
    return SolicitudCambio(
      id: id ?? this.id,
      solicitante: solicitante ?? this.solicitante,
      solicitanteId: solicitanteId ?? this.solicitanteId,
      destinatario: destinatario ?? this.destinatario,
      destinatarioId: destinatarioId ?? this.destinatarioId,
      horarioOrigen: horarioOrigen ?? this.horarioOrigen,
      horarioOrigenId: horarioOrigenId ?? this.horarioOrigenId,
      horarioDestino: horarioDestino ?? this.horarioDestino,
      horarioDestinoId: horarioDestinoId ?? this.horarioDestinoId,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
      mensaje: mensaje ?? this.mensaje,
      respuesta: respuesta ?? this.respuesta,
      estado: estado ?? this.estado,
    );
  }
  
  String get fechaSolicitudFormateada {
    if (fechaSolicitud == null) return 'N/A';
    final dia = fechaSolicitud!.day.toString().padLeft(2, '0');
    final mes = fechaSolicitud!.month.toString().padLeft(2, '0');
    final anio = fechaSolicitud!.year.toString();
    return '$dia/$mes/$anio';
  }
  
  String get fechaRespuestaFormateada {
    if (fechaRespuesta == null) return 'N/A';
    final dia = fechaRespuesta!.day.toString().padLeft(2, '0');
    final mes = fechaRespuesta!.month.toString().padLeft(2, '0');
    final anio = fechaRespuesta!.year.toString();
    return '$dia/$mes/$anio';
  }
}

enum EstadoSolicitud {
  PENDIENTE,
  ACEPTADA,
  RECHAZADA,
  CANCELADA
}

extension EstadoSolicitudExtension on EstadoSolicitud {
  static EstadoSolicitud fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDIENTE':
        return EstadoSolicitud.PENDIENTE;
      case 'ACEPTADA':
        return EstadoSolicitud.ACEPTADA;
      case 'RECHAZADA':
        return EstadoSolicitud.RECHAZADA;
      case 'CANCELADA':
        return EstadoSolicitud.CANCELADA;
      default:
        return EstadoSolicitud.PENDIENTE;
    }
  }
  
  String get displayName {
    switch (this) {
      case EstadoSolicitud.PENDIENTE:
        return 'Pendiente';
      case EstadoSolicitud.ACEPTADA:
        return 'Aceptada';
      case EstadoSolicitud.RECHAZADA:
        return 'Rechazada';
      case EstadoSolicitud.CANCELADA:
        return 'Cancelada';
    }
  }
}
