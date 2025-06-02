import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/screens/horarios_disponibles_screen.dart';
import 'package:gestor_horarios_app/screens/admin/publicar_horario_screen.dart';
import 'package:gestor_horarios_app/presentation/vehiculos/vehiculos_screen.dart';



class AppRouter {
  static const String home = '/';
  static const String horariosDisponibles = '/horarios-disponibles';
  static const String publicarHorario = '/publicar-horario';
  static const String vehicles = '/vehiculos';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case horariosDisponibles:
        return MaterialPageRoute(
          builder: (_) => const HorariosDisponiblesScreen(),
          settings: settings,
        );
      case publicarHorario:
        return MaterialPageRoute(
          builder: (_) => const PublicarHorarioScreen(),
          settings: settings,
        );
      case vehicles:
        return MaterialPageRoute(
          builder: (_) => const VehiculosScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No se encontró la ruta para ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
