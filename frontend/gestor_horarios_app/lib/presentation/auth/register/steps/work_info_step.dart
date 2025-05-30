import 'package:flutter/material.dart';

class WorkInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Function(String, dynamic) updateData;
  final String? rol;
  final String localidad;
  final String centroTrabajo;

  const WorkInfoStep({
    super.key,
    required this.formKey,
    required this.updateData,
    required this.rol,
    required this.localidad,
    required this.centroTrabajo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información Laboral',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Información sobre tu posición y ubicación de trabajo. Esto nos ayudará a configurar correctamente tu perfil.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              _buildRoleDropdown(),
              const SizedBox(height: 16),
              _buildLocalidadField(),
              const SizedBox(height: 16),
              _buildCentroTrabajoField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: rol,
      decoration: InputDecoration(
        labelText: 'Rol',
        hintText: 'Seleccione su rol',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.work),
      ),
      items: [
        DropdownMenuItem<String>(
          value: 'ROLE_MEDICO',
          child: Row(
            children: [
              Icon(Icons.medical_services, color: Colors.blue[700], size: 20),
              const SizedBox(width: 10),
              const Text('Médico'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'ROLE_ENFERMERO',
          child: Row(
            children: [
              Icon(Icons.healing, color: Colors.green[700], size: 20),
              const SizedBox(width: 10),
              const Text('Enfermero'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'ROLE_TCAE',
          child: Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.orange[700], size: 20),
              const SizedBox(width: 10),
              const Text('TCAE'),
            ],
          ),
        ),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor seleccione un rol';
        }
        return null;
      },
      onChanged: (value) {
        updateData('rol', value);
      },
      onSaved: (value) {
        updateData('rol', value);
      },
    );
  }

  Widget _buildLocalidadField() {
    return TextFormField(
      initialValue: localidad,
      decoration: InputDecoration(
        labelText: 'Localidad',
        hintText: 'Ingrese su localidad',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.location_city),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su localidad';
        }
        return null;
      },
      onSaved: (value) {
        updateData('localidad', value);
      },
    );
  }

  Widget _buildCentroTrabajoField() {
    return TextFormField(
      initialValue: centroTrabajo,
      decoration: InputDecoration(
        labelText: 'Centro de trabajo',
        hintText: 'Ingrese su centro de trabajo',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.business),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su centro de trabajo';
        }
        return null;
      },
      onSaved: (value) {
        updateData('centroTrabajo', value);
      },
    );
  }
}
