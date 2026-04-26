import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/widgets/custom_button.dart';

enum _HistoryTab { hoje, ultimos7, personalizado }

enum HistoryStatus { tomado, perdido, atrasado }

class HistoryEntry {
  final String name;
  final String dose;
  final TimeOfDay scheduledTime;
  final TimeOfDay? actualTime;
  final HistoryStatus status;

  const HistoryEntry({
    required this.name,
    required this.dose,
    required this.scheduledTime,
    this.actualTime,
    required this.status,
  });

  String get scheduledLabel {
    final h = scheduledTime.hour.toString().padLeft(2, '0');
    final m = scheduledTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String? get actualLabel => actualTime == null
      ? null
      : '${actualTime!.hour.toString().padLeft(2, '0')}:${actualTime!.minute.toString().padLeft(2, '0')}';
}

class HistoryPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<HistoryEntry>? initialEntries;
  final bool showBottomNavigation;
  final bool showBackButton;

  const HistoryPage({
    super.key,
    this.title = 'Histórico',
    this.subtitle = 'Acompanhe sua adesão',
    this.initialEntries,
    this.showBottomNavigation = true,
    this.showBackButton = false,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  _HistoryTab _tab = _HistoryTab.hoje;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _endDate = DateTime.now();

  static const _defaultEntries = [
    HistoryEntry(
      name: 'Losartana',
      dose: '50mg',
      scheduledTime: TimeOfDay(hour: 8, minute: 0),
      actualTime: TimeOfDay(hour: 8, minute: 3),
      status: HistoryStatus.tomado,
    ),
    HistoryEntry(
      name: 'Metformina',
      dose: '500mg',
      scheduledTime: TimeOfDay(hour: 12, minute: 0),
      status: HistoryStatus.perdido,
    ),
    HistoryEntry(
      name: 'Atorvastatina',
      dose: '20mg',
      scheduledTime: TimeOfDay(hour: 20, minute: 0),
      status: HistoryStatus.atrasado,
    ),
  ];

  List<HistoryEntry> get _entries => widget.initialEntries ?? _defaultEntries;

  int get _tomados =>
      _entries.where((e) => e.status == HistoryStatus.tomado).length;
  int get _atrasados =>
      _entries.where((e) => e.status == HistoryStatus.atrasado).length;
  int get _perdidos =>
      _entries.where((e) => e.status == HistoryStatus.perdido).length;
  int get _adesaoPct =>
      _entries.isEmpty ? 0 : (_tomados / _entries.length * 100).round();

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
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
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_startDate.isAfter(_endDate)) _endDate = _startDate;
      } else {
        _endDate = picked;
        if (_endDate.isBefore(_startDate)) _startDate = _endDate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _HistoryHeader(
            showBackButton: widget.showBackButton,
            title: widget.title,
            subtitle: widget.subtitle,
            tomados: _tomados,
            atrasados: _atrasados,
            perdidos: _perdidos,
            adesaoPct: _adesaoPct,
          ),
          const SizedBox(height: 16),
          _TabSelector(
            selected: _tab,
            onChanged: (t) => setState(() => _tab = t),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _tab == _HistoryTab.personalizado
                ? _CustomDatePicker(
                    startDate: _startDate,
                    endDate: _endDate,
                    onPickStart: () => _pickDate(true),
                    onPickEnd: () => _pickDate(false),
                    onSearch: () {},
                  )
                : _EntryList(entries: _entries),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNavigation
          ? BottomNavigationBar(
              currentIndex: 1,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.backgroundWhite,
              elevation: 12,
              onTap: (i) {
                if (i == 0) context.go(AppRoutes.userHome);
                if (i == 2) context.go(AppRoutes.settings);
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
            )
          : null,
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HistoryHeader extends StatelessWidget {
  final bool showBackButton;
  final String title;
  final String subtitle;
  final int tomados;
  final int atrasados;
  final int perdidos;
  final int adesaoPct;

  const _HistoryHeader({
    required this.showBackButton,
    required this.title,
    required this.subtitle,
    required this.tomados,
    required this.atrasados,
    required this.perdidos,
    required this.adesaoPct,
  });

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
          // Decorative circles
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
            right: 30,
            bottom: 8,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(8),
              ),
            ),
          ),
          Positioned(
            left: -25,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(8),
              ),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      if (showBackButton)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(30),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withAlpha(60),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Stats card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(22),
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: Colors.white.withAlpha(45)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          _StatItem(
                            label: 'Tomados',
                            value: '$tomados',
                            icon: Icons.check_circle_rounded,
                            valueColor: const Color(0xFF86EFAC),
                          ),
                          _StatDivider(),
                          _StatItem(
                            label: 'Atrasados',
                            value: '$atrasados',
                            icon: Icons.schedule_rounded,
                            valueColor: const Color(0xFFFCD34D),
                          ),
                          _StatDivider(),
                          _StatItem(
                            label: 'Perdidos',
                            value: '$perdidos',
                            icon: Icons.cancel_rounded,
                            valueColor: const Color(0xFFFCA5A5),
                          ),
                          _StatDivider(),
                          _StatItem(
                            label: 'Adesão',
                            value: '$adesaoPct%',
                            icon: Icons.bar_chart_rounded,
                            valueColor: const Color(0xFF93C5FD),
                          ),
                        ],
                      ),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: valueColor.withAlpha(35),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: valueColor, size: 17),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: Colors.white.withAlpha(30),
    );
  }
}

// ── Tab selector ──────────────────────────────────────────────────────────────

class _TabSelector extends StatelessWidget {
  final _HistoryTab selected;
  final ValueChanged<_HistoryTab> onChanged;

  const _TabSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: _HistoryTab.values.map((tab) {
            final isSelected = tab == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(60),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    _label(tab),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _label(_HistoryTab t) => switch (t) {
        _HistoryTab.hoje => 'Hoje',
        _HistoryTab.ultimos7 => 'Últimos 7 dias',
        _HistoryTab.personalizado => 'Personalizado',
      };
}

// ── Entry list ────────────────────────────────────────────────────────────────

class _EntryList extends StatelessWidget {
  final List<HistoryEntry> entries;

  const _EntryList({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Nenhum registro encontrado.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tente mudar o período.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _HistoryCard(entry: entries[i]),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;

  const _HistoryCard({required this.entry});

  Color get _color => switch (entry.status) {
        HistoryStatus.tomado => AppColors.success,
        HistoryStatus.perdido => AppColors.error,
        HistoryStatus.atrasado => AppColors.warning,
      };

  String get _statusLabel => switch (entry.status) {
        HistoryStatus.tomado => 'Tomado',
        HistoryStatus.perdido => 'Perdido',
        HistoryStatus.atrasado => 'Atrasado',
      };

  IconData get _icon => switch (entry.status) {
        HistoryStatus.tomado => Icons.check_circle_rounded,
        HistoryStatus.perdido => Icons.cancel_rounded,
        HistoryStatus.atrasado => Icons.schedule_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: _color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(7),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            // Icon with gradient background
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _color.withAlpha(35),
                    _color.withAlpha(15),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _color.withAlpha(45)),
              ),
              child: Icon(_icon, color: _color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.dose,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 7),
                  // Time row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 11,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              entry.scheduledLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (entry.actualLabel != null) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          entry.actualLabel!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: _color.withAlpha(18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom date picker ────────────────────────────────────────────────────────

class _CustomDatePicker extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onSearch;

  const _CustomDatePicker({
    required this.startDate,
    required this.endDate,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                color: AppColors.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(16),
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
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Selecione o intervalo de datas',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'Data início',
                    value: fmt.format(startDate),
                    onTap: onPickStart,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateButton(
                    label: 'Data fim',
                    value: fmt.format(endDate),
                    onTap: onPickEnd,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Buscar', onPressed: onSearch),
          ],
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withAlpha(60)),
            ),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
