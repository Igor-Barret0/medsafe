import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../user/presentation/widgets/profile_edit_widgets.dart';

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

  static const _elderlies = [
    'Maria Oliveira',
    'João Pereira',
    'Antônio Santos',
  ];

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
      _Event(
        elderlyName: 'Maria Oliveira',
        medication: 'Hidroclorotiazida',
        dosage: '25mg',
        time: '07:33',
        date: d(0),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'Antônio Santos',
        medication: 'Omeprazol',
        dosage: '20mg',
        time: '07:05',
        date: d(0),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'João Pereira',
        medication: 'Losartana',
        dosage: '50mg',
        time: '08:02',
        date: d(0),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'Maria Oliveira',
        medication: 'AAS',
        dosage: '100mg',
        time: '09:01',
        date: d(0),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'João Pereira',
        medication: 'Metformina',
        dosage: '500mg',
        time: '12:00',
        date: d(0),
        type: _EventType.missed,
      ),
      _Event(
        elderlyName: 'João Pereira',
        medication: 'Dipirona',
        dosage: '500mg',
        time: '14:00',
        date: d(0),
        type: _EventType.missed,
      ),
      _Event(
        elderlyName: 'Maria Oliveira',
        medication: 'AAS',
        dosage: '100mg',
        time: '—',
        date: d(0),
        type: _EventType.lowStock,
      ),
      _Event(
        elderlyName: 'Maria Oliveira',
        medication: 'Hidroclorotiazida',
        dosage: '25mg',
        time: '07:28',
        date: d(1),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'Antônio Santos',
        medication: 'Omeprazol',
        dosage: '20mg',
        time: '07:00',
        date: d(1),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'João Pereira',
        medication: 'Losartana',
        dosage: '50mg',
        time: '08:10',
        date: d(1),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'João Pereira',
        medication: 'Metformina',
        dosage: '500mg',
        time: '12:40',
        date: d(1),
        type: _EventType.late,
      ),
      _Event(
        elderlyName: 'Antônio Santos',
        medication: 'Vitamina D',
        dosage: '1 gota',
        time: '10:00',
        date: d(1),
        type: _EventType.missed,
      ),
      _Event(
        elderlyName: 'Maria Oliveira',
        medication: 'Sinvastatina',
        dosage: '20mg',
        time: '21:05',
        date: d(1),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'Maria Oliveira',
        medication: 'Hidroclorotiazida',
        dosage: '25mg',
        time: '07:30',
        date: d(2),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'Antônio Santos',
        medication: 'Omeprazol',
        dosage: '20mg',
        time: '07:02',
        date: d(2),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'João Pereira',
        medication: 'Losartana',
        dosage: '50mg',
        time: '08:00',
        date: d(2),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'Maria Oliveira',
        medication: 'AAS',
        dosage: '100mg',
        time: '09:05',
        date: d(2),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'João Pereira',
        medication: 'Atorvastatina',
        dosage: '20mg',
        time: '20:00',
        date: d(2),
        type: _EventType.missed,
      ),
      _Event(
        elderlyName: 'Maria Oliveira',
        medication: 'Hidroclorotiazida',
        dosage: '25mg',
        time: '07:35',
        date: d(3),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'João Pereira',
        medication: 'Losartana',
        dosage: '50mg',
        time: '08:05',
        date: d(3),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'Antônio Santos',
        medication: 'Vitamina D',
        dosage: '1 gota',
        time: '10:00',
        date: d(3),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'João Pereira',
        medication: 'Metformina',
        dosage: '500mg',
        time: '12:00',
        date: d(3),
        type: _EventType.missed,
      ),
      _Event(
        elderlyName: 'Antônio Santos',
        medication: 'Omeprazol',
        dosage: '20mg',
        time: '07:00',
        date: d(4),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'Maria Oliveira',
        medication: 'Sinvastatina',
        dosage: '20mg',
        time: '21:00',
        date: d(4),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'João Pereira',
        medication: 'Dipirona',
        dosage: '500mg',
        time: '14:00',
        date: d(4),
        type: _EventType.missed,
      ),
      _Event(
        elderlyName: 'Maria Oliveira',
        medication: 'Hidroclorotiazida',
        dosage: '25mg',
        time: '07:30',
        date: d(5),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'João Pereira',
        medication: 'Losartana',
        dosage: '50mg',
        time: '08:00',
        date: d(5),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'Antônio Santos',
        medication: 'Omeprazol',
        dosage: '20mg',
        time: '07:08',
        date: d(5),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'João Pereira',
        medication: 'Metformina',
        dosage: '500mg',
        time: '12:30',
        date: d(6),
        type: _EventType.late,
      ),
      _Event(
        elderlyName: 'Maria Oliveira',
        medication: 'AAS',
        dosage: '100mg',
        time: '09:00',
        date: d(6),
        type: _EventType.taken,
      ),
      _Event(
        elderlyName: 'Antônio Santos',
        medication: 'Omeprazol',
        dosage: '20mg',
        time: '07:10',
        date: d(6),
        type: _EventType.taken,
      ),
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
        _Period.week => !e.date.isBefore(
          today.subtract(const Duration(days: 6)),
        ),
        _Period.custom =>
          (_customStart == null || _customEnd == null)
              ? true
              : !e.date.isBefore(
                      DateTime(
                        _customStart!.year,
                        _customStart!.month,
                        _customStart!.day,
                      ),
                    ) &&
                    !e.date.isAfter(
                      DateTime(
                        _customEnd!.year,
                        _customEnd!.month,
                        _customEnd!.day,
                      ),
                    ),
      };
      final inElderly =
          _selectedElderly == null || e.elderlyName == _selectedElderly;
      return inPeriod && inElderly;
    }).toList();
  }

  ({int taken, int missed, int late, int total, int adherence}) get _stats {
    final events = _filtered
        .where((e) => e.type != _EventType.lowStock)
        .toList();
    final taken = events.where((e) => e.type == _EventType.taken).length;
    final missed = events.where((e) => e.type == _EventType.missed).length;
    final late = events.where((e) => e.type == _EventType.late).length;
    final total = events.length;
    final adherence = total == 0 ? 0 : ((taken / total) * 100).round();
    return (
      taken: taken,
      missed: missed,
      late: late,
      total: total,
      adherence: adherence,
    );
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
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          ProfileEditHeader(
            title: 'Histórico',
            subtitle: 'Registro dos idosos monitorados',
            icon: Icons.history_rounded,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundWhite,
        elevation: 12,
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context).pop();
            return;
          }
          if (i == 2) {
            context.go(AppRoutes.settings);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Config.',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final stats = _stats;
    final grouped = _grouped;
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final showPicker = _period == _Period.custom && !_customSearching;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _StatsCard(stats: stats),
        const SizedBox(height: 12),
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
            _DateGroupHeader(date: date, events: grouped[date]!),
            const SizedBox(height: 8),
            ...grouped[date]!.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < grouped[date]!.length - 1 ? 8 : 0,
                ),
                child: _EventCard(event: entry.value),
              ),
            ),
            const SizedBox(height: 18),
          ],
      ],
    );
  }
}

// ── Stats card ────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final ({int taken, int missed, int late, int total, int adherence}) stats;

  const _StatsCard({required this.stats});

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
                  color: AppColors.success,
                  icon: Icons.check_circle_outline_rounded,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: AppColors.divider),
                ),
                _StatRow(
                  label: 'Esquecidos',
                  value: stats.missed,
                  color: AppColors.error,
                  icon: Icons.cancel_outlined,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: AppColors.divider),
                ),
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
    if (percent >= 80) return AppColors.success;
    if (percent >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color.withAlpha(10),
      ),
      child: CustomPaint(
        painter: _ArcPainter(percent: percent, color: _color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _color,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'adesão',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: _color.withAlpha(180),
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
    final radius = (size.width - 14) / 2;
    const strokeWidth = 7.0;

    final bgPaint = Paint()
      ..color = Colors.black.withAlpha(10)
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
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withAlpha(18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withAlpha(14),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
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
    if (customStart == null || customEnd == null) return 'Período';
    final fmt = DateFormat('dd/MM');
    return '${fmt.format(customStart!)} – ${fmt.format(customEnd!)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _PeriodTab(
            text: 'Hoje',
            icon: Icons.today_rounded,
            selected: selected == _Period.today,
            onTap: () => onChanged(_Period.today),
          ),
          _PeriodTab(
            text: '7 dias',
            icon: Icons.date_range_rounded,
            selected: selected == _Period.week,
            onTap: () => onChanged(_Period.week),
          ),
          _PeriodTab(
            text: _customLabel(),
            icon: Icons.tune_rounded,
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
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.text,
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
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(50),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(height: 3),
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withAlpha(12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? AppColors.primary.withAlpha(120)
                : AppColors.inputBorder,
            width: active ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary.withAlpha(20)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 17,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _label,
                style: TextStyle(
                  color: active ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              active ? Icons.close_rounded : Icons.expand_more_rounded,
              size: 20,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSheet(BuildContext context) async {
    if (selected != null) {
      onChanged(null);
      return;
    }
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ElderlyPicker(elderlies: elderlies, selected: selected),
    );
    if (result == null) return;
    onChanged(result.isEmpty ? null : result);
  }
}

class _ElderlyPicker extends StatelessWidget {
  final List<String> elderlies;
  final String? selected;

  const _ElderlyPicker({required this.elderlies, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Filtrar por idoso',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _PickerTile(
            label: 'Todos os idosos',
            isSelected: selected == null,
            onTap: () => Navigator.of(context).pop(''),
          ),
          const Divider(height: 1, color: AppColors.divider),
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 15,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Date group header ─────────────────────────────────────────────────────────

class _DateGroupHeader extends StatelessWidget {
  final DateTime date;
  final List<_Event> events;

  const _DateGroupHeader({required this.date, required this.events});

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
    final taken = events.where((e) => e.type == _EventType.taken).length;
    final total = events.where((e) => e.type != _EventType.lowStock).length;

    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(160),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _label().toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
        ),
        if (total > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$taken/$total tomados',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Event card ────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final _Event event;

  const _EventCard({required this.event});

  Color get _statusColor => switch (event.type) {
    _EventType.taken => AppColors.success,
    _EventType.missed => AppColors.error,
    _EventType.late => AppColors.warning,
    _EventType.lowStock => AppColors.primary,
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

  String get _elderlyInitials {
    final parts = event.elderlyName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Rounded left status bar via Positioned
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                // Medication icon box
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon, color: _statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                // Medication info
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
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(18),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _elderlyInitials,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${event.elderlyName.split(' ').first} · ${event.dosage}',
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
                const SizedBox(width: 8),
                // Status + time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withAlpha(14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          event.time,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
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

// ── Custom period picker ──────────────────────────────────────────────────────

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
    final canSearch = start != null && end != null;

    return Container(
      padding: const EdgeInsets.all(20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Período personalizado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Selecione o intervalo de datas',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Data início',
                  value: _fmt(start),
                  active: start != null,
                  onTap: onPickStart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateButton(
                  label: 'Data fim',
                  value: _fmt(end),
                  active: end != null,
                  onTap: onPickEnd,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: canSearch ? onSearch : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: canSearch
                    ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      )
                    : null,
                color: canSearch ? null : AppColors.inputBorder,
                borderRadius: BorderRadius.circular(14),
                boxShadow: canSearch
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: canSearch ? Colors.white : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Buscar',
                    style: TextStyle(
                      color: canSearch ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
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

class _DateButton extends StatelessWidget {
  final String label;
  final String value;
  final bool active;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.value,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withAlpha(10) : AppColors.surface,
          border: Border.all(
            color: active
                ? AppColors.primary.withAlpha(120)
                : AppColors.inputBorder,
            width: active ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: active ? AppColors.primary : AppColors.textHint,
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  final _Period period;

  const _EmptyHistory({required this.period});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withAlpha(20),
                    AppColors.primary.withAlpha(10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_toggle_off_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum registro encontrado',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tente mudar o período ou o filtro de idoso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
