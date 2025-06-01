class Vehiculo {
  final int? id;
  final String marca;
  final String modelo;
  final String matricula;
  final String? color;
  final int totalAsientos;
  final int asientosDisponibles;
  final String? observaciones;
  final bool activo;

  Vehiculo({
    this.id,
    required this.marca,
    required this.modelo,
    required this.matricula,
    this.color,
    required this.totalAsientos,
    required this.asientosDisponibles,
    this.observaciones,
    this.activo = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'brand': marca,
      'model': modelo,
      'licensePlate': matricula,
      'color': color,
      'totalSeats': totalAsientos,
      'availableSeats': asientosDisponibles,
      'observations': observaciones,
      'active': activo,
    };
  }

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      marca: json['brand'] ?? '',
      modelo: json['model'] ?? '',
      matricula: json['licensePlate'] ?? '',
      color: json['color'],
      totalAsientos: json['totalSeats'] ?? 0,
      asientosDisponibles: json['availableSeats'] ?? 0,
      observaciones: json['observations'],
      activo: json['active'] ?? true,
    );
  }

  Vehiculo copyWith({
    int? id,
    String? marca,
    String? modelo,
    String? matricula,
    String? color,
    int? totalAsientos,
    int? asientosDisponibles,
    String? observaciones,
    bool? activo,
  }) {
    return Vehiculo(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      matricula: matricula ?? this.matricula,
      color: color ?? this.color,
      totalAsientos: totalAsientos ?? this.totalAsientos,
      asientosDisponibles: asientosDisponibles ?? this.asientosDisponibles,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
    );
  }
}