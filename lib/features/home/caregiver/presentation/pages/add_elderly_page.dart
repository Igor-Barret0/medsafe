import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../user/presentation/widgets/profile_edit_widgets.dart';

class AddElderlyResult {
  final String name;
  final int age;
  final String contact;
  final String sex;
  final String notes;

  const AddElderlyResult({
    required this.name,
    required this.age,
    required this.contact,
    required this.sex,
    required this.notes,
  });
}

class AddElderlyPage extends StatefulWidget {
  const AddElderlyPage({super.key});

  @override
  State<AddElderlyPage> createState() => _AddElderlyPageState();
}

class _AddElderlyPageState extends State<AddElderlyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedSex = 'Masculino';
  bool _saving = false;

  bool get _canSave {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final phone = _phoneController.text.trim();
    return name.isNotEmpty && age != null && age > 0 && age <= 120 && phone.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onChanged);
    _ageController.addListener(_onChanged);
    _phoneController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveElderly() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final result = AddElderlyResult(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      contact: _phoneController.text.trim(),
      sex: _selectedSex,
      notes: _notesController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Idoso adicionado com sucesso!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          ProfileEditHeader(
            title: 'Adicionar idoso',
            subtitle: 'Preencha os dados do idoso',
            icon: Icons.person_add_rounded,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileInfoCard(
                      icon: Icons.info_outline_rounded,
                      text:
                          'Informe os dados básicos do idoso. Medicamentos e rotinas podem ser adicionados depois.',
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel(label: 'Informações pessoais'),
                    const SizedBox(height: 10),
                    ProfileFormCard(
                      children: [
                        CustomTextField(
                          label: 'Nome completo',
                          hint: 'Ex: Maria Oliveira',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Informe o nome completo';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'Idade',
                          hint: 'Ex: 74',
                          keyboardType: TextInputType.number,
                          controller: _ageController,
                          prefixIcon: const Icon(Icons.cake_outlined),
                          validator: (v) {
                            final age = int.tryParse(v?.trim() ?? '');
                            if (age == null || age <= 0 || age > 120) return 'Informe uma idade válida';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sexo',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _SexOption(
                              label: 'Masculino',
                              icon: Icons.male_rounded,
                              selected: _selectedSex == 'Masculino',
                              onTap: () => setState(() => _selectedSex = 'Masculino'),
                            ),
                            const SizedBox(width: 8),
                            _SexOption(
                              label: 'Feminino',
                              icon: Icons.female_rounded,
                              selected: _selectedSex == 'Feminino',
                              onTap: () => setState(() => _selectedSex = 'Feminino'),
                            ),
                            const SizedBox(width: 8),
                            _SexOption(
                              label: 'Outro',
                              icon: Icons.people_outline_rounded,
                              selected: _selectedSex == 'Outro',
                              onTap: () => setState(() => _selectedSex = 'Outro'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionLabel(label: 'Contato e observações'),
                    const SizedBox(height: 10),
                    ProfileFormCard(
                      children: [
                        CustomTextField(
                          label: 'Telefone de contato',
                          hint: '(11) 98765-4321',
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                          prefixIcon: const Icon(Icons.phone_iphone_outlined),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Informe o telefone';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          label: 'Observações médicas',
                          hint: 'Ex: Hipertensão, diabetes tipo 2, alergias...',
                          controller: _notesController,
                          maxLines: 3,
                          textInputAction: TextInputAction.newline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ProfileSaveButton(
                        label: 'Salvar idoso',
                        enabled: _canSave,
                        isLoading: _saving,
                        onPressed: _saveElderly,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ProfileCancelButton(onPressed: () => Navigator.of(context).pop()),
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

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
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
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

// ── Sex option chip ───────────────────────────────────────────────────────────

class _SexOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SexOption({
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
          height: 60,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? Colors.transparent : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(60),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
