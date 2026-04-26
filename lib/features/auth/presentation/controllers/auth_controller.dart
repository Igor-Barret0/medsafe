import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/enums/user_role.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });
}

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthController extends ChangeNotifier {
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyUserPhone = 'user_phone';
  static const _keyUserRole = 'user_role';
  static const _keyOnboardingDone = 'onboarding_done';

  AuthStatus _status = AuthStatus.initial;
  AuthUser? _currentUser;
  String? _errorMessage;
  bool _onboardingCompleted = false;

  AuthStatus get status => _status;
  AuthUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingCompleted = prefs.getBool(_keyOnboardingDone) ?? false;

    final userId = prefs.getString(_keyUserId);
    if (userId != null) {
      _currentUser = AuthUser(
        id: userId,
        name: prefs.getString(_keyUserName) ?? '',
        email: prefs.getString(_keyUserEmail) ?? '',
        phone: prefs.getString(_keyUserPhone) ?? '',
        role: UserRole.fromString(prefs.getString(_keyUserRole) ?? 'usuario'),
      );
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
    _onboardingCompleted = true;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 1200));

      // TODO: replace with real API call
      if (email.isEmpty || password.length < 8) {
        _errorMessage = 'E-mail ou senha incorretos.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final role = _resolveRoleFromEmail(email);
      _currentUser = AuthUser(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Usuário',
        email: email,
        phone: '',
        role: role,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, _currentUser!.id);
      await prefs.setString(_keyUserName, _currentUser!.name);
      await prefs.setString(_keyUserEmail, email);
      await prefs.setString(_keyUserPhone, '');
      await prefs.setString(_keyUserRole, role.value);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Ocorreu um erro. Tente novamente.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      // TODO: replace with real API call
      _currentUser = AuthUser(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        role: role,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, _currentUser!.id);
      await prefs.setString(_keyUserName, name);
      await prefs.setString(_keyUserEmail, email);
      await prefs.setString(_keyUserPhone, phone);
      await prefs.setString(_keyUserRole, role.value);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Ocorreu um erro ao criar a conta. Tente novamente.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset({required String email}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      // TODO: replace with real API call
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível enviar o e-mail. Tente novamente.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserRole);
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  UserRole _resolveRoleFromEmail(String email) {
    if (email.contains('admin')) return UserRole.admin;
    if (email.contains('cuidador')) return UserRole.cuidador;
    return UserRole.usuario;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
