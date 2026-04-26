import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/constants/app_colors.dart';

class CaregiverHistoryPage extends StatefulWidget {
  const CaregiverHistoryPage({super.key});

  @override
  State<CaregiverHistoryPage> createState() => _CaregiverHistoryPageState();
}

enum _Period { today, week, custom }

enum _EventType { taken, missed, late, lowStock }

class _Event {
  final String elderlyName;
  final String medication;
  final String dosage;
  final String time;
  final DateTime date;
  final _EventType type;

  const _Event({
    required this.elderlyName,
    required this.medication,
    required this.dosage,
    required this.time,
    required this.date,
    required this.type,
  });
}

class _CaregiverHistoryPageState extends State<CaregiverHistoryPage> {
  _Period _period = _Period.today;
  String? _selectedElderly;
  DateTime? _customStart;
  DateTime? _customEnd;
  bool _customSearching = false;

  static const _elderlies = ['Maria Oliveira', 'João Pereira', 'Antônio Santos'];

  late final List<_Event> _events;

  @override
  void initState() {
    super.initState();
    _buildMockEvents();
  }

  void _buildMockEvents() {
    final now = DateTime.now();
    DateTime d(int n) =>
        DateTime(now.year, now.month, now.day).subtract(Duration(days: n));

    _events = [
      // Hoje
      _Event(elderlyName: 'Maria Oliveira', medication: 'Hidroclorotiazida', dosage: '25mg', time: '07:33', date: d(0), type: _EventType.taken),
      _Event(elderlyName: 'Antônio Santos', medication: 'Omeprazol', dosage: '20mg', time: '07:05', date: d(0), type: _EventType.taken),
      _Event(elderlyName: 'João Pereira', medication: 'Losartana', dosage: '50mg', time: '08:02', date: d(0), type: _EventType.taken),
      _Event(elderlyName: 'Maria Oliveira', medication: 'AAS', dosage: '100mg', time: '09:01', date: d(0), type: _EventType.taken),
      _Event(elderlyName: 'João Pereira', medication: 'Metformina', dosage: '500mg', time: '12:00', date: d(0), type: _EventType.missed),
      _Event(elderlyName: 'João Pereira', medication: 'Dipirona', dosage: '500mg', time: '14:00', date: d(0), type: _EventType.missed),
      _Event(elderlyName: 'Maria Oliveira', medication: 'AAS', dosage: '100mg', time: '—', date: d(0), type: _EventType.lowStock),
      // Ontem
      _Event(elderlyName: 'Maria Oliveira', medication: 'Hidroclorotiazida', dosage: '25mg', time: '07:28', date: d(1), type: _EventType.taken),
      _Event(elderlyName: 'Antônio Santos', medication: 'Omeprazol', dosage: '20mg', time: '07:00', date: d(1), type: _EventType.taken),
      _Event(elderlyName: 'João Pereira', medication: 'Losartana', dosage: '50mg', time: '08:10', date: d(1), type: _EventType.taken),
      _Event(elderlyName: 'João Pereira', medication: 'Metformina', dosage: '500mg', time: '12:40', date: d(1), type: _EventType.late),
      _Event(elderlyName: 'Antônio Santos', medication: 'Vitamina D', dosage: '1 gota', time: '10:00', date: d(1), type: _EventType.missed),
      _Event(elderlyName: 'Maria Oliveira', medication: 'Sinvastatina', dosage: '20mg', time: '21:05', date: d(1), type: _EventType.taken),
      // 2 dias atrás
      _Event(elderlyName: 'Maria Oliveira', medication: 'Hidroclorotiazida', dosage: '25mg', time: '07:30', date: d(2), type: _EventType.taken),
      _Event(elderlyName: 'Antônio Santos', medication: 'Omeprazol', dosage: '20mg', time: '07:02', date: d(2), type: _EventType.taken),
      _Event(elderlyName: 'João Pereira', medication: 'Losartana', dosage: '50mg', time: '08:00', date: d(2), type: _EventType.taken),
      _Event(elderlyName: 'Maria Oliveira', medication: 'AAS', dosage: '100mg', time: '09:05', date: d(2), type: _EventType.taken),
      _Event(elderlyName: 'João Pereira', medication: 'Atorvastatina', dosage: '20mg', time: '20:00', date: d(2), type: _EventType.missed),
      // 3 dias atrás
      _Event(elderlyName: 'Maria Oliveira', medication: 'Hidroclorotiazida', dosage: '25mg', time: '07:35', date: d(3), type: _EventType.taken),
      _Event(elderlyName: 'João Pereira', medication: 'Losartana', dosage: '50mg', time: '08:05', date: d(3), type: _EventType.taken),
      _Event(elderlyName: 'Antônio Santos', medication: 'Vitamina D', dosage: '1 gota', time: '10:00', date: d(3), type: _EventType.taken),
      _Event(elderlyName: 'João Pereira', medication: 'Metformina', dosage: '500mg', time: '12:00', date: d(3), type: _EventType.missed),
      // 4 dias atrás
      _Event(elderlyName: 'Antônio Santos', medication: 'Omeprazol', dosage: '20mg', time: '07:00', date: d(4), type: _EventType.taken),
      _Event(elderlyName: 'Maria Oliveira', medication: 'Sinvastatina', dosage: '20mg', time: '21:00', date: d(4), type: _EventType.taken),
      _Event(elderlyName: 'João Pereira', medication: 'Dipirona', dosage: '500mg', time: '14:00', date: d(4), type: _EventType.missed),
      // 5 dias atrás
      _Event(elderlyName: 'Maria Oliveira', medication: 'Hidroclorotiazida', dosage: '25mg', time: '07:30', date: d(5), type: _EventType.taken),
      _Event(elderlyName: 'João Pereira', medication: 'Losartana', dosage: '50mg', time: '08:00', date: d(5), type: _EventType.taken),
      _Event(elderlyName: 'Antônio Santos', medication: 'Omeprazol', dosage: '20mg', time: '07:08', date: d(5), type: _EventType.taken),
      // 6 dias atrás
      _Event(elderlyName: 'João Pereira', medication: 'Metformina', dosage: '500mg', time: '12:30', date: d(6), type: _EventType.late),
      _Event(elderlyName: 'Maria Oliveira', medication: 'AAS', dosage: '100mg', time: '09:00', date: d(6), type: _EventType.taken),
      _Event(elderlyName: 'Antônio Santos', medication: 'Omeprazol', dosage: '20mg', time: '07:10', date: d(6), type: _EventType.taken),
    ];

    _events.sort((a, b) {
      final dc = b.date.compareTo(a.date);
      return dc != 0 ? dc : b.time.compareTo(a.time);
    });
  }

  List<_Event> get _filtered {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _events.where((e) {
      final inPeriod = switch (_period) {
        _Period.today => e.date == today,
        _Period.week =>
          !e.date.isBefore(today.subtract(const Duration(days: 6))),
        _Period.custom => (_customStart == null || _customEnd == null)
            ? true
            : !e.date.isBefore(
                  DateTime(_customStart!.year, _customStart!.month, _customStart!.day),
                ) &&
                !e.date.isAfter(
                  DateTime(_customEnd!.year, _customEnd!.month, _customEnd!.day),
                ),
      };
      final inElderly =
          _selectedElderly == null || e.elderlyName == _selectedElderly;
      return inPeriod && inElderly;
    }).toList();
  }

  ({int taken, int missed, int late, int total, int adherence}) get _stats {
    final events = _filtered.where((e) => e.type != _EventType.lowStock).toList();
    final taken = events.where((e) => e.type == _EventType.taken).length;
    final missed = events.where((e) => e.type == _EventType.missed).length;
    final late = events.where((e) => e.type == _EventType.late).length;
    final total = events.length;
    final adherence = total == 0 ? 0 : ((taken / total) * 100).round();
    return (taken: taken, missed: missed, late: late, total: total, adherence: adherence);
  }

  Map<DateTime, List<_Event>> get _grouped {
    final result = <DateTime, List<_Event>>{};
    for (final e in _filtered) {
      result.putIfAbsent(e.date, () => []).add(e);
    }
    return result;
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_customStart ?? now)
        : ((_customEnd != null && !_customEnd!.isBefore(_customStart ?? now))
            ? _customEnd!
            : (_customStart ?? now));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: isStart ? DateTime(2024) : (_customStart ?? DateTime(2024)),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _customStart = picked;
        if (_customEnd != null && _customEnd!.isBefore(picked)) {
          _customEnd = picked;
        }
      } else {
        _customEnd = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 38,
                  height: 38,
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
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Histórico',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Registro de todos os idosos monitorados.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final stats = _stats;
    final grouped = _grouped;
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final showPicker = _period == _Period.custom && !_customSearching;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        _StatsCard(stats: stats),
        const SizedBox(height: 14),
        _PeriodFilter(
          selected: _period,
          customStart: _customStart,
          customEnd: _customEnd,
          onChanged: (p) {
            setState(() {
              _period = p;
              if (p == _Period.custom) _customSearching = false;
            });
          },
        ),
        const SizedBox(height: 10),
        _ElderlyDropdown(
          elderlies: _elderlies,
          selected: _selectedElderly,
          onChanged: (v) => setState(() => _selectedElderly = v),
        ),
        const SizedBox(height: 14),
        if (showPicker)
          _CustomPeriodPicker(
            start: _customStart,
            end: _customEnd,
            onPickStart: () => _pickDate(true),
            onPickEnd: () => _pickDate(false),
            onSearch: () => setState(() => _customSearching = true),
          )
        else if (_filtered.isEmpty)
          _EmptyHistory(period: _period)
        else
          for (final date in dates) ...[
            _DateHeader(date: date),
            const SizedBox(height: 6),
            ...grouped[date]!.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _EventCard(event: e),
              ),
            ),
            const SizedBox(height: 6),
          ],
      ],
    );
  }
}

// ── Stats ─────────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final ({int taken, int missed, int late, int total, int adherence}) stats;

  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _AdherenceCircle(percent: stats.adherence),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _StatRow(
                  label: 'Tomados',
                  value: stats.taken,
                  color: const Color(0xFF16A34A),
                  icon: Icons.check_circle_outline_rounded,
                ),
                const SizedBox(height: 8),
                _StatRow(
                  label: 'Esquecidos',
                  value: stats.missed,
                  color: AppColors.error,
                  icon: Icons.cancel_outlined,
                ),
                const SizedBox(height: 8),
                _StatRow(
                  label: 'Atrasados',
                  value: stats.late,
                  color: AppColors.warning,
                  icon: Icons.schedule_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdherenceCircle extends StatelessWidget {
  final int percent;

  const _AdherenceCircle({required this.percent});

  Color get _color {
    if (percent >= 80) return const Color(0xFF16A34A);
    if (percent >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: CustomPaint(
        painter: _ArcPainter(percent: percent, color: _color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _color,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 1),
              const Text(
                'adesão',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final int percent;
  final Color color;

  const _ArcPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    const strokeWidth = 8.0;

    final bgPaint = Paint()
      ..color = const Color(0xFFEEF2FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (percent > 0) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * (percent / 100),
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.percent != percent || old.color != color;
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Filters ───────────────────────────────────────────────────────────────────

class _PeriodFilter extends StatelessWidget {
  final _Period selected;
  final DateTime? customStart;
  final DateTime? customEnd;
  final void Function(_Period) onChanged;

  const _PeriodFilter({
    required this.selected,
    required this.customStart,
    required this.customEnd,
    required this.onChanged,
  });

  String _customLabel() {
    if (customStart == null || customEnd == null) return 'Personalizado';
    final fmt = DateFormat('dd/MM');
    return '${fmt.format(customStart!)} – ${fmt.format(customEnd!)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _PeriodTab(
            text: 'Hoje',
            selected: selected == _Period.today,
            onTap: () => onChanged(_Period.today),
          ),
          _PeriodTab(
            text: '7 dias',
            selected: selected == _Period.week,
            onTap: () => onChanged(_Period.week),
          ),
          _PeriodTab(
            text: _customLabel(),
            selected: selected == _Period.custom,
            onTap: () => onChanged(_Period.custom),
          ),
        ],
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? AppColors.textWhite : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ElderlyDropdown extends StatelessWidget {
  final List<String> elderlies;
  final String? selected;
  final void Function(String?) onChanged;

  const _ElderlyDropdown({
    required this.elderlies,
    required this.selected,
    required this.onChanged,
  });

  String get _label => selected ?? 'Todos os idosos';

  @override
  Widget build(BuildContext context) {
    final active = selected != null;
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withAlpha(13)
              : AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.inputBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 18,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _label,
                style: TextStyle(
                  color: active ? AppColors.primary : AppColors.textSecondary,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.expand_more_rounded,
              size: 20,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSheet(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ElderlyPicker(
        elderlies: elderlies,
        selected: selected,
      ),
    );
    if (result == null) return;
    onChanged(result.isEmpty ? null : result);
  }
}

class _ElderlyPicker extends StatelessWidget {
  final List<String> elderlies;
  final String? selected;

  const _ElderlyPicker({
    required this.elderlies,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por idoso',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _PickerTile(
            label: 'Todos os idosos',
            isSelected: selected == null,
            onTap: () => Navigator.of(context).pop(''),
          ),
          const Divider(height: 1),
          ...elderlies.map(
            (name) => _PickerTile(
              label: name,
              isSelected: selected == name,
              onTap: () => Navigator.of(context).pop(name),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 15,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ── List items ────────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final DateTime date;

  const _DateHeader({required this.date});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'Hoje';
    if (date == yesterday) return 'Ontem';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        _label().toUpperCase(),
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

class _EventCard extends StatelessWidget {
  final _Event event;

  const _EventCard({required this.event});

  Color get _borderColor => switch (event.type) {
    _EventType.taken => const Color(0xFF16A34A),
    _EventType.missed => AppColors.error,
    _EventType.late => AppColors.warning,
    _EventType.lowStock => AppColors.primary,
  };

  Color get _bgColor => switch (event.type) {
    _EventType.taken => const Color(0xFFECF8EF),
    _EventType.missed => const Color(0xFFFEECEC),
    _EventType.late => const Color(0xFFFFF8E8),
    _EventType.lowStock => const Color(0xFFEFF3FF),
  };

  IconData get _icon => switch (event.type) {
    _EventType.taken => Icons.check_circle_outline_rounded,
    _EventType.missed => Icons.cancel_outlined,
    _EventType.late => Icons.schedule_rounded,
    _EventType.lowStock => Icons.inventory_2_outlined,
  };

  String get _statusLabel => switch (event.type) {
    _EventType.taken => 'Tomado',
    _EventType.missed => 'Esquecido',
    _EventType.late => 'Atrasado',
    _EventType.lowStock => 'Estoque baixo',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: _borderColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _borderColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.medication,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${event.dosage} · ${event.elderlyName.split(' ').first}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      color: _borderColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _CustomPeriodPicker extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onSearch;

  const _CustomPeriodPicker({
    required this.start,
    required this.end,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onSearch,
  });

  String _fmt(DateTime? d) {
    if (d == null) return 'Selecionar';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Período personalizado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Selecione o intervalo de datas',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Data início',
                  value: _fmt(start),
                  onTap: onPickStart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateButton(
                  label: 'Data fim',
                  value: _fmt(end),
                  onTap: onPickEnd,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (start != null && end != null) ? onSearch : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Buscar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  final _Period period;

  const _EmptyHistory({required this.period});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nenhum registro encontrado.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tente mudar o período ou o filtro de idoso.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
