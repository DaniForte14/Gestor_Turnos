import 'user.dart';

class Vehiculo {
  final int? id;
  final String marca;
  final String modelo;
  final String matricula;
  final String? color;
  final int? plazas;
  final User? propietario;
  final int? propietarioId;
  final bool activo;

  Vehiculo({
    this.id,
    required this.marca,
    required this.modelo,
    required this.matricula,
    this.color,
    this.plazas,
    this.propietario,
    this.propietarioId,
    this.activo = true,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      marca: json['marca'],
      modelo: json['modelo'],
      matricula: json['matricula'],
      color: json['color'],
      plazas: json['plazas'],
      propietario: json['propietario'] != null ? User.fromJson(json['propietario']) : null,
      propietarioId: json['propietarioId'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'marca': marca,
      'modelo': modelo,
      'matricula': matricula,
      'activo': activo,
    };

    if (id != null) data['id'] = id;
    if (color != null) data['color'] = color;
    if (plazas != null) data['plazas'] = plazas;
    if (propietarioId != null) data['propietarioId'] = propietarioId;

    return data;
  }

  Vehiculo copyWith({
    int? id,
    String? marca,
    String? modelo,
    String? matricula,
    String? color,
    int? plazas,
    User? propietario,
    int? propietarioId,
    bool? activo,
  }) {
    return Vehiculo(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      matricula: matricula ?? this.matricula,
      color: color ?? this.color,
      plazas: plazas ?? this.plazas,
      propietario: propietario ?? this.propietario,
      propietarioId: propietarioId ?? this.propietarioId,
      activo: activo ?? this.activo,
    );
  }
  
  String get descripcion => '$marca $modelo ($matricula)';
  
  String get descripcionCompleta {
    String desc = '$marca $modelo - $matricula';
    if (color != null) desc += ' - Color: $color';
    if (plazas != null) desc += ' - $plazas plazas';
    return desc;
  }
}
