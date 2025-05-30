import 'package:flutter/material.dart';

class PasswordStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(String, dynamic) updateData;
  final String password;

  const PasswordStep({
    super.key,
    required this.formKey,
    required this.updateData,
    required this.password,
  });

  @override
  State<PasswordStep> createState() => _PasswordStepState();
}

class _PasswordStepState extends State<PasswordStep> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController.text = widget.password;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crea una Contraseña',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Establece una contraseña segura para proteger tu cuenta. Asegúrate de que sea difícil de adivinar pero fácil de recordar.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildConfirmPasswordField(),
              const SizedBox(height: 24),
              _buildPasswordStrengthIndicator(),
              const SizedBox(height: 16),
              _buildPasswordRequirements(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: 'Cree una contraseña segura',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese una contraseña';
        }
        if (value.length < 8) {
          return 'La contraseña debe tener al menos 8 caracteres';
        }
        if (!_hasUpperCase(value)) {
          return 'La contraseña debe tener al menos una letra mayúscula';
        }
        if (!_hasLowerCase(value)) {
          return 'La contraseña debe tener al menos una letra minúscula';
        }
        if (!_hasNumber(value)) {
          return 'La contraseña debe tener al menos un número';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {});
        widget.updateData('password', value);
      },
      onSaved: (value) {
        widget.updateData('password', value);
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        labelText: 'Confirmar contraseña',
        hintText: 'Repita su contraseña',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      obscureText: _obscureConfirmPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor confirme su contraseña';
        }
        if (value != _passwordController.text) {
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final String password = _passwordController.text;
    double strength = 0;
    String label = 'Muy débil';
    Color color = Colors.red;

    if (password.length >= 8) strength += 0.25;
    if (_hasUpperCase(password) && _hasLowerCase(password)) strength += 0.25;
    if (_hasNumber(password)) strength += 0.25;
    if (_hasSpecialCharacter(password)) strength += 0.25;

    if (strength <= 0.25) {
      label = 'Muy débil';
      color = Colors.red;
    } else if (strength <= 0.5) {
      label = 'Débil';
      color = Colors.orange;
    } else if (strength <= 0.75) {
      label = 'Buena';
      color = Colors.yellow[700]!;
    } else {
      label = 'Fuerte';
      color = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Seguridad de la contraseña:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: strength,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final String password = _passwordController.text;
    
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Requisitos de la contraseña:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            _buildRequirementRow(
              'Al menos 8 caracteres',
              password.length >= 8,
            ),
            const SizedBox(height: 8),
            _buildRequirementRow(
              'Al menos una letra mayúscula',
              _hasUpperCase(password),
            ),
            const SizedBox(height: 8),
            _buildRequirementRow(
              'Al menos una letra minúscula',
              _hasLowerCase(password),
            ),
            const SizedBox(height: 8),
            _buildRequirementRow(
              'Al menos un número',
              _hasNumber(password),
            ),
            const SizedBox(height: 8),
            _buildRequirementRow(
              'Caracteres especiales (recomendado)',
              _hasSpecialCharacter(password),
              isRequired: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet, {bool isRequired = true}) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : (isRequired ? Icons.cancel : Icons.circle_outlined),
          color: isMet ? Colors.green : (isRequired ? Colors.red : Colors.grey),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isMet ? Colors.green : (isRequired ? Colors.red : Colors.grey),
          ),
        ),
      ],
    );
  }

  bool _hasUpperCase(String value) => RegExp(r'[A-Z]').hasMatch(value);
  bool _hasLowerCase(String value) => RegExp(r'[a-z]').hasMatch(value);
  bool _hasNumber(String value) => RegExp(r'[0-9]').hasMatch(value);
  bool _hasSpecialCharacter(String value) => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
}
