import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';
import 'package:gestor_horarios_app/presentation/calendar/calendar_screen.dart';
import 'package:gestor_horarios_app/presentation/profile/profile_screen_fixed.dart';
import 'package:gestor_horarios_app/presentation/admin/admin_dashboard.dart';
import 'package:gestor_horarios_app/presentation/home/vertical_day_view.dart';
import 'package:gestor_horarios_app/presentation/auth/login_screen.dart';
import 'package:gestor_horarios_app/presentation/vehiculos/vehiculos_screen.dart';
import 'package:gestor_horarios_app/presentation/schedule/my_schedules_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  List<Widget> _buildScreens(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.currentUser?.roles.any((role) => 
      role == 'ROLE_ADMIN' || role == 'ADMIN' || role == 'ADMINISTRADOR'
    ) ?? false;

    return [
      const VerticalDayView(),
      const CalendarScreen(),
      const VehiculosScreen(),
      const MySchedulesScreen(),
      isAdmin ? const AdminDashboard() : const ProfileScreen(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      // Initialize auth provider if needed
      if (!authProvider.isAuthenticated) {
        await authProvider.initialize();
      }
      
      if (!mounted) return;
      
      // If not authenticated after initialization, redirect to login
      if (!authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al verificar la autenticación')),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
  
  Future<void> _logout() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (mounted) {
        // Navegar a la pantalla de login usando MaterialPageRoute
        // y limpiar el stack de navegación
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // Elimina todas las rutas anteriores
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (_isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        final isAdmin = authProvider.currentUser?.roles.any((role) => 
          role == 'ROLE_ADMIN' || role == 'ADMIN' || role == 'ADMINISTRADOR'
        ) ?? false;

        final screens = _buildScreens(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestor de Horarios'),
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    authProvider.currentUser?.nombreCompleto ?? 'Usuario',
                    style: const TextStyle(fontSize: 18),
                  ),
                  accountEmail: Text(
                    authProvider.currentUser?.email ?? '',
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      authProvider.currentUser?.nombreCompleto.isNotEmpty == true
                          ? authProvider.currentUser!.nombreCompleto[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(fontSize: 40, color: Colors.blue),
                    ),
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Inicio'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Calendario'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: const Text('Vehículos'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Mis Turnos'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 3;
                    });
                  },
                ),
                if (isAdmin)
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Panel de Administración'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 4;
                      });
                    },
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar sesión'),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Inicio',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Calendario',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.directions_car),
                label: 'Vehículos',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'Mis Turnos',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: isAdmin ? 'Admin' : 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}


