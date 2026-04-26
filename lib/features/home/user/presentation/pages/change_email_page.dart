import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../widgets/profile_edit_widgets.dart';

class ChangeEmailPage extends StatefulWidget {
  final String currentEmail;
  const ChangeEmailPage({super.key, required this.currentEmail});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailCtrl = TextEditingController();
  final _confirmEmailCtrl = TextEditingController();
  bool _isLoading = false;

  bool get _canSave =>
      _newEmailCtrl.text.isNotEmpty && _confirmEmailCtrl.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _newEmailCtrl.addListener(() => setState(() {}));
    _confirmEmailCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _newEmailCtrl.dispose();
    _confirmEmailCtrl.dispose();
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
        content: Text('Confirmação enviada para o novo e-mail!'),
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
            title: 'Alterar e-mail',
            subtitle: 'Atualize seu endereço de e-mail',
            icon: Icons.email_outlined,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  const ProfileInfoCard(
                    icon: Icons.info_outline_rounded,
                    text:
                        'Você receberá um e-mail de confirmação no novo endereço antes da alteração ser concluída.',
                  ),
                  const SizedBox(height: 20),
                  ProfileFormCard(
                    children: [
                      // Current email — read-only
                      _ReadOnlyField(
                        label: 'E-mail atual',
                        value: widget.currentEmail,
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Novo e-mail',
                        hint: 'Digite o novo e-mail',
                        controller: _newEmailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obrigatório';
                          if (!EmailValidator.validate(v.trim())) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Confirmar novo e-mail',
                        hint: 'Confirme o novo e-mail',
                        controller: _confirmEmailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obrigatório';
                          if (v.trim() != _newEmailCtrl.text.trim()) {
                            return 'Os e-mails não coincidem';
                          }
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

// ── Shared helpers ────────────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
