import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import 'password_changed_page.dart';
import 'widgets/auth_header.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  int get _passwordStrength {
    final p = _passwordCtrl.text;
    if (p.length < 8) return 0;
    final hasUpper = p.contains(RegExp(r'[A-Z]'));
    final hasNumber = p.contains(RegExp(r'[0-9]'));
    final hasSpecial = p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    if ((hasUpper && hasNumber) || hasSpecial) return 3;
    if (hasUpper || hasNumber) return 2;
    return 1;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PasswordChangedPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          AuthHeader(
            title: 'Criar nova senha',
            subtitle: 'Escolha uma senha forte para proteger sua conta.',
            showBackButton: true,
            customIcon: const Icon(
              Icons.lock_reset_rounded,
              size: 34,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AuthCard(
                      children: [
                        CustomTextField(
                          controller: _passwordCtrl,
                          label: 'Nova senha',
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                            if (v.length < 8) return AppStrings.passwordMinLength;
                            return null;
                          },
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).nextFocus(),
                        ),
                        const SizedBox(height: 12),
                        _PasswordStrengthBar(strength: _passwordStrength),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _confirmCtrl,
                          label: 'Confirmar nova senha',
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                            if (v != _passwordCtrl.text) return AppStrings.passwordsDoNotMatch;
                            return null;
                          },
                          onFieldSubmitted: (_) => _save(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _GradientButton(
                      label: 'Salvar nova senha',
                      icon: Icons.save_rounded,
                      isLoading: _isLoading,
                      onTap: _save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0–3

  const _PasswordStrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    if (strength == 0) return const SizedBox.shrink();

    const labels = ['', 'Fraca', 'Média', 'Forte'];
    const colors = [
      Colors.transparent,
      AppColors.error,
      AppColors.warning,
      AppColors.success,
    ];

    return Row(
      children: [
        ...List.generate(
          3,
          (i) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
              decoration: BoxDecoration(
                color: i < strength
                    ? colors[strength]
                    : Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          labels[strength],
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors[strength],
          ),
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _AuthCard extends StatelessWidget {
  final List<Widget> children;
  const _AuthCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(7),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(70),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
