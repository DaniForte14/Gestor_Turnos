import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonalInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Function(String, dynamic) updateData;
  final String nombre;
  final String apellidos;
  final String telefono;

  const PersonalInfoStep({
    super.key,
    required this.formKey,
    required this.updateData,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
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
                'Información Personal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Cuéntanos sobre ti. Esta información nos ayudará a identificarte en el sistema.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              _buildNombreField(),
              const SizedBox(height: 16),
              _buildApellidosField(),
              const SizedBox(height: 16),
              _buildTelefonoField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNombreField() {
    return TextFormField(
      initialValue: nombre,
      decoration: InputDecoration(
        labelText: 'Nombre',
        hintText: 'Ingrese su nombre',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.person),
      ),
      textCapitalization: TextCapitalization.words,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su nombre';
        }
        if (value.length < 2) {
          return 'El nombre debe tener al menos 2 caracteres';
        }
        return null;
      },
      onSaved: (value) {
        updateData('nombre', value);
      },
    );
  }

  Widget _buildApellidosField() {
    return TextFormField(
      initialValue: apellidos,
      decoration: InputDecoration(
        labelText: 'Apellidos',
        hintText: 'Ingrese sus apellidos',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.person_outline),
      ),
      textCapitalization: TextCapitalization.words,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese sus apellidos';
        }
        if (value.length < 2) {
          return 'Los apellidos deben tener al menos 2 caracteres';
        }
        return null;
      },
      onSaved: (value) {
        updateData('apellidos', value);
      },
    );
  }

  Widget _buildTelefonoField() {
    return TextFormField(
      initialValue: telefono,
      decoration: InputDecoration(
        labelText: 'Número de teléfono',
        hintText: 'Ingrese su número de teléfono',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.phone),
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su número de teléfono';
        }
        if (value.length != 9) {
          return 'El número de teléfono debe tener 9 dígitos';
        }
        return null;
      },
      onSaved: (value) {
        updateData('telefono', value);
      },
    );
  }
}
