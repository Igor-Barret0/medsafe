import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import 'widgets/auth_header.dart';

class CaregiverRegisterPage extends StatefulWidget {
  const CaregiverRegisterPage({super.key});

  @override
  State<CaregiverRegisterPage> createState() => _CaregiverRegisterPageState();
}

enum _Relationship { filho, neto, profissional, outro }

class _CaregiverRegisterPageState extends State<CaregiverRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'\d')},
  );

  _Relationship _relationship = _Relationship.filho;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _lgpd = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_lgpd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aceite os termos para continuar.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _CaregiverSuccessPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          AuthHeader(
            title: 'Cadastro do cuidador',
            subtitle: 'Crie sua conta para acompanhar o tratamento do idoso.',
            showBackButton: true,
            customIcon: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.health_and_safety_outlined,
                size: 32,
                color: AppColors.textWhite,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _nameCtrl,
                      label: 'Nome completo',
                      hint: 'Maria da Silva',
                      prefixIcon: const Icon(Icons.person_outline_rounded,
                          color: AppColors.textSecondary),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Campo obrigatório.' : null,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _emailCtrl,
                      label: 'E-mail',
                      hint: 'maria@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: AppColors.textSecondary),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Campo obrigatório.' : null,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _phoneCtrl,
                      label: 'Telefone',
                      hint: '(11) 98765-4321',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_phoneMask],
                      prefixIcon: const Icon(Icons.phone_outlined,
                          color: AppColors.textSecondary),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Campo obrigatório.' : null,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _passwordCtrl,
                      label: 'Senha',
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _confirmCtrl,
                      label: 'Confirmar senha',
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) => v != _passwordCtrl.text
                          ? 'As senhas não coincidem.'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Relacionamento com o idoso',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _Relationship.values.map((r) {
                        final selected = _relationship == r;
                        final label = switch (r) {
                          _Relationship.filho => 'Filho(a)',
                          _Relationship.neto => 'Neto(a)',
                          _Relationship.profissional => 'Cuidador(a) profissional',
                          _Relationship.outro => 'Outro',
                        };
                        return GestureDetector(
                          onTap: () => setState(() => _relationship = r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.backgroundWhite,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.inputBorder,
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.textWhite
                                    : AppColors.textSecondary,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => setState(() => _lgpd = !_lgpd),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _lgpd
                              ? AppColors.primary.withAlpha(12)
                              : AppColors.backgroundWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _lgpd
                                ? AppColors.primary.withAlpha(80)
                                : AppColors.inputBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _lgpd
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _lgpd
                                      ? AppColors.primary
                                      : AppColors.inputBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: _lgpd
                                  ? const Icon(Icons.check_rounded,
                                      size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(text: 'Concordo com os '),
                                    TextSpan(
                                      text: 'termos de uso',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(text: ' e '),
                                    TextSpan(
                                      text: 'política de privacidade',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Criar conta'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text(
                          'Já tenho uma conta',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
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

class _CaregiverSuccessPage extends StatelessWidget {
  const _CaregiverSuccessPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          AuthHeader(
            title: 'Cadastro realizado\ncom sucesso!',
            subtitle: 'Bem-vindo(a) ao Medisafe',
            customIcon: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 34,
                color: AppColors.textWhite,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conta criada',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Agora você pode acompanhar o tratamento do idoso e receber alertas de medicamentos.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go(AppRoutes.login),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Ir para login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
