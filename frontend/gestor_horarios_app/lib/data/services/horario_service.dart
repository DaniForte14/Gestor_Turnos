import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/data/models/horario.dart';
import 'package:gestor_horarios_app/data/repositories/horario_repository.dart';

class HorarioService {
  final HorarioRepository _repository;

  HorarioService(this._repository);

  /// Obtiene los horarios disponibles para un rol y fecha específicos
  Future<List<Horario>> getHorariosDisponibles({
    required DateTime fecha,
    String? rol,
  }) async {
    try {
      final horarios = await _repository.getHorariosDisponibles(
        fecha: fecha,
        rol: rol,
      );
      
      // Retornar los horarios con sus roles
      return horarios;
    } catch (e) {
      print('Error en HorarioService.getHorariosDisponibles: $e');
      rethrow;
    }
  }

  /// Obtiene los horarios del usuario actual
  Future<List<Horario>> getMisHorarios() async {
    try {
      return await _repository.getMisHorarios();
    } catch (e) {
      print('Error en HorarioService.getMisHorarios: $e');
      rethrow;
    }
  }

  /// Obtiene los horarios por rango de fechas
  Future<List<Horario>> getHorariosPorFecha(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    try {
      return await _repository.getHorariosPorFecha(fechaInicio, fechaFin);
    } catch (e) {
      print('Error en HorarioService.getHorariosPorFecha: $e');
      rethrow;
    }
  }

  /// Obtiene un horario por su ID
  Future<Horario?> getHorarioPorId(int id) async {
    try {
      return await _repository.getHorarioPorId(id);
    } catch (e) {
      print('Error en HorarioService.getHorarioPorId: $e');
      rethrow;
    }
  }

  /// Solicita un horario disponible
  Future<bool> solicitarHorario(int horarioId) async {
    try {
      // TODO: Implementar lógica de solicitud de horario
      // Esto debería hacer una petición PATCH al backend
      // para asignar el horario al usuario actual
      print('Solicitando horario con ID: $horarioId');
      return true; // Simular éxito por ahora
    } catch (e) {
      print('Error en HorarioService.solicitarHorario: $e');
      rethrow;
    }
  }

  /// Crea un nuevo horario disponible
  Future<Horario> crearHorarioDisponible({
    required DateTime fecha,
    required TimeOfDay horaInicio,
    required TimeOfDay horaFin,
    required TipoJornada tipoJornada,
    String? notas,
    List<String>? roles,
  }) async {
    try {
      // Convertir TimeOfDay a String en formato HH:mm
      final horaInicioStr = '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}';
      final horaFinStr = '${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}';
      
      // Crear el horario
      final horario = Horario(
        fecha: fecha,
        horaInicio: horaInicioStr,
        horaFin: horaFinStr,
        tipoJornada: tipoJornada,
        notas: notas,
        roles: roles ?? [],
      );
      
      // Llamar al repositorio para guardar en el backend
      return await _repository.crearHorarioDisponible(horario);
    } catch (e) {
      print('Error en HorarioService.crearHorarioDisponible: $e');
      rethrow;
    }
  }
}
