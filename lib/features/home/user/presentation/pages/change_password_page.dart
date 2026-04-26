import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../widgets/profile_edit_widgets.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  bool get _canSave =>
      _currentCtrl.text.isNotEmpty &&
      _newCtrl.text.isNotEmpty &&
      _confirmCtrl.text.isNotEmpty;

  int get _strength {
    final p = _newCtrl.text;
    if (p.length < 4) return 0;
    int score = 1;
    if (p.length >= 8) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(p)) score++;
    return score;
  }

  @override
  void initState() {
    super.initState();
    _currentCtrl.addListener(() => setState(() {}));
    _newCtrl.addListener(() => setState(() {}));
    _confirmCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Senha alterada com sucesso!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          const ProfileEditHeader(
            title: 'Alterar senha',
            subtitle: 'Atualize sua senha de acesso',
            icon: Icons.lock_outline_rounded,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  const ProfileInfoCard(
                    icon: Icons.shield_outlined,
                    text:
                        'Use uma senha forte com pelo menos 8 caracteres, incluindo letras e números.',
                  ),
                  const SizedBox(height: 20),
                  ProfileFormCard(
                    children: [
                      CustomTextField(
                        label: 'Senha atual',
                        hint: 'Digite sua senha atual',
                        controller: _currentCtrl,
                        obscureText: _obscureCurrent,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: _VisibilityToggle(
                          obscure: _obscureCurrent,
                          onToggle: () => setState(
                              () => _obscureCurrent = !_obscureCurrent),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Campo obrigatório'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Nova senha',
                        hint: 'Digite a nova senha',
                        controller: _newCtrl,
                        obscureText: _obscureNew,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: _VisibilityToggle(
                          obscure: _obscureNew,
                          onToggle: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obrigatório';
                          if (v.length < 8) return 'Mínimo 8 caracteres';
                          return null;
                        },
                      ),
                      if (_newCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _PasswordStrengthBar(strength: _strength),
                      ],
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Confirmar nova senha',
                        hint: 'Confirme a nova senha',
                        controller: _confirmCtrl,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: _VisibilityToggle(
                          obscure: _obscureConfirm,
                          onToggle: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obrigatório';
                          if (v != _newCtrl.text) return 'As senhas não coincidem';
                          return null;
                        },
                        onFieldSubmitted: (_) => _canSave ? _save() : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ProfileSaveButton(
                    label: 'Salvar alterações',
                    enabled: _canSave,
                    isLoading: _isLoading,
                    onPressed: _save,
                  ),
                  const SizedBox(height: 10),
                  ProfileCancelButton(
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0–4

  const _PasswordStrengthBar({required this.strength});

  Color get _color => switch (strength) {
        1 => AppColors.error,
        2 => AppColors.warning,
        3 => const Color(0xFF84CC16),
        _ => AppColors.success,
      };

  String get _label => switch (strength) {
        1 => 'Muito fraca',
        2 => 'Fraca',
        3 => 'Boa',
        _ => 'Forte',
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final filled = i < strength;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: filled ? _color : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              'Força da senha: ',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              _label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  final bool obscure;
  final VoidCallback onToggle;
  const _VisibilityToggle({required this.obscure, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscure
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onPressed: onToggle,
    );
  }
}
