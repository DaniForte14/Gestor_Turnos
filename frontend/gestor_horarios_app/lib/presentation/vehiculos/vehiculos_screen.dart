import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/core/theme/app_theme.dart';
import 'package:gestor_horarios_app/data/models/vehiculo.dart';
import 'package:gestor_horarios_app/data/repositories/vehiculo_repository.dart';
import 'package:provider/provider.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({Key? key}) : super(key: key);

  @override
  _VehiculosScreenState createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Vehiculo>> _misVehiculosFuture;
  late Future<List<Vehiculo>> _vehiculosDisponiblesFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVehiculos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadVehiculos() {
    setState(() {
      _isLoading = true;
    });

    final vehiculoRepository = Provider.of<VehiculoRepository>(context, listen: false);
    
    _misVehiculosFuture = vehiculoRepository.getMisVehiculos();
    _vehiculosDisponiblesFuture = vehiculoRepository.getVehiculosDisponibles();
    
    Future.wait([_misVehiculosFuture, _vehiculosDisponiblesFuture]).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando vehículos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _cambiarEstadoActivo(Vehiculo vehiculo, bool nuevoEstado) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehiculoRepository = Provider.of<VehiculoRepository>(context, listen: false);
      final success = await vehiculoRepository.cambiarEstadoActivo(vehiculo.id!, nuevoEstado);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vehículo ${nuevoEstado ? 'activado' : 'desactivado'} correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadVehiculos();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cambiar el estado del vehículo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _eliminarVehiculo(Vehiculo vehiculo) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehiculoRepository = Provider.of<VehiculoRepository>(context, listen: false);
      final success = await vehiculoRepository.eliminarVehiculo(vehiculo.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehículo eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadVehiculos();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el vehículo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAgregarVehiculoDialog() {
    // Aquí implementaremos la funcionalidad para añadir un nuevo vehículo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Vehículo'),
        content: const Text('Esta funcionalidad estará disponible próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mis Vehículos'),
            Tab(text: 'Disponibles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMisVehiculosTab(),
          _buildVehiculosDisponiblesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAgregarVehiculoDialog,
        child: const Icon(Icons.add),
        tooltip: 'Agregar Vehículo',
      ),
    );
  }

  Widget _buildMisVehiculosTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : FutureBuilder<List<Vehiculo>>(
            future: _misVehiculosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              
              final vehiculos = snapshot.data ?? [];
              
              if (vehiculos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes vehículos registrados',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showAgregarVehiculoDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Vehículo'),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: vehiculos.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final vehiculo = vehiculos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: vehiculo.activo ? AppTheme.primaryColor : Colors.grey,
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        vehiculo.descripcion,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                vehiculo.activo ? Icons.check_circle : Icons.cancel,
                                color: vehiculo.activo ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                vehiculo.activo ? 'Activo' : 'Inactivo',
                                style: TextStyle(
                                  color: vehiculo.activo ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (vehiculo.color != null) ...[
                            const SizedBox(height: 4),
                            Text('Color: ${vehiculo.color}'),
                          ],
                          if (vehiculo.plazas != null) ...[
                            const SizedBox(height: 4),
                            Text('Plazas: ${vehiculo.plazas}'),
                          ],
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              // Implementar edición de vehículo
                              break;
                            case 'toggle':
                              _cambiarEstadoActivo(vehiculo, !vehiculo.activo);
                              break;
                            case 'delete':
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Eliminar Vehículo'),
                                  content: const Text(
                                      '¿Está seguro de que desea eliminar este vehículo?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('CANCELAR'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _eliminarVehiculo(vehiculo);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('ELIMINAR'),
                                    ),
                                  ],
                                ),
                              );
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Editar'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'toggle',
                            child: ListTile(
                              leading: Icon(
                                vehiculo.activo ? Icons.cancel : Icons.check_circle,
                                color: vehiculo.activo ? Colors.red : Colors.green,
                              ),
                              title: Text(vehiculo.activo ? 'Desactivar' : 'Activar'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
  }

  Widget _buildVehiculosDisponiblesTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : FutureBuilder<List<Vehiculo>>(
            future: _vehiculosDisponiblesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              
              final vehiculos = snapshot.data ?? [];
              
              if (vehiculos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.no_crash,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay vehículos disponibles',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: vehiculos.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final vehiculo = vehiculos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        vehiculo.descripcion,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          if (vehiculo.propietario != null) ...[
                            Text('Propietario: ${vehiculo.propietario!.nombreCompleto}'),
                            const SizedBox(height: 4),
                          ],
                          if (vehiculo.color != null) ...[
                            Text('Color: ${vehiculo.color}'),
                            const SizedBox(height: 4),
                          ],
                          if (vehiculo.plazas != null) ...[
                            Text('Plazas: ${vehiculo.plazas}'),
                          ],
                        ],
                      ),
                      trailing: const Icon(Icons.info_outline),
                      onTap: () {
                        // Mostrar detalles del vehículo
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(vehiculo.descripcion),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Matrícula: ${vehiculo.matricula}'),
                                const SizedBox(height: 8),
                                if (vehiculo.propietario != null) ...[
                                  Text('Propietario: ${vehiculo.propietario!.nombreCompleto}'),
                                  const SizedBox(height: 8),
                                ],
                                if (vehiculo.color != null) ...[
                                  Text('Color: ${vehiculo.color}'),
                                  const SizedBox(height: 8),
                                ],
                                if (vehiculo.plazas != null) ...[
                                  Text('Plazas: ${vehiculo.plazas}'),
                                ],
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('CERRAR'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
  }
}
