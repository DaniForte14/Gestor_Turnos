import 'package:flutter/foundation.dart';
import 'horario.dart';

class Schedule {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String role; // 'TCAE', 'ENFERMERO', 'MEDICO'
  final String? description;
  final bool isPublished;
  final String? createdBy;
  final String? assignedTo;
  final String status; // 'AVAILABLE', 'PENDING', 'APPROVED', 'REJECTED'

  Schedule({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.role,
    this.description,
    this.isPublished = false,
    this.createdBy,
    this.assignedTo,
    this.status = 'AVAILABLE',
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    // Función para formatear el rol para la UI (eliminar prefijo ROLE_ y formatear)
    String formatRoleForUI(String? role) {
      if (role == null) return 'USER';
      String formatted = role.trim();
      
      // Eliminar prefijo ROLE_ si existe
      if (formatted.startsWith('ROLE_')) {
        formatted = formatted.substring(5);
      }
      
      // Mapear a nombres consistentes
      if (formatted == 'MEDICO') {
        return 'Médico';
      } else if (formatted == 'ENFERMERO') {
        return 'Enfermero';
      } else if (formatted == 'TCAE') {
        return 'TCAE';
      }
      
      // Convertir a mayúsculas solo la primera letra
      if (formatted.isNotEmpty) {
        formatted = formatted[0].toUpperCase() + formatted.substring(1).toLowerCase();
      }
      
      return formatted;
    }
    
    // Mapeo de campos del backend a nuestro modelo
    String? getUserId(dynamic userData) {
      if (userData == null) return null;
      if (userData is Map) {
        return userData['id']?.toString();
      } else if (userData is int) {
        return userData.toString();
      } else if (userData is String) {
        return userData;
      }
      return null;
    }
    
    // Determinar el estado del horario
    String determineStatus(Map<String, dynamic> json) {
      if (json['disponible'] == true) return 'AVAILABLE';
      if (json['intercambiado'] == true) return 'EXCHANGED';
      if (json['estado'] != null) return json['estado'].toString().toUpperCase();
      return 'AVAILABLE';
    }
    
    return Schedule(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String().split('T')[0]),
      startTime: (json['horaInicio'] ?? '00:00:00').toString().substring(0, 5), // Tomar solo HH:mm
      endTime: (json['horaFin'] ?? '00:00:00').toString().substring(0, 5), // Tomar solo HH:mm
      role: formatRoleForUI(json['rol']?.toString() ?? json['tipoTurno']?.toString()),
      description: json['notas'] ?? json['descripcion'] ?? json['observaciones'],
      isPublished: json['publicado'] ?? true,
      createdBy: getUserId(json['usuario']),
      assignedTo: json['asignadoA']?.toString() ?? getUserId(json['usuario']),
      status: determineStatus(json),
    );
  }

  Map<String, dynamic> toJson() {
    // Función para formatear el rol al formato esperado por el backend
    String formatRole(String? role) {
      if (role == null) {
        debugPrint('Warning: El rol es nulo. Usando ROLE_MEDICO como valor por defecto.');
        return 'ROLE_MEDICO';
      }
      
      // Convertir a mayúsculas y eliminar espacios
      String formatted = role.trim().toUpperCase().replaceAll(' ', '');
      
      // Asegurar que el rol tenga el prefijo ROLE_
      if (!formatted.startsWith('ROLE_')) {
        formatted = 'ROLE_$formatted';
      }
      
      // Mapeo de roles a los valores esperados por el backend
      final roleMappings = {
        'ROLE_MÉDICO': 'ROLE_MEDICO',
        'ROLE_MEDICO': 'ROLE_MEDICO',
        'ROLE_ENFERMERO': 'ROLE_ENFERMERO',
        'ROLE_ENFERMERA': 'ROLE_ENFERMERO',
        'ROLE_TCAE': 'ROLE_TCAE',
        'MÉDICO': 'ROLE_MEDICO',
        'MEDICO': 'ROLE_MEDICO',
        'ENFERMERO': 'ROLE_ENFERMERO',
        'ENFERMERA': 'ROLE_ENFERMERO',
        'TCAE': 'ROLE_TCAE',
      };
      
      // Aplicar el mapeo de roles
      formatted = roleMappings[formatted] ?? formatted;
      
      // Validar que el rol sea uno de los permitidos
      if (!['ROLE_MEDICO', 'ROLE_ENFERMERO', 'ROLE_TCAE'].contains(formatted)) {
        debugPrint('Warning: Rol no válido: $role. Usando ROLE_MEDICO como valor por defecto.');
        return 'ROLE_MEDICO';
      }
      
      debugPrint('Rol formateado: $formatted');
      return formatted;
    }
    
    // Función para formatear la hora al formato HH:mm
    String formatTime(String time) {
      if (time.isEmpty) {
        debugPrint('Warning: La hora está vacía. Usando 09:00 como valor por defecto.');
        return '09:00';
      }
      
      try {
        // Eliminar espacios y dividir por ':'
        final cleanTime = time.trim();
        final parts = cleanTime.split(':');
        
        if (parts.isEmpty) return '09:00';
        
        // Asegurar que tenemos al menos horas y minutos
        var hour = parts[0].padLeft(2, '0');
        var minute = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
        
        // Validar rangos
        int? hourInt = int.tryParse(hour);
        int? minuteInt = int.tryParse(minute);
        
        if (hourInt == null || hourInt < 0 || hourInt > 23) {
          debugPrint('Warning: Hora inválida: $hour. Usando 09:00');
          return '09:00';
        }
        
        if (minuteInt == null || minuteInt < 0 || minuteInt > 59) {
          debugPrint('Warning: Minutos inválidos: $minute. Usando 00');
          minute = '00';
        }
        
        return '$hour:$minute';
      } catch (e) {
        debugPrint('Error al formatear la hora "$time": $e');
        return '09:00';
      }
    }
    
    // Formatear la fecha como string YYYY-MM-DD
    String formatDate(DateTime date) {
      try {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      } catch (e) {
        debugPrint('Error al formatear la fecha: $e');
        return DateTime.now().toIso8601String().split('T')[0];
      }
    }
    
    // Validar que la hora de fin sea posterior a la de inicio
    bool validateTimeRange(String start, String end) {
      try {
        final startParts = start.split(':');
        final endParts = end.split(':');
        
        if (startParts.length < 2 || endParts.length < 2) return false;
        
        final startHour = int.tryParse(startParts[0]) ?? 0;
        final startMinute = int.tryParse(startParts[1]) ?? 0;
        final endHour = int.tryParse(endParts[0]) ?? 0;
        final endMinute = int.tryParse(endParts[1]) ?? 0;
        
        if (endHour > startHour) return true;
        if (endHour == startHour && endMinute > startMinute) return true;
        
        debugPrint('Error: La hora de fin ($end) debe ser posterior a la hora de inicio ($start)');
        return false;
      } catch (e) {
        debugPrint('Error al validar el rango de horas: $e');
        return false;
      }
    }
    
    // Preparar los valores
    final formattedDate = formatDate(date);
    final formattedStartTime = formatTime(startTime);
    var formattedEndTime = formatTime(endTime);
    final formattedRole = formatRole(role);
    
    // Validar el rango de tiempo
    if (!validateTimeRange(formattedStartTime, formattedEndTime)) {
      throw Exception('La hora de fin debe ser posterior a la hora de inicio');
    }
    
    // Crear el mapa con los campos que espera el backend
    final jsonMap = {
      'fecha': formattedDate, // Formato: YYYY-MM-DD
      'horaInicio': formattedStartTime, // Formato: HH:mm
      'horaFin': formattedEndTime, // Formato: HH:mm
      'rol': formattedRole, // Formato: ROLE_XXX (MEDICO, ENFERMERO, TCAE)
      'notas': description?.trim() ?? '',
      'tipoTurno': 'MANANA', // Valor por defecto
      'disponible': true,
    };
    
    debugPrint('Datos a enviar al backend: $jsonMap');
    return jsonMap;
  }

  factory Schedule.fromHorario(Horario horario) {
    // Get the first role from the roles list or default to 'USER'
    final role = horario.roles.isNotEmpty 
        ? horario.roles.first.toUpperCase()
        : 'USER';
    
    // Determine if the schedule is assigned to a user
    final isAssigned = horario.usuarioId != null && horario.usuarioId != 0;
    
    return Schedule(
      id: horario.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: horario.fecha,
      startTime: horario.horaInicio,
      endTime: horario.horaFin,
      role: role,
      description: horario.notas,
      isPublished: horario.activo,
      createdBy: horario.usuario?.id?.toString(),
      assignedTo: isAssigned ? horario.usuarioId.toString() : null,
      status: isAssigned ? 'ASSIGNED' : 'AVAILABLE',
    );
  }

  Schedule copyWith({
    String? id,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? role,
    String? description,
    bool? isPublished,
    String? createdBy,
    String? assignedTo,
    String? status,
  }) {
    return Schedule(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      role: role ?? this.role,
      description: description ?? this.description,
      isPublished: isPublished ?? this.isPublished,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
    );
  }
}
