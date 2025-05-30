enum Role {
  ROLE_MEDICO,
  ROLE_ENFERMERO,
  ROLE_TCAE,
  ROLE_ADMIN,
}

extension RoleExtension on Role {
  String get displayName {
    switch (this) {
      case Role.ROLE_MEDICO:
        return 'Médico';
      case Role.ROLE_ENFERMERO:
        return 'Enfermero';
      case Role.ROLE_TCAE:
        return 'TCAE';
      case Role.ROLE_ADMIN:
        return 'Administrador';
    }
  }

  String get value {
    return toString().split('.').last;
  }
}
