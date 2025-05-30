import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/presentation/auth/login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gestor_horarios_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar servicios globales antes de ejecutar la app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const GestorHorariosApp(),
    ),
  );
}

class GestorHorariosApp extends StatelessWidget {
  const GestorHorariosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Horarios',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      home: const LoginScreen(),
    );
  }
}
