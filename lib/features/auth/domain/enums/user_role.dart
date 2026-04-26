enum UserRole {
  usuario,
  cuidador,
  admin;

  String get label {
    switch (this) {
      case UserRole.usuario:
        return 'Usuário (Paciente)';
      case UserRole.cuidador:
        return 'Cuidador';
      case UserRole.admin:
        return 'Administrador';
    }
  }

  String get value {
    switch (this) {
      case UserRole.usuario:
        return 'usuario';
      case UserRole.cuidador:
        return 'cuidador';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'cuidador':
        return UserRole.cuidador;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.usuario;
    }
  }
}
