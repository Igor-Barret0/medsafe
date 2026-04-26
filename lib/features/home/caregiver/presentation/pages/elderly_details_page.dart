import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../user/presentation/pages/history_page.dart';
import '../../../user/domain/medication.dart';
import '../../../user/presentation/pages/add_medication_page.dart';

enum DoseStatus { taken, late, pending }

String _doseStatusLabel(DoseStatus status) => switch (status) {
  DoseStatus.taken => 'Tomado',
  DoseStatus.late => 'Atrasado',
  DoseStatus.pending => 'Pendente',
};

bool _isSuccessfulStatus(DoseStatus status) => status == DoseStatus.taken;

class ElderlyMedicationItem {
  final String name;
  final String dosage;
  final String time;
  final DoseStatus status;

  const ElderlyMedicationItem({
    required this.name,
    required this.dosage,
    required this.time,
    required this.status,
  });

  ElderlyMedicationItem copyWith({
    String? name,
    String? dosage,
    String? time,
    DoseStatus? status,
  }) {
    return ElderlyMedicationItem(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }
}

class RecentHistoryItem {
  final String message;
  final bool success;

  const RecentHistoryItem({required this.message, required this.success});
}

class ElderlyDetailsPage extends StatefulWidget {
  final String elderlyName;
  final int age;
  final int medicationCount;
  final String relationship;
  final List<ElderlyMedicationItem> medications;
  final List<RecentHistoryItem> recentHistory;

  const ElderlyDetailsPage({
    super.key,
    required this.elderlyName,
    required this.age,
    required this.medicationCount,
    required this.relationship,
    required this.medications,
    required this.recentHistory,
  });

  @override
  State<ElderlyDetailsPage> createState() => _ElderlyDetailsPageState();
}

class _ElderlyDetailsPageState extends State<ElderlyDetailsPage> {
  late List<ElderlyMedicationItem> _medications;
  late List<RecentHistoryItem> _history;

  @override
  void initState() {
    super.initState();
    _medications = List<ElderlyMedicationItem>.from(widget.medications);
    _history = List<RecentHistoryItem>.from(widget.recentHistory);
  }

  Future<void> _openEditMedicationsSheet() async {
    final source = _medications;
    final mappedForEditor = <Medication>[];
    for (var i = 0; i < source.length; i++) {
      final med = source[i];
      mappedForEditor.add(_toMedicationModel(med, i));
    }

    final result = await Navigator.of(context).push<MedicationEditorResult>(
      MaterialPageRoute(
        builder: (_) => AddMedicationPage(existingMedications: mappedForEditor),
      ),
    );

    if (!mounted || result == null) return;
    if (result.index < 0 || result.index >= _medications.length) return;

    final now = TimeOfDay.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final timeLabel = '$hh:$mm';

    final before = _medications[result.index];
    final updated = _fromMedicationModel(result.medication);

    setState(() {
      _medications[result.index] = updated;

      if (before.status != updated.status) {
        _history = [
          RecentHistoryItem(
            message:
                '${updated.name} atualizada para ${_doseStatusLabel(updated.status).toLowerCase()} às $timeLabel',
            success: _isSuccessfulStatus(updated.status),
          ),
          ..._history,
        ];
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medicamento atualizado com sucesso.')),
    );
  }

  Medication _toMedicationModel(ElderlyMedicationItem med, int index) {
    final parts = med.time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts.first) ?? 8 : 8;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return Medication(
      id: 'elderly-${widget.elderlyName}-$index',
      name: med.name,
      dose: med.dosage,
      time: TimeOfDay(hour: hour, minute: minute),
      status: _toMedicationStatus(med.status),
    );
  }

  ElderlyMedicationItem _fromMedicationModel(Medication med) {
    return ElderlyMedicationItem(
      name: med.name,
      dosage: med.dose,
      time: med.formattedTime,
      status: _fromMedicationStatus(med.status),
    );
  }

  MedicationStatus _toMedicationStatus(DoseStatus status) => switch (status) {
    DoseStatus.taken => MedicationStatus.tomado,
    DoseStatus.late => MedicationStatus.atrasado,
    DoseStatus.pending => MedicationStatus.pendente,
  };

  DoseStatus _fromMedicationStatus(MedicationStatus status) => switch (status) {
    MedicationStatus.tomado => DoseStatus.taken,
    MedicationStatus.atrasado => DoseStatus.late,
    MedicationStatus.pendente => DoseStatus.pending,
  };

  Future<void> _openFullHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HistoryPage(
          title: 'Histórico de ${widget.elderlyName}',
          subtitle: 'Registros de medicação deste idoso',
          initialEntries: _buildHistoryEntries(),
          showBottomNavigation: false,
          showBackButton: true,
        ),
      ),
    );
  }

  List<HistoryEntry> _buildHistoryEntries() {
    if (_medications.isEmpty) return const <HistoryEntry>[];

    final entries = <HistoryEntry>[];
    for (final med in _medications) {
      final timeParts = med.time.split(':');
      final hour = timeParts.isNotEmpty ? int.tryParse(timeParts[0]) ?? 0 : 0;
      final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;

      final status = switch (med.status) {
        DoseStatus.taken => HistoryStatus.tomado,
        DoseStatus.late => HistoryStatus.atrasado,
        DoseStatus.pending => HistoryStatus.perdido,
      };

      entries.add(
        HistoryEntry(
          name: med.name,
          dose: med.dosage,
          scheduledTime: TimeOfDay(hour: hour, minute: minute),
          actualTime: med.status == DoseStatus.taken
              ? TimeOfDay(hour: hour, minute: minute)
              : null,
          status: status,
        ),
      );
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          _DetailsHeader(
            elderlyName: widget.elderlyName,
            age: widget.age,
            medicationCount: _medications.length,
            relationship: widget.relationship,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
              children: [
                const _SectionTitle('MEDICAMENTOS DO IDOSO'),
                const SizedBox(height: 10),
                ..._buildMedicationCards(_medications),
                const SizedBox(height: 14),
                const _SectionTitle('HISTÓRICO RECENTE'),
                const SizedBox(height: 10),
                _HistoryCard(items: _history.take(3).toList()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _openEditMedicationsSheet,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Editar medicamentos'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _openFullHistory,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Ver histórico'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMedicationCards(List<ElderlyMedicationItem> list) {
    final widgets = <Widget>[];
    for (var i = 0; i < list.length; i++) {
      widgets.add(_MedicationCard(item: list[i]));
      if (i < list.length - 1) {
        widgets.add(const SizedBox(height: 9));
      }
    }
    return widgets;
  }
}

class _DetailsHeader extends StatelessWidget {
  final String elderlyName;
  final int age;
  final int medicationCount;
  final String relationship;

  const _DetailsHeader({
    required this.elderlyName,
    required this.age,
    required this.medicationCount,
    required this.relationship,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(11),
                      onTap: () => Navigator.of(context).pop(),
                      child: Ink(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(38),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textWhite,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          elderlyName,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 31,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        const Text(
                          'Detalhes do acompanhamento',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeaderBadge(
                    icon: Icons.accessibility_new_rounded,
                    text: '$age anos',
                  ),
                  _HeaderBadge(
                    icon: Icons.medication_rounded,
                    text: '$medicationCount medicamentos',
                  ),
                  _HeaderBadge(
                    icon: Icons.favorite_rounded,
                    text: relationship,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(28),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.warning),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final ElderlyMedicationItem item;

  const _MedicationCard({required this.item});

  Color get _accentColor => switch (item.status) {
    DoseStatus.taken => const Color(0xFF16A34A),
    DoseStatus.late => const Color(0xFFEF4444),
    DoseStatus.pending => const Color(0xFF1D6FD6),
  };

  Color get _cardTint => switch (item.status) {
    DoseStatus.taken => const Color(0xFFB5E5C6),
    DoseStatus.late => const Color(0xFFF8C4C4),
    DoseStatus.pending => const Color(0xFFBED5FF),
  };

  Color get _iconBg => _accentColor.withAlpha(18);

  String get _statusLabel => switch (item.status) {
    DoseStatus.taken => 'Tomado',
    DoseStatus.late => 'Atrasado',
    DoseStatus.pending => 'Pendente',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardTint),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication_outlined,
              color: _accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.dosage,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.alarm_rounded, size: 14, color: _accentColor),
                    const SizedBox(width: 4),
                    Text(
                      item.time,
                      style: TextStyle(
                        color: _accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              _statusLabel,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final List<RecentHistoryItem> items;

  const _HistoryCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _HistoryRow(item: items[i]),
            if (i < items.length - 1)
              const Divider(height: 1, indent: 42, endIndent: 6),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final RecentHistoryItem item;

  const _HistoryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final iconColor = item.success
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.success ? Icons.check_rounded : Icons.close_rounded,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
