import 'package:flutter/material.dart';
import 'package:gestor_horarios_app/data/providers/auth_provider.dart';
import 'package:gestor_horarios_app/presentation/auth/register/steps/account_info_step.dart';
import 'package:gestor_horarios_app/presentation/auth/register/steps/password_step.dart';
import 'package:gestor_horarios_app/presentation/auth/register/steps/personal_info_step.dart';
import 'package:gestor_horarios_app/presentation/auth/register/steps/work_info_step.dart';
import 'package:provider/provider.dart';

class RegisterProcess extends StatefulWidget {
  const RegisterProcess({super.key});

  @override
  State<RegisterProcess> createState() => _RegisterProcessState();
}

class _RegisterProcessState extends State<RegisterProcess> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isRegistering = false;
  
  // Datos de registro
  final Map<String, dynamic> _registrationData = {
    'username': '',
    'email': '',
    'nombre': '',
    'apellidos': '',
    'telefono': '',
    'rol': null,
    'localidad': '',
    'centroTrabajo': '',
    'password': '',
  };

  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Textos para la barra de paso
  final List<String> _stepTitles = [
    'Información personal',
    'Información laboral',
    'Cuenta',
    'Contraseña',
  ];

  // Indicadores de progreso
  bool _isLastPage() => _currentPage == 3;
  bool _isFirstPage() => _currentPage == 0;

  void _updateData(String key, dynamic value) {
    setState(() {
      _registrationData[key] = value;
    });
  }

  void _nextPage() {
    if (_formKeys[_currentPage].currentState!.validate()) {
      _formKeys[_currentPage].currentState!.save();
      if (_isLastPage()) {
        _register();
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _register() async {
    setState(() {
      _isRegistering = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await authProvider.register(
        username: _registrationData['username'],
        email: _registrationData['email'],
        nombre: _registrationData['nombre'],
        apellidos: _registrationData['apellidos'],
        telefono: _registrationData['telefono'],
        rol: _registrationData['rol'],
        localidad: _registrationData['localidad'],
        centroTrabajo: _registrationData['centroTrabajo'],
        password: _registrationData['password'],
      );

      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Registro exitoso. Inicie sesión para continuar.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Error al registrar. Intente nuevamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
          _isRegistering = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: _currentPage >= index 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Colors.grey,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: _currentPage >= index 
                                      ? Colors.white 
                                      : Colors.black54,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _stepTitles[index],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: _currentPage == index 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentPage + 1) / 4,
                  backgroundColor: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          PersonalInfoStep(
            formKey: _formKeys[0],
            updateData: _updateData,
            nombre: _registrationData['nombre'],
            apellidos: _registrationData['apellidos'],
            telefono: _registrationData['telefono'],
          ),
          WorkInfoStep(
            formKey: _formKeys[1],
            updateData: _updateData,
            rol: _registrationData['rol'],
            localidad: _registrationData['localidad'],
            centroTrabajo: _registrationData['centroTrabajo'],
          ),
          AccountInfoStep(
            formKey: _formKeys[2],
            updateData: _updateData,
            username: _registrationData['username'],
            email: _registrationData['email'],
          ),
          PasswordStep(
            formKey: _formKeys[3],
            updateData: _updateData,
            password: _registrationData['password'],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!_isFirstPage())
                ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('Anterior'),
                )
              else
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ElevatedButton(
                onPressed: _isRegistering ? null : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isRegistering
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(_isLastPage() ? 'Registrarse' : 'Siguiente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
