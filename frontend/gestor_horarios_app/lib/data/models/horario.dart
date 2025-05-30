import 'user.dart';

class Horario {
  final int? id;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final User? usuario;
  final int? usuarioId;
  final String? notas;
  final TipoJornada tipoJornada;
  final bool activo;

  Horario({
    this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.usuario,
    this.usuarioId,
    this.notas,
    required this.tipoJornada,
    this.activo = true,
  });

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      id: json['id'],
      fecha: DateTime.parse(json['fecha']),
      horaInicio: json['horaInicio'],
      horaFin: json['horaFin'],
      usuario: json['usuario'] != null ? User.fromJson(json['usuario']) : null,
      usuarioId: json['usuarioId'],
      notas: json['notas'],
      tipoJornada: TipoJornadaExtension.fromString(json['tipoJornada']),
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'fecha': fecha.toIso8601String().split('T')[0],
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'tipoJornada': tipoJornada.toString().split('.').last,
      'activo': activo,
    };

    if (id != null) data['id'] = id;
    if (usuarioId != null) data['usuarioId'] = usuarioId;
    if (notas != null) data['notas'] = notas;

    return data;
  }

  Horario copyWith({
    int? id,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
    User? usuario,
    int? usuarioId,
    String? notas,
    TipoJornada? tipoJornada,
    bool? activo,
  }) {
    return Horario(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      usuario: usuario ?? this.usuario,
      usuarioId: usuarioId ?? this.usuarioId,
      notas: notas ?? this.notas,
      tipoJornada: tipoJornada ?? this.tipoJornada,
      activo: activo ?? this.activo,
    );
  }
  
  String get fechaFormateada {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    return '$dia/$mes/$anio';
  }
  
  String get horarioFormateado => '$horaInicio - $horaFin';
  
  String get duracion {
    final inicio = _convertirHoraMinutos(horaInicio);
    final fin = _convertirHoraMinutos(horaFin);
    
    int minutosTotales = fin - inicio;
    if (minutosTotales < 0) minutosTotales += 24 * 60; // Si cruza la medianoche
    
    final horas = (minutosTotales / 60).floor();
    final minutos = minutosTotales % 60;
    
    return '${horas}h ${minutos}m';
  }
  
  int _convertirHoraMinutos(String hora) {
    final partes = hora.split(':');
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
  }
}

enum TipoJornada {
  MANANA,
  TARDE,
  NOCHE,
  COMPLETA,
  GUARDIA
}

extension TipoJornadaExtension on TipoJornada {
  static TipoJornada fromString(String value) {
    switch (value.toUpperCase()) {
      case 'MANANA':
        return TipoJornada.MANANA;
      case 'TARDE':
        return TipoJornada.TARDE;
      case 'NOCHE':
        return TipoJornada.NOCHE;
      case 'COMPLETA':
        return TipoJornada.COMPLETA;
      case 'GUARDIA':
        return TipoJornada.GUARDIA;
      default:
        return TipoJornada.MANANA;
    }
  }
  
  String get displayName {
    switch (this) {
      case TipoJornada.MANANA:
        return 'Mañana';
      case TipoJornada.TARDE:
        return 'Tarde';
      case TipoJornada.NOCHE:
        return 'Noche';
      case TipoJornada.COMPLETA:
        return 'Jornada Completa';
      case TipoJornada.GUARDIA:
        return 'Guardia';
    }
  }
}
