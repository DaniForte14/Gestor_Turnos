import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/data/repositories/auth_repository.dart';
import 'package:gestor_horarios_app/presentation/admin/schedule_form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestor_horarios_app/presentation/auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authRepository = AuthRepository();
    _userFuture = authRepository.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Text(
              'Error: ${snapshot.error ?? "No se pudo cargar la información"}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        final userData = snapshot.data!;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Panel de Administración'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar sesión',
                onPressed: () async {
                  // Mostrar diálogo de confirmación
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    // Limpiar el token de autenticación
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('auth_token');
                    
                    // Navegar a la pantalla de login
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado de bienvenida
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido, Administrador ${userData['nombre'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${userData['email'] ?? ''}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Tarjetas de gestión
                const Text(
                  'Gestión del Sistema',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Grid de tarjetas de administración
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildAdminCard(
                      context,
                      'Usuarios',
                      Icons.people,
                      Colors.blue,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gestión de usuarios - En desarrollo'),
                          ),
                        );
                      },
                    ),
                    _buildAdminCard(
                      context,
                      'Horarios',
                      Icons.calendar_month,
                      Colors.green,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ScheduleFormScreen(),
                          ),
                        );
                      },
                    ),
                    _buildAdminCard(
                      context,
                      'Solicitudes',
                      Icons.assignment,
                      Colors.orange,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gestión de solicitudes - En desarrollo'),
                          ),
                        );
                      },
                    ),
                    _buildAdminCard(
                      context,
                      'Reportes',
                      Icons.bar_chart,
                      Colors.purple,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reportes - En desarrollo'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Resumen del sistema
                const Text(
                  'Resumen del Sistema',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatRow('Total Usuarios', '34', Icons.people),
                        const Divider(),
                        _buildStatRow('Médicos', '12', Icons.medical_services),
                        const Divider(),
                        _buildStatRow('Enfermeros', '18', Icons.healing),
                        const Divider(),
                        _buildStatRow('TCAE', '4', Icons.health_and_safety),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
