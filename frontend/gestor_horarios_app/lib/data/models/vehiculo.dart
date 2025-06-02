import 'package:gestor_horarios_app/data/models/user.dart';

class Vehiculo {
  final int? id;
  final String marca;
  final String modelo;
  final String matricula;
  final String? color;
  final int? asientosDisponibles;
  final int? totalSeats;
  final String? observaciones;
  final User? propietario;
  final int? propietarioId;
  final String? propietarioNombre;
  final bool activo;
  final List<User>? pasajeros;
  final List<int>? pasajerosIds;

  Vehiculo({
    this.id,
    required this.marca,
    required this.modelo,
    required this.matricula,
    this.color,
    this.asientosDisponibles,
    this.observaciones,
    this.totalSeats,
    this.propietario,
    this.propietarioId,
    this.propietarioNombre,
    this.activo = true,
    this.pasajeros,
    this.pasajerosIds,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    print('Parsing vehicle JSON: $json');
    
    try {
      final vehiculo = Vehiculo(
        id: json['id'],
        marca: json['brand'] ?? json['marca'] ?? '', // Fallback to old field name
        modelo: json['model'] ?? json['modelo'] ?? '', // Fallback to old field name
        matricula: json['licensePlate'] ?? json['matricula'] ?? '', // Fallback to old field name
        color: json['color'],
        asientosDisponibles: json['availableSeats'] ?? json['asientosDisponibles'] ?? json['plazas'] ?? 0,
        totalSeats: json['totalSeats'] ?? json['asientosDisponibles'] ?? json['plazas'] ?? 0,
        observaciones: json['observations'] ?? json['observaciones'],
        propietario: json['owner'] != null 
            ? User.fromJson(json['owner'])
            : (json['propietario'] != null ? User.fromJson(json['propietario']) : null),
        propietarioId: json['ownerId'] ?? json['propietarioId'],
        propietarioNombre: json['ownerName'] ?? json['propietarioNombre'],
        activo: json['active'] ?? json['activo'] ?? true,
        pasajeros: (json['passengers'] ?? json['pasajeros']) != null 
            ? List<User>.from((json['passengers'] ?? json['pasajeros']).map((x) => User.fromJson(x)))
            : null,
        pasajerosIds: (json['passengerIds'] ?? json['pasajerosIds']) != null
            ? List<int>.from((json['passengerIds'] ?? json['pasajerosIds']).map((x) => x is int ? x : int.tryParse(x.toString()) ?? 0))
            : null,
      );
      
      print('Successfully parsed vehicle: ${vehiculo.matricula}');
      return vehiculo;
      
    } catch (e) {
      print('Error parsing vehicle: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': marca,
      'model': modelo,
      'licensePlate': matricula,
      'color': color,
      'availableSeats': asientosDisponibles,
      'totalSeats': totalSeats,
      'observations': observaciones,
      'active': activo,
      if (propietario != null) 'owner': propietario!.toJson(),
      if (propietarioId != null) 'ownerId': propietarioId,
      if (propietarioNombre != null) 'ownerName': propietarioNombre,
      if (pasajeros != null)
        'passengers': pasajeros!.map((p) => p.toJson()).toList(),
      if (pasajerosIds != null) 'passengerIds': pasajerosIds,
    };
  }

  Vehiculo copyWith({
    int? id,
    String? marca,
    String? modelo,
    String? matricula,
    String? color,
    int? asientosDisponibles,
    int? totalSeats,
    String? observaciones,
    User? propietario,
    int? propietarioId,
    String? propietarioNombre,
    bool? activo,
    List<User>? pasajeros,
    List<int>? pasajerosIds,
  }) {
    return Vehiculo(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      matricula: matricula ?? this.matricula,
      color: color ?? this.color,
      asientosDisponibles: asientosDisponibles ?? this.asientosDisponibles,
      totalSeats: totalSeats ?? this.totalSeats,
      observaciones: observaciones ?? this.observaciones,
      propietario: propietario ?? this.propietario,
      propietarioId: propietarioId ?? this.propietarioId,
      propietarioNombre: propietarioNombre ?? this.propietarioNombre,
      activo: activo ?? this.activo,
      pasajeros: pasajeros ?? this.pasajeros,
      pasajerosIds: pasajerosIds ?? this.pasajerosIds,
    );
  }
  
  // Helper method to check if the current user is the owner
  bool isOwner(int? currentUserId) {
    return currentUserId != null && 
           (propietarioId == currentUserId || 
            (propietario != null && propietario!.id == currentUserId));
  }
  
  /// Verifica si un usuario es pasajero de este vehículo
  bool isPassenger(int? userId) {
    if (userId == null) return false;
    
    // Verificar en la lista de pasajeros completos
    if (pasajeros != null) {
      return pasajeros!.any((p) => p.id == userId);
    }
    
    // Verificar en la lista de IDs de pasajeros
    if (pasajerosIds != null) {
      return pasajerosIds!.contains(userId);
    }
    
    return false;
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
