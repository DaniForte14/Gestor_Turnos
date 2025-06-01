import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:gestor_horarios_app/app_router.dart';
import 'package:gestor_horarios_app/core/theme/app_theme.dart';
import 'package:gestor_horarios_app/core/utils/api_client.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';
import 'package:gestor_horarios_app/data/providers/vehicle_provider.dart';
import 'package:gestor_horarios_app/data/repositories/horario_repository.dart';
import 'package:gestor_horarios_app/data/repositories/vehiculo_repository.dart';
import 'package:gestor_horarios_app/presentation/auth/login_screen.dart';
import 'package:gestor_horarios_app/presentation/home/home_screen.dart';
import 'package:gestor_horarios_app/presentation/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar servicios globales antes de ejecutar la app
  // Initialize API client with base URL and interceptors
  final apiClient = ApiClient();
  
  // Inicializar AuthProvider primero
  final authProvider = AuthProvider();
  
  // Inicializar la autenticación
  authProvider.initialize().then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<VehicleProvider>(
            create: (context) => VehicleProvider(authProvider),
          ),
          Provider<HorarioRepository>(
            create: (_) => HorarioRepository(apiClient),
            dispose: (_, __) => apiClient.dio.close(),
          ),
          Provider<VehiculoRepository>(
            create: (_) => VehiculoRepository(),
          ),
        ],
        child: const GestorHorariosApp(),
      ),
    );
  });
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
      initialRoute: AppRouter.home, 
      onGenerateRoute: AppRouter.generateRoute,
      // Ruta de inicio de sesión manejada por el AuthProvider
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // Si el usuario no está autenticado, mostrar la pantalla de login
          if (!authProvider.isAuthenticated) {
            return const LoginScreen();
          }
          
          // Si el usuario está autenticado, verificar si es administrador
          final user = authProvider.currentUser;
          final isAdmin = user?.username == 'admin';
          
          debugPrint('=== VERIFICACIÓN DE ADMIN EN MAIN.DART ===');
          debugPrint('Solo el usuario "admin" es considerado administrador');
          debugPrint('Usuario actual: ${user?.username}');
          debugPrint('Es administrador: $isAdmin');
          
          // Si es administrador, redirigir al panel de administración
          if (isAdmin) {
            return const AdminDashboard();
          }
          
          // Si es un usuario normal, mostrar el HomeScreen
          return const HomeScreen();
        },
      ),
    );
  }
}
