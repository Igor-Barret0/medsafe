import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../../domain/enums/user_role.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import 'widgets/auth_header.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _lgpdAccepted = false;
  UserRole _selectedRole = UserRole.usuario;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_lgpdAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text(AppStrings.lgpdRequired)),
          ]),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    final auth = context.read<AuthController>();
    final success = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      phone: _phoneMask.getUnmaskedText(),
      role: _selectedRole,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(auth.errorMessage ?? AppStrings.genericError)),
          ]),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<AuthController>().status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          AuthHeader(
            title: AppStrings.registerTitle,
            subtitle: AppStrings.registerSubtitle,
            showBackButton: true,
            customIcon: const Icon(
              Icons.person_add_rounded,
              size: 34,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Dados pessoais ─────────────────────────────────
                    _SectionLabel(label: 'Dados pessoais'),
                    const SizedBox(height: 10),
                    _AuthCard(
                      children: [
                        CustomTextField(
                          label: AppStrings.fullNameLabel,
                          hint: AppStrings.fullNameHint,
                          controller: _nameCtrl,
                          prefixIcon:
                              const Icon(Icons.person_outline_rounded),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
                            if (v.trim().split(' ').length < 2) return AppStrings.fullNameMinLength;
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: AppStrings.emailLabel,
                          hint: AppStrings.emailHint,
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (v) {
                            if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                            if (!EmailValidator.validate(v.trim())) return AppStrings.invalidEmail;
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: AppStrings.phoneLabel,
                          hint: AppStrings.phoneHint,
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          prefixIcon:
                              const Icon(Icons.phone_iphone_outlined),
                          inputFormatters: [_phoneMask],
                          validator: (v) {
                            if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                            if (_phoneMask.getUnmaskedText().length < 10) return AppStrings.invalidPhone;
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Tipo de conta ──────────────────────────────────
                    _SectionLabel(label: 'Tipo de conta'),
                    const SizedBox(height: 10),
                    _RoleChips(
                      selected: _selectedRole,
                      onChanged: (r) => setState(() => _selectedRole = r),
                    ),
                    const SizedBox(height: 16),

                    // ── Senha ──────────────────────────────────────────
                    _SectionLabel(label: 'Segurança'),
                    const SizedBox(height: 10),
                    _AuthCard(
                      children: [
                        CustomTextField(
                          label: AppStrings.passwordLabel,
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          prefixIcon:
                              const Icon(Icons.lock_outline_rounded),
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
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: AppStrings.confirmPasswordLabel,
                          controller: _confirmPasswordCtrl,
                          obscureText: _obscureConfirm,
                          prefixIcon:
                              const Icon(Icons.lock_outline_rounded),
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── LGPD ───────────────────────────────────────────
                    _LgpdCheckbox(
                      accepted: _lgpdAccepted,
                      onChanged: (v) =>
                          setState(() => _lgpdAccepted = v ?? false),
                    ),
                    const SizedBox(height: 20),

                    // ── Submit ─────────────────────────────────────────
                    _GradientButton(
                      label: AppStrings.registerButton,
                      icon: Icons.check_rounded,
                      isLoading: isLoading,
                      onTap: _submit,
                    ),
                    const SizedBox(height: 8),
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

// ── Role chips ────────────────────────────────────────────────────────────────

class _RoleChips extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  const _RoleChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoleChip(
          label: 'Paciente',
          icon: Icons.person_outline_rounded,
          selected: selected == UserRole.usuario,
          onTap: () => onChanged(UserRole.usuario),
        ),
        const SizedBox(width: 10),
        _RoleChip(
          label: 'Cuidador',
          icon: Icons.favorite_outline_rounded,
          selected: selected == UserRole.cuidador,
          onTap: () => onChanged(UserRole.cuidador),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 64,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : AppColors.inputBorder,
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── LGPD checkbox ─────────────────────────────────────────────────────────────

class _LgpdCheckbox extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool?> onChanged;

  const _LgpdCheckbox({required this.accepted, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!accepted),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: accepted ? AppColors.primary.withAlpha(10) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accepted
                ? AppColors.primary.withAlpha(100)
                : AppColors.inputBorder,
            width: accepted ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: accepted,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Concordo com os '),
                      TextSpan(
                        text: AppStrings.termsOfUse,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(
                          text:
                              ' e autorizo o tratamento dos meus dados conforme a '),
                      TextSpan(
                        text: AppStrings.lgpd,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

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
