import 'package:gestor_horarios_app/data/models/user.dart';

class Vehiculo {
  final int? id;
  final String marca;
  final String modelo;
  final String matricula;
  final String? color;
  final int? asientosDisponibles;
  final String? observaciones;
  final User? propietario;
  final int? propietarioId;
  final String? propietarioNombre;
  final bool activo;

  Vehiculo({
    this.id,
    required this.marca,
    required this.modelo,
    required this.matricula,
    this.color,
    this.asientosDisponibles,
    this.observaciones,
    this.propietario,
    this.propietarioId,
    this.propietarioNombre,
    this.activo = true,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      marca: json['marca'],
      modelo: json['modelo'],
      matricula: json['matricula'],
      color: json['color'],
      asientosDisponibles: json['asientosDisponibles'] ?? json['plazas'],
      observaciones: json['observaciones'],
      propietario: json['propietario'] != null ? User.fromJson(json['propietario']) : null,
      propietarioId: json['propietarioId'],
      propietarioNombre: json['propietarioNombre'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'marca': marca,
      'modelo': modelo,
      'matricula': matricula,
      'activo': activo,
      'asientosDisponibles': asientosDisponibles,
    };

    if (id != null) data['id'] = id;
    if (color != null) data['color'] = color;
    if (observaciones != null) data['observaciones'] = observaciones;
    if (propietarioId != null) data['propietarioId'] = propietarioId;

    return data;
  }

  Vehiculo copyWith({
    int? id,
    String? marca,
    String? modelo,
    String? matricula,
    String? color,
    int? asientosDisponibles,
    String? observaciones,
    User? propietario,
    int? propietarioId,
    String? propietarioNombre,
    bool? activo,
  }) {
    return Vehiculo(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      matricula: matricula ?? this.matricula,
      color: color ?? this.color,
      asientosDisponibles: asientosDisponibles ?? this.asientosDisponibles,
      observaciones: observaciones ?? this.observaciones,
      propietario: propietario ?? this.propietario,
      propietarioId: propietarioId ?? this.propietarioId,
      propietarioNombre: propietarioNombre ?? this.propietarioNombre,
      activo: activo ?? this.activo,
    );
  }
  
  // Helper method to check if the current user is the owner
  bool isOwner(int? currentUserId) {
    return currentUserId != null && 
           (propietarioId == currentUserId || 
            (propietario != null && propietario!.id == currentUserId));
  }
  
  String get descripcion => '$marca $modelo ($matricula)';
  
  String get descripcionCompleta {
    String desc = '$marca $modelo - $matricula';
    if (color != null) desc += ' - Color: $color';
    if (asientosDisponibles != null) desc += ' - $asientosDisponibles plazas';
    if (observaciones != null && observaciones!.isNotEmpty) {
      desc += '\nObservaciones: $observaciones';
    }
    return desc;
  }
}
