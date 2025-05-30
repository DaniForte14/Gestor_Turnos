import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/core/theme/app_theme.dart';
import 'package:gestor_horarios_app/data/models/solicitud_cambio.dart';
import 'package:gestor_horarios_app/data/repositories/solicitud_cambio_repository.dart';
import 'package:provider/provider.dart';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({Key? key}) : super(key: key);

  @override
  _SolicitudesScreenState createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<SolicitudCambio>> _misSolicitudesFuture;
  late Future<List<SolicitudCambio>> _solicitudesRecibidasFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSolicitudes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSolicitudes() {
    setState(() {
      _isLoading = true;
    });

    final solicitudRepository = Provider.of<SolicitudCambioRepository>(context, listen: false);
    
    _misSolicitudesFuture = solicitudRepository.getMisSolicitudes();
    _solicitudesRecibidasFuture = solicitudRepository.getSolicitudesRecibidas();
    
    Future.wait([_misSolicitudesFuture, _solicitudesRecibidasFuture]).then((_) {
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
            content: Text('Error cargando solicitudes: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _responderSolicitud(SolicitudCambio solicitud, bool aceptada, String? respuesta) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final solicitudRepository = Provider.of<SolicitudCambioRepository>(context, listen: false);
      final result = await solicitudRepository.responderSolicitud(
        solicitud.id!,
        aceptada,
        respuesta,
      );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solicitud ${aceptada ? 'aceptada' : 'rechazada'} correctamente'),
            backgroundColor: aceptada ? Colors.green : Colors.orange,
          ),
        );
        _loadSolicitudes();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al responder a la solicitud'),
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

  void _cancelarSolicitud(SolicitudCambio solicitud) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final solicitudRepository = Provider.of<SolicitudCambioRepository>(context, listen: false);
      final success = await solicitudRepository.cancelarSolicitud(solicitud.id!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud cancelada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSolicitudes();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cancelar la solicitud'),
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

  Color _getColorForEstado(EstadoSolicitud estado) {
    switch (estado) {
      case EstadoSolicitud.PENDIENTE:
        return AppTheme.pendingColor;
      case EstadoSolicitud.ACEPTADA:
        return AppTheme.approvedColor;
      case EstadoSolicitud.RECHAZADA:
        return AppTheme.rejectedColor;
      case EstadoSolicitud.CANCELADA:
        return AppTheme.cancelledColor;
    }
  }

  void _showNuevaSolicitudDialog() {
    // Aquí implementaremos la funcionalidad para crear una nueva solicitud
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Solicitud de Cambio'),
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
        title: const Text('Solicitudes de Cambio'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mis Solicitudes'),
            Tab(text: 'Recibidas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMisSolicitudesTab(),
          _buildSolicitudesRecibidasTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNuevaSolicitudDialog,
        child: const Icon(Icons.add),
        tooltip: 'Nueva Solicitud',
      ),
    );
  }

  Widget _buildMisSolicitudesTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : FutureBuilder<List<SolicitudCambio>>(
            future: _misSolicitudesFuture,
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
              
              final solicitudes = snapshot.data ?? [];
              
              if (solicitudes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No has realizado ninguna solicitud',
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
                itemCount: solicitudes.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final solicitud = solicitudes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: _getColorForEstado(solicitud.estado),
                        child: Icon(
                          _getIconForEstado(solicitud.estado),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Solicitud a ${solicitud.destinatario?.nombreCompleto ?? 'Usuario'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Estado: ${solicitud.estado.displayName}',
                            style: TextStyle(
                              color: _getColorForEstado(solicitud.estado),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fecha: ${solicitud.fechaSolicitudFormateada}',
                          ),
                          if (solicitud.horarioOrigen != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'De: ${solicitud.horarioOrigen!.fechaFormateada} (${solicitud.horarioOrigen!.horarioFormateado})',
                            ),
                          ],
                          if (solicitud.horarioDestino != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'A: ${solicitud.horarioDestino!.fechaFormateada} (${solicitud.horarioDestino!.horarioFormateado})',
                            ),
                          ],
                          if (solicitud.mensaje != null && solicitud.mensaje!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Mensaje: ${solicitud.mensaje}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (solicitud.respuesta != null && solicitud.respuesta!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Respuesta: ${solicitud.respuesta}',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: solicitud.estado == EstadoSolicitud.ACEPTADA
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: solicitud.estado == EstadoSolicitud.PENDIENTE
                          ? IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Cancelar Solicitud'),
                                    content: const Text(
                                        '¿Está seguro de que desea cancelar esta solicitud?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('NO'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _cancelarSolicitud(solicitud);
                                        },
                                        child: const Text('SÍ'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          );
  }

  Widget _buildSolicitudesRecibidasTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : FutureBuilder<List<SolicitudCambio>>(
            future: _solicitudesRecibidasFuture,
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
              
              final solicitudes = snapshot.data ?? [];
              
              if (solicitudes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No has recibido ninguna solicitud',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Filtramos para mostrar primero las pendientes
              final pendientes = solicitudes.where((s) => s.estado == EstadoSolicitud.PENDIENTE).toList();
              final otras = solicitudes.where((s) => s.estado != EstadoSolicitud.PENDIENTE).toList();
              final ordenadas = [...pendientes, ...otras];
              
              return ListView.builder(
                itemCount: ordenadas.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final solicitud = ordenadas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: _getColorForEstado(solicitud.estado),
                        child: Icon(
                          _getIconForEstado(solicitud.estado),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Solicitud de ${solicitud.solicitante?.nombreCompleto ?? 'Usuario'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Estado: ${solicitud.estado.displayName}',
                            style: TextStyle(
                              color: _getColorForEstado(solicitud.estado),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fecha: ${solicitud.fechaSolicitudFormateada}',
                          ),
                          if (solicitud.horarioOrigen != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'De: ${solicitud.horarioOrigen!.fechaFormateada} (${solicitud.horarioOrigen!.horarioFormateado})',
                            ),
                          ],
                          if (solicitud.horarioDestino != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'A: ${solicitud.horarioDestino!.fechaFormateada} (${solicitud.horarioDestino!.horarioFormateado})',
                            ),
                          ],
                          if (solicitud.mensaje != null && solicitud.mensaje!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Mensaje: ${solicitud.mensaje}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: solicitud.estado == EstadoSolicitud.PENDIENTE
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () {
                                    _showResponderDialog(solicitud, true);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    _showResponderDialog(solicitud, false);
                                  },
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          );
  }

  void _showResponderDialog(SolicitudCambio solicitud, bool aceptar) {
    final respuestaController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(aceptar ? 'Aceptar Solicitud' : 'Rechazar Solicitud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              aceptar
                  ? '¿Está seguro de que desea aceptar esta solicitud de cambio?'
                  : '¿Está seguro de que desea rechazar esta solicitud de cambio?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: respuestaController,
              decoration: const InputDecoration(
                labelText: 'Respuesta (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _responderSolicitud(
                solicitud,
                aceptar,
                respuestaController.text.isEmpty ? null : respuestaController.text,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: aceptar ? Colors.green : Colors.red,
            ),
            child: Text(aceptar ? 'ACEPTAR' : 'RECHAZAR'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForEstado(EstadoSolicitud estado) {
    switch (estado) {
      case EstadoSolicitud.PENDIENTE:
        return Icons.schedule;
      case EstadoSolicitud.ACEPTADA:
        return Icons.check_circle;
      case EstadoSolicitud.RECHAZADA:
        return Icons.cancel;
      case EstadoSolicitud.CANCELADA:
        return Icons.block;
    }
  }
}
