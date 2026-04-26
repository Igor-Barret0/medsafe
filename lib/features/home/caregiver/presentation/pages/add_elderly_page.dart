import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/custom_text_field.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveElderly() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = AddElderlyResult(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      contact: _phoneController.text.trim(),
      sex: _selectedSex,
      notes: _notesController.text.trim(),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Idoso salvo com sucesso.')));
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(10),
                      child: Ink(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(38),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textWhite,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adicionar idoso',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 33,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Preencha os dados do idoso',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: 'Nome completo',
                          hint: 'Ex: Maria Oliveira',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o nome completo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Idade',
                          hint: 'Ex: 74',
                          keyboardType: TextInputType.number,
                          controller: _ageController,
                          prefixIcon: const Icon(Icons.elderly_outlined),
                          validator: (value) {
                            final age = int.tryParse(value?.trim() ?? '');
                            if (age == null || age <= 0 || age > 120) {
                              return 'Informe uma idade válida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Sexo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _SexOption(
                              label: 'Masculino',
                              selected: _selectedSex == 'Masculino',
                              onTap: () =>
                                  setState(() => _selectedSex = 'Masculino'),
                            ),
                            const SizedBox(width: 8),
                            _SexOption(
                              label: 'Feminino',
                              selected: _selectedSex == 'Feminino',
                              onTap: () =>
                                  setState(() => _selectedSex = 'Feminino'),
                            ),
                            const SizedBox(width: 8),
                            _SexOption(
                              label: 'Outro',
                              selected: _selectedSex == 'Outro',
                              onTap: () =>
                                  setState(() => _selectedSex = 'Outro'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Telefone',
                          hint: '(11) 98765-4321',
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                          prefixIcon: const Icon(Icons.phone_iphone_outlined),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o telefone';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Observações médicas',
                          hint: 'Ex: Hipertensão, diabetes tipo 2...',
                          controller: _notesController,
                          maxLines: 3,
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: 18),
                        PrimaryButton(
                          label: 'Salvar idoso',
                          onPressed: _saveElderly,
                        ),
                      ],
                    ),
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

class _SexOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SexOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : const Color(0xFFE8ECF3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.textWhite : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
