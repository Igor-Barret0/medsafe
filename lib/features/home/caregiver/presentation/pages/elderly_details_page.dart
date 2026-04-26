import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
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
    final mappedForEditor = <Medication>[];
    for (var i = 0; i < _medications.length; i++) {
      mappedForEditor.add(_toMedicationModel(_medications[i], i));
    }

    final result = await Navigator.of(context).push<MedicationEditorResult>(
      MaterialPageRoute(
        builder: (_) => AddMedicationPage(existingMedications: mappedForEditor),
      ),
    );

    if (!mounted || result == null) return;
    if (result.index < 0 || result.index >= _medications.length) return;

    final now = TimeOfDay.now();
    final timeLabel =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
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
      const SnackBar(
        content: Text('Medicamento atualizado com sucesso.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
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

  MedicationStatus _toMedicationStatus(DoseStatus s) => switch (s) {
        DoseStatus.taken => MedicationStatus.tomado,
        DoseStatus.late => MedicationStatus.atrasado,
        DoseStatus.pending => MedicationStatus.pendente,
      };

  DoseStatus _fromMedicationStatus(MedicationStatus s) => switch (s) {
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
    return _medications.map((med) {
      final parts = med.time.split(':');
      final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      final status = switch (med.status) {
        DoseStatus.taken => HistoryStatus.tomado,
        DoseStatus.late => HistoryStatus.atrasado,
        DoseStatus.pending => HistoryStatus.perdido,
      };
      return HistoryEntry(
        name: med.name,
        dose: med.dosage,
        scheduledTime: TimeOfDay(hour: hour, minute: minute),
        actualTime:
            med.status == DoseStatus.taken ? TimeOfDay(hour: hour, minute: minute) : null,
        status: status,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final taken = _medications.where((m) => m.status == DoseStatus.taken).length;
    final total = _medications.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _DetailsHeader(
            elderlyName: widget.elderlyName,
            age: widget.age,
            medicationCount: total,
            relationship: widget.relationship,
            taken: taken,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                _SectionLabel(
                    text: 'MEDICAMENTOS', color: AppColors.primary),
                const SizedBox(height: 10),
                for (var i = 0; i < _medications.length; i++) ...[
                  _MedicationCard(item: _medications[i]),
                  if (i < _medications.length - 1) const SizedBox(height: 10),
                ],
                const SizedBox(height: 22),
                _SectionLabel(
                    text: 'HISTÓRICO RECENTE',
                    color: const Color(0xFF7C3AED)),
                const SizedBox(height: 10),
                _HistoryCard(items: _history.take(3).toList()),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.edit_rounded,
                        label: 'Editar meds',
                        gradient: true,
                        onTap: _openEditMedicationsSheet,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.history_rounded,
                        label: 'Histórico',
                        gradient: false,
                        onTap: _openFullHistory,
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
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DetailsHeader extends StatelessWidget {
  final String elderlyName;
  final int age;
  final int medicationCount;
  final String relationship;
  final int taken;

  const _DetailsHeader({
    required this.elderlyName,
    required this.age,
    required this.medicationCount,
    required this.relationship,
    required this.taken,
  });

  String get _initials {
    final parts = elderlyName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(12),
              ),
            ),
          ),
          Positioned(
            left: -25,
            bottom: -25,
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withAlpha(60)),
                          ),
                          child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Initials avatar
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(30),
                          border: Border.all(
                              color: Colors.white.withAlpha(70), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              elderlyName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Detalhes do acompanhamento',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _InfoBadge(
                          icon: Icons.cake_outlined, label: '$age anos'),
                      const SizedBox(width: 8),
                      _InfoBadge(
                          icon: Icons.medication_outlined,
                          label: '$medicationCount meds'),
                      const SizedBox(width: 8),
                      _InfoBadge(
                          icon: Icons.favorite_outline_rounded,
                          label: relationship),
                      const Spacer(),
                      // Adherence mini badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.success.withAlpha(80)),
                        ),
                        child: Text(
                          '$taken/$medicationCount tomados',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withAlpha(210)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

// ── Medication card ───────────────────────────────────────────────────────────

class _MedicationCard extends StatelessWidget {
  final ElderlyMedicationItem item;

  const _MedicationCard({required this.item});

  Color get _accentColor => switch (item.status) {
        DoseStatus.taken => AppColors.success,
        DoseStatus.late => AppColors.error,
        DoseStatus.pending => AppColors.primary,
      };

  IconData get _statusIcon => switch (item.status) {
        DoseStatus.taken => Icons.check_circle_rounded,
        DoseStatus.late => Icons.error_rounded,
        DoseStatus.pending => Icons.schedule_rounded,
      };

  String get _statusLabel => switch (item.status) {
        DoseStatus.taken => 'Tomado',
        DoseStatus.late => 'Atrasado',
        DoseStatus.pending => 'Pendente',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(7),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _accentColor.withAlpha(18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.medication_outlined,
                      color: _accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.dosage,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.alarm_rounded,
                              size: 12, color: _accentColor),
                          const SizedBox(width: 4),
                          Text(
                            item.time,
                            style: TextStyle(
                              color: _accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentColor.withAlpha(16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accentColor.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, color: _accentColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── History card ──────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final List<RecentHistoryItem> items;

  const _HistoryCard({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(7),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: const Center(
          child: Text('Nenhum histórico recente.',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(7),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              _HistoryRow(item: e.value),
              if (!isLast)
                const Divider(height: 1, indent: 58, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final RecentHistoryItem item;

  const _HistoryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color =
        item.success ? AppColors.success : AppColors.error;
    final icon =
        item.success ? Icons.check_rounded : Icons.close_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.message,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: gradient
              ? const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                )
              : null,
          color: gradient ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: gradient
              ? null
              : Border.all(color: AppColors.inputBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: gradient
                  ? AppColors.primary.withAlpha(55)
                  : Colors.black.withAlpha(5),
              blurRadius: gradient ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: gradient ? Colors.white : AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: gradient ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
