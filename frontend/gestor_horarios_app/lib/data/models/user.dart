class User {
  final int id;
  final String username;
  final String email;
  final String nombre;
  final String apellidos;
  final List<String> roles;
  final bool isAdmin;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.nombre,
    required this.apellidos,
    this.roles = const ['USER'],
    bool? isAdmin,
  }) : isAdmin = isAdmin ?? (roles.any((role) => role.toUpperCase() == 'ROLE_ADMIN'));

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      roles: List<String>.from(json['roles'] ?? ['USER']),
      isAdmin: json['isAdmin'] ?? json['roles']?.contains('ROLE_ADMIN') ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nombre': nombre,
      'apellidos': apellidos,
      'roles': roles,
    };
  }

  String get nombreCompleto {
    return '$nombre $apellidos'.trim();
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? nombre,
    String? apellidos,
    List<String>? roles,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      roles: roles ?? this.roles,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, nombre: $nombre, apellidos: $apellidos, roles: $roles, isAdmin: $isAdmin)';
  }
}
