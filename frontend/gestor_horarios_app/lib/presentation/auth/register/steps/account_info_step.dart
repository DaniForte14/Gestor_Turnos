import 'package:flutter/material.dart';

class AccountInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Function(String, dynamic) updateData;
  final String username;
  final String? email;

  const AccountInfoStep({
    super.key,
    required this.formKey,
    required this.updateData,
    required this.username,
    this.email,
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
                'Información de Cuenta',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Establece un nombre de usuario único para tu cuenta. Esto será lo que utilizarás para iniciar sesión.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              _buildUsernameField(),
              const SizedBox(height: 16),
              _buildEmailField(),
              const SizedBox(height: 24),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      initialValue: username,
      decoration: InputDecoration(
        labelText: 'Nombre de usuario',
        hintText: 'Cree un nombre de usuario único',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.account_circle),
      ),
      keyboardType: TextInputType.text,
      autocorrect: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese un nombre de usuario';
        }
        if (value.length < 4) {
          return 'El nombre de usuario debe tener al menos 4 caracteres';
        }
        if (value.contains(' ')) {
          return 'El nombre de usuario no puede contener espacios';
        }
        return null;
      },
      onSaved: (value) {
        updateData('username', value);
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      initialValue: email,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'Ingrese su correo electrónico',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese un correo electrónico';
        }
        // Validación simple de formato de email
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegex.hasMatch(value)) {
          return 'Por favor ingrese un correo electrónico válido';
        }
        return null;
      },
      onSaved: (value) {
        updateData('email', value);
      },
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Recomendaciones',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• Elija un nombre de usuario fácil de recordar pero difícil de adivinar',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 6),
            const Text(
              '• No utilice información personal fácilmente identificable',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 6),
            const Text(
              '• Use una combinación de letras y números para mayor seguridad',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
