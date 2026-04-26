import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../domain/medication.dart';

class MedicationEditorResult {
  final int index;
  final Medication medication;

  const MedicationEditorResult({required this.index, required this.medication});
}

class AddMedicationPage extends StatefulWidget {
  final List<Medication> existingMedications;

  const AddMedicationPage({
    super.key,
    this.existingMedications = const <Medication>[],
  });

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _caregiverNameCtrl = TextEditingController();
  final _caregiverPhoneCtrl = TextEditingController();

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  int _selectedHour = 8;
  int _selectedMinute = 0;
  MedicationFrequency _frequency = MedicationFrequency.diario;
  AlertInterval _alertInterval = AlertInterval.cincoMin;
  MaxAttempts _maxAttempts = MaxAttempts.tres;
  int _selectedMedicationIndex = -1;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  bool get _isEditMode => widget.existingMedications.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedMinute);

    if (_isEditMode) {
      _selectedMedicationIndex = 0;
      _fillFromMedication(widget.existingMedications[0]);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _caregiverNameCtrl.dispose();
    _caregiverPhoneCtrl.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final med = Medication(
      id: _isEditMode
          ? widget.existingMedications[_selectedMedicationIndex].id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      dose: _doseCtrl.text.trim(),
      time: TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
      status: _isEditMode
          ? widget.existingMedications[_selectedMedicationIndex].status
          : MedicationStatus.pendente,
      frequency: _frequency,
      alertInterval: _alertInterval,
      maxAttempts: _maxAttempts,
      caregiverName: _caregiverNameCtrl.text.trim().isEmpty
          ? null
          : _caregiverNameCtrl.text.trim(),
      caregiverPhone: _caregiverPhoneCtrl.text.trim().isEmpty
          ? null
          : _caregiverPhoneCtrl.text.trim(),
      stockRemaining: widget.existingMedications.isNotEmpty
          ? widget.existingMedications[_selectedMedicationIndex].stockRemaining
          : null,
    );

    if (_isEditMode) {
      Navigator.of(context).pop(
        MedicationEditorResult(
          index: _selectedMedicationIndex,
          medication: med,
        ),
      );
      return;
    }

    Navigator.of(context).pop(med);
  }

  void _fillFromMedication(Medication med) {
    _nameCtrl.text = med.name;
    _doseCtrl.text = med.dose;
    _caregiverNameCtrl.text = med.caregiverName ?? '';
    _caregiverPhoneCtrl.text = med.caregiverPhone ?? '';

    _selectedHour = med.time.hour;
    _selectedMinute = med.time.minute;
    _frequency = med.frequency;
    _alertInterval = med.alertInterval;
    _maxAttempts = med.maxAttempts;

    if (_hourController.hasClients) _hourController.jumpToItem(_selectedHour);
    if (_minuteController.hasClients) {
      _minuteController.jumpToItem(_selectedMinute);
    }
  }

  void _selectMedicationAt(int index) {
    if (index < 0 || index >= widget.existingMedications.length) return;
    setState(() {
      _selectedMedicationIndex = index;
      _fillFromMedication(widget.existingMedications[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _AddMedHeader(isEditMode: _isEditMode),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  if (_isEditMode) ...[
                    _SectionCard(
                      icon: Icons.list_alt_rounded,
                      title: 'Medicamentos',
                      children: _buildSelectableMedications(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Medicamento ──────────────────────────────────────────
                  _SectionCard(
                    icon: Icons.medication_rounded,
                    title: 'Informações do medicamento',
                    children: [
                      CustomTextField(
                        label: 'Nome do medicamento',
                        hint: 'Ex: Losartana',
                        controller: _nameCtrl,
                        prefixIcon: const Icon(Icons.medication_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Campo obrigatório'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Dose',
                        hint: 'Ex: 50mg — 1 comprimido',
                        controller: _doseCtrl,
                        prefixIcon:
                            const Icon(Icons.add_circle_outline_rounded),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Campo obrigatório'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _TimePickerField(
                        selectedHour: _selectedHour,
                        selectedMinute: _selectedMinute,
                        hourController: _hourController,
                        minuteController: _minuteController,
                        onHourChanged: (h) =>
                            setState(() => _selectedHour = h),
                        onMinuteChanged: (m) =>
                            setState(() => _selectedMinute = m),
                      ),
                      const SizedBox(height: 16),
                      _StyledDropdown<MedicationFrequency>(
                        label: 'Frequência',
                        icon: Icons.calendar_today_outlined,
                        value: _frequency,
                        items: MedicationFrequency.values,
                        labelOf: (e) => e.label,
                        onChanged: (v) =>
                            setState(() => _frequency = v!),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Alertas ──────────────────────────────────────────────
                  _SectionCard(
                    icon: Icons.notifications_outlined,
                    title: 'Configurações do alerta',
                    children: [
                      _ChipGroupLabel(
                        icon: Icons.timer_outlined,
                        label: 'Intervalo entre alertas',
                      ),
                      const SizedBox(height: 10),
                      _ChipSelector<AlertInterval>(
                        options: AlertInterval.values,
                        selected: _alertInterval,
                        labelOf: (e) => switch (e) {
                          AlertInterval.cincoMin => '5 min',
                          AlertInterval.dezMin => '10 min',
                          AlertInterval.quinzeMin => '15 min',
                          AlertInterval.trintaMin => '30 min',
                          AlertInterval.umaHora => '1 hora',
                        },
                        onChanged: (v) =>
                            setState(() => _alertInterval = v),
                      ),
                      const SizedBox(height: 18),
                      _ChipGroupLabel(
                        icon: Icons.repeat_rounded,
                        label: 'Máximo de tentativas',
                      ),
                      const SizedBox(height: 10),
                      _ChipSelector<MaxAttempts>(
                        options: MaxAttempts.values,
                        selected: _maxAttempts,
                        labelOf: (e) => switch (e) {
                          MaxAttempts.uma => '1×',
                          MaxAttempts.duas => '2×',
                          MaxAttempts.tres => '3×',
                          MaxAttempts.quatro => '4×',
                          MaxAttempts.cinco => '5×',
                        },
                        onChanged: (v) =>
                            setState(() => _maxAttempts = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Cuidador ─────────────────────────────────────────────
                  _SectionCard(
                    icon: Icons.people_outline_rounded,
                    title: 'Cuidador',
                    subtitle: 'opcional',
                    children: [
                      CustomTextField(
                        label: 'Nome do cuidador',
                        hint: 'Maria Silva',
                        controller: _caregiverNameCtrl,
                        prefixIcon:
                            const Icon(Icons.person_outline_rounded),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Telefone do cuidador',
                        hint: '(11) 98888-7777',
                        controller: _caregiverPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        inputFormatters: [_phoneMask],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Save ─────────────────────────────────────────────────
                  _GradientSaveButton(
                    label: _isEditMode
                        ? 'Salvar alterações'
                        : 'Salvar medicamento',
                    onTap: _save,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSelectableMedications() {
    return [
      for (var i = 0; i < widget.existingMedications.length; i++) ...[
        if (i > 0) const SizedBox(height: 8),
        _MedSelectTile(
          med: widget.existingMedications[i],
          isSelected: _selectedMedicationIndex == i,
          onTap: () => _selectMedicationAt(i),
        ),
      ],
    ];
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _AddMedHeader extends StatelessWidget {
  final bool isEditMode;

  const _AddMedHeader({required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -45,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(12),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(9),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withAlpha(60),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withAlpha(60),
                            ),
                          ),
                          child: Icon(
                            isEditMode
                                ? Icons.edit_rounded
                                : Icons.medication_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditMode
                                  ? 'Editar Medicamento'
                                  : 'Novo Medicamento',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isEditMode
                                  ? 'Atualize as informações abaixo'
                                  : 'Preencha os campos abaixo',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
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

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(7),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (subtitle != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withAlpha(18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(50),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// ── Chip group ────────────────────────────────────────────────────────────────

class _ChipGroupLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ChipGroupLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ChipSelector<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.inputBorder,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(55),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              labelOf(opt),
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Time picker ───────────────────────────────────────────────────────────────

class _TimePickerField extends StatelessWidget {
  final int selectedHour;
  final int selectedMinute;
  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  const _TimePickerField({
    required this.selectedHour,
    required this.selectedMinute,
    required this.hourController,
    required this.minuteController,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.access_time_rounded,
                size: 15, color: AppColors.textSecondary),
            SizedBox(width: 6),
            Text(
              'Horário',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withAlpha(40)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center highlight band
              Container(
                height: 46,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withAlpha(55),
                  ),
                ),
              ),
              // Wheel pickers
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    child: _WheelPicker(
                      controller: hourController,
                      count: 24,
                      selected: selectedHour,
                      onChanged: onHourChanged,
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: _WheelPicker(
                      controller: minuteController,
                      count: 60,
                      selected: selectedMinute,
                      onChanged: onMinuteChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 24),
            SizedBox(
              width: 90,
              child: Center(
                child: Text(
                  'hora',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withAlpha(180),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 90,
              child: Center(
                child: Text(
                  'minuto',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withAlpha(180),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WheelPicker extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int count;
  final int selected;
  final ValueChanged<int> onChanged;

  const _WheelPicker({
    required this.controller,
    required this.count,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 46,
      perspective: 0.003,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          final isSel = index == selected;
          return Center(
            child: Text(
              index.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: isSel ? 30 : 22,
                fontWeight:
                    isSel ? FontWeight.w800 : FontWeight.w400,
                color: isSel
                    ? AppColors.primary
                    : AppColors.textSecondary.withAlpha(120),
              ),
            ),
          );
        },
        childCount: count,
      ),
    );
  }
}

// ── Styled dropdown ───────────────────────────────────────────────────────────

class _StyledDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(labelOf(e)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ── Med select tile ───────────────────────────────────────────────────────────

class _MedSelectTile extends StatelessWidget {
  final Medication med;
  final bool isSelected;
  final VoidCallback onTap;

  const _MedSelectTile({
    required this.med,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(15)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(20)
                    : AppColors.inputBorder.withAlpha(60),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.medication_outlined,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${med.dose} · ${med.formattedTime}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.inputBorder,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gradient save button ──────────────────────────────────────────────────────

class _GradientSaveButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientSaveButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
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
      ),
    );
  }
}
