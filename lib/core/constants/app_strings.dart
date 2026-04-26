class AppStrings {
  AppStrings._();

  static const String appName = 'Medisafe';
  static const String appTagline = 'Seu cuidado, no horário certo';

  // Onboarding
  static const List<Map<String, String>> onboardingData = [
    {
      'title': 'Nunca mais esqueça\nsua medicação',
      'subtitle': 'Gerencie todos os seus medicamentos em um\nsó lugar com facilidade.',
    },
    {
      'title': 'Alertas inteligentes\ne repetitivos',
      'subtitle': 'Receba notificações no horário certo e\nconfirme com um toque.',
    },
    {
      'title': 'Seu cuidador\nsempre informado',
      'subtitle': 'Notifique automaticamente quem você ama\nquando precisar de ajuda.',
    },
  ];

  // Auth
  static const String loginTitle = 'Acesse sua conta';
  static const String emailLabel = 'E-mail';
  static const String emailHint = 'igor@email.com';
  static const String passwordLabel = 'Senha';
  static const String forgotPassword = 'Esqueci a senha';
  static const String loginButton = 'Entrar';
  static const String orSeparator = 'ou';
  static const String createAccount = 'Criar conta';

  // Forgot Password
  static const String forgotPasswordTitle = 'Recuperar Senha';
  static const String forgotPasswordSubtitle = 'Redefinição de acesso';
  static const String forgotPasswordDescription =
      'Digite seu e-mail cadastrado e enviaremos\num link para redefinir sua senha.';
  static const String sendInstructions = 'Enviar instruções';
  static const String backToLogin = 'Voltar para o login';

  // Register
  static const String registerTitle = 'Criar conta';
  static const String registerSubtitle = 'Preencha seus dados';
  static const String fullNameLabel = 'Nome completo';
  static const String fullNameHint = 'Igor Silva';
  static const String confirmPasswordLabel = 'Confirmar senha';
  static const String phoneLabel = 'Telefone';
  static const String phoneHint = '(11) 99999-9999';
  static const String roleLabel = 'Tipo de conta';
  static const String lgpdConsent =
      'Concordo com os Termos de Uso e autorizo o tratamento dos meus dados conforme a LGPD.';
  static const String termsOfUse = 'Termos de Uso';
  static const String lgpd = 'LGPD';
  static const String registerButton = 'Criar conta';

  // Validation
  static const String fieldRequired = 'Campo obrigatório';
  static const String invalidEmail = 'E-mail inválido';
  static const String passwordMinLength = 'Mínimo 8 caracteres';
  static const String passwordsDoNotMatch = 'As senhas não coincidem';
  static const String invalidPhone = 'Telefone inválido';
  static const String lgpdRequired = 'Você deve aceitar os termos para continuar';
  static const String fullNameMinLength = 'Informe o nome completo';

  // Roles
  static const String roleUser = 'Usuário (Paciente)';
  static const String roleCaregiver = 'Cuidador';
  static const String roleAdmin = 'Administrador';

  // Navigation
  static const String next = 'Próximo';
  static const String start = 'Começar';
  static const String skip = 'Pular';

  // Home
  static const String homeTitle = 'Meus Medicamentos';
  static const String caregiverHomeTitle = 'Pacientes Monitorados';
  static const String adminHomeTitle = 'Painel Administrativo';

  // Errors
  static const String genericError = 'Ocorreu um erro. Tente novamente.';
  static const String networkError = 'Sem conexão. Verifique sua internet.';
  static const String invalidCredentials = 'E-mail ou senha incorretos.';
  static const String emailAlreadyInUse = 'Este e-mail já está cadastrado.';
  static const String weakPassword = 'Senha muito fraca. Use pelo menos 8 caracteres.';
}
