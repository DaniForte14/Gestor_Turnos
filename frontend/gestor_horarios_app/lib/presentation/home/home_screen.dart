import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';
import 'package:gestor_horarios_app/presentation/auth/login_screen.dart';
import 'package:gestor_horarios_app/presentation/calendar/calendar_screen.dart';
import 'package:gestor_horarios_app/presentation/profile/profile_screen_fixed.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const WelcomeScreen(),
    const CalendarScreen(),
    const ProfileScreen(),
  ];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Initialize auth provider if needed
      if (!authProvider.isAuthenticated) {
        await authProvider.initialize();
      }
      
      // If not authenticated after initialization, redirect to login
      if (!authProvider.isAuthenticated && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _logout() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 
            ? 'Gestor de Horarios' 
            : _currentIndex == 1 
              ? 'Calendario' 
              : 'Perfil'
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text('¿Está seguro que desea cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('CANCELAR'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _logout();
                      },
                      child: const Text('ACEPTAR'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// Welcome screen widget that displays user information
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (!authProvider.isAuthenticated || authProvider.currentUser == null) {
      return const Center(
        child: Text(
          'No se pudo cargar la información del usuario',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    
    final user = authProvider.currentUser!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bienvenido, ${user.nombreCompleto}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text('Usuario: ${user.username}'),
          Text('Email: ${user.email}'),
          const SizedBox(height: 30),
          const Text(
            'Esta es una versión simplificada de la aplicación.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
