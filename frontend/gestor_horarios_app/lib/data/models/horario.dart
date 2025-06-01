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
  final List<String> roles; // Lista de roles para este horario

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
    List<String>? roles,
  }) : roles = roles ?? [];

  factory Horario.fromJson(Map<String, dynamic> json) {
    // Procesar los roles si vienen en la respuesta
    List<String> roles = [];
    if (json['roles'] != null && json['roles'] is List) {
      roles = (json['roles'] as List).map((role) {
        // Asegurar que el rol tenga el formato correcto (sin prefijo ROLE_)
        final roleStr = role.toString();
        return roleStr.replaceFirst('ROLE_', '');
      }).toList();
    }

    // Manejar el tipo de jornada (puede venir como 'tipoJornada' o 'tipoTurno')
    final tipoJornadaStr = json['tipoJornada']?.toString() ?? 
                           json['tipoTurno']?.toString() ?? '';

    // Manejar la fecha (puede venir en diferentes formatos)
    DateTime parseFecha(dynamic fecha) {
      if (fecha == null) return DateTime.now();
      if (fecha is DateTime) return fecha;
      try {
        return DateTime.parse(fecha.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return Horario(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0'),
      fecha: parseFecha(json['fecha']),
      horaInicio: json['horaInicio']?.toString() ?? '',
      horaFin: json['horaFin']?.toString() ?? '',
      usuario: json['usuario'] != null ? User.fromJson(json['usuario'] is Map ? json['usuario'] : {}) : null,
      usuarioId: json['usuarioId'] is int ? json['usuarioId'] : int.tryParse(json['usuarioId']?.toString() ?? '0'),
      notas: json['notas']?.toString(),
      tipoJornada: TipoJornadaExtension.fromString(tipoJornadaStr),
      activo: json['activo'] ?? json['disponible'] ?? true,
      roles: roles,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'fecha': fecha.toIso8601String().split('T')[0],
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'tipoTurno': tipoJornada.toString().split('.').last,
      'disponible': true, // Por defecto, un nuevo horario está disponible
      'activo': activo,
    };

    if (id != null) data['id'] = id;
    if (usuarioId != null) data['usuarioId'] = usuarioId;
    if (notas != null && notas!.isNotEmpty) data['notas'] = notas;
    if (roles.isNotEmpty) {
      // Asegurar que los roles tengan el prefijo ROLE_ y estén en mayúsculas
      data['roles'] = roles.map((rol) => 
        rol.toUpperCase().startsWith('ROLE_') ? rol.toUpperCase() : 'ROLE_${rol.toUpperCase()}'
      ).toList();
    }

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
    List<String>? roles,
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
      roles: roles ?? this.roles,
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
