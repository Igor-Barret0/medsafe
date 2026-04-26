import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../domain/medication.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  static final List<Medication> _meds = [
    Medication(
      id: '1',
      name: 'Losartana',
      dose: '50mg — 1 comprimido',
      time: const TimeOfDay(hour: 8, minute: 0),
      status: MedicationStatus.tomado,
    ),
    Medication(
      id: '2',
      name: 'Metformina',
      dose: '500mg — 2 comprimidos',
      time: const TimeOfDay(hour: 12, minute: 0),
      status: MedicationStatus.atrasado,
    ),
    Medication(
      id: '3',
      name: 'Atorvastatina',
      dose: '20mg — 1 comprimido',
      time: const TimeOfDay(hour: 20, minute: 0),
      status: MedicationStatus.pendente,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final firstName = user?.name.split(' ').first ?? 'Usuário';
    final taken  = _meds.where((m) => m.status == MedicationStatus.tomado).length;
    final late   = _meds.where((m) => m.status == MedicationStatus.atrasado).length;
    final pending = _meds.where((m) => m.status == MedicationStatus.pendente).length;
    final total  = _meds.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HomeHeader(
              firstName: firstName,
              taken: taken,
              total: total,
              onLogout: () async {
                await context.read<AuthController>().logout();
                if (context.mounted) context.go(AppRoutes.login);
              },
            ),
          ),

          // ── Section header ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Medicamentos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _todayLabel(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Hoje',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Quick stats strip ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _QuickStats(
                taken: taken,
                late: late,
                pending: pending,
              ),
            ),
          ),

          // ── Stock alert ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _StockAlertCard(medName: 'Dipirona', remaining: 2),
            ),
          ),

          // ── Medication list ────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MedicationCard(med: _meds[i]),
                ),
                childCount: _meds.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addMedication),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: AppColors.textWhite, size: 28),
      ),
      bottomNavigationBar: _BottomNav(currentIndex: 0),
    );
  }

  String _todayLabel() {
    const weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday % 7]}, ${now.day} de ${months[now.month - 1]}';
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final String firstName;
  final int taken;
  final int total;
  final VoidCallback onLogout;

  const _HomeHeader({
    required this.firstName,
    required this.taken,
    required this.total,
    required this.onLogout,
  });

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia,';
    if (h < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }

  Color _pctColor(double pct) {
    if (pct >= 0.8) return const Color(0xFF86EFAC);
    if (pct >= 0.5) return const Color(0xFFFCD34D);
    return const Color(0xFFFCA5A5);
  }

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : taken / total;
    final pctInt = (pct * 100).round();

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
                color: Colors.white.withAlpha(14),
              ),
            ),
          ),
          Positioned(
            right: 25,
            bottom: 8,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(9),
              ),
            ),
          ),
          Positioned(
            left: -25,
            bottom: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(9),
              ),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  firstName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  '👋',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Avatar with initials
                      GestureDetector(
                        onTap: onLogout,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(35),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withAlpha(70),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              firstName.isNotEmpty
                                  ? firstName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(22),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withAlpha(45)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progresso do dia',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _pctColor(pct).withAlpha(50),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$pctInt%',
                                style: TextStyle(
                                  color: _pctColor(pct),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: Colors.white.withAlpha(45),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _pctColor(pct)),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _ProgressStat(
                              label: 'tomado${taken == 1 ? '' : 's'}',
                              value: '$taken',
                              color: const Color(0xFF86EFAC),
                            ),
                            const SizedBox(width: 18),
                            _ProgressStat(
                              label: 'pendente${(total - taken) == 1 ? '' : 's'}',
                              value: '${total - taken}',
                              color: Colors.white60,
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

class _ProgressStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ProgressStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ── Quick Stats ───────────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  final int taken;
  final int late;
  final int pending;

  const _QuickStats({
    required this.taken,
    required this.late,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(7),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _QuickStatItem(
              count: taken,
              label: 'Tomados',
              color: AppColors.success,
              icon: Icons.check_circle_rounded,
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.inputBorder.withAlpha(120),
            ),
            _QuickStatItem(
              count: late,
              label: 'Atrasados',
              color: AppColors.warning,
              icon: Icons.schedule_rounded,
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.inputBorder.withAlpha(120),
            ),
            _QuickStatItem(
              count: pending,
              label: 'Pendentes',
              color: AppColors.primary,
              icon: Icons.hourglass_top_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;

  const _QuickStatItem({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stock Alert ───────────────────────────────────────────────────────────────

class _StockAlertCard extends StatelessWidget {
  final String medName;
  final int remaining;

  const _StockAlertCard({required this.medName, required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFFD97706),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Apenas $remaining comprimido${remaining == 1 ? '' : 's'} restando',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF78350F),
                  ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (ctx) => TextButton(
              onPressed: () => ctx.push(
                AppRoutes.lowStockDetail,
                extra: {
                  'medName': medName,
                  'dose': '500mg — 1 comprimido por dose',
                  'remaining': remaining,
                  'estimatedTotal': 14,
                },
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD97706),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Ver detalhes',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Medication Card ───────────────────────────────────────────────────────────

class _MedicationCard extends StatelessWidget {
  final Medication med;

  const _MedicationCard({required this.med});

  Color get _statusColor => switch (med.status) {
        MedicationStatus.tomado => AppColors.success,
        MedicationStatus.atrasado => AppColors.warning,
        MedicationStatus.pendente => AppColors.primary,
      };

  String get _statusLabel => switch (med.status) {
        MedicationStatus.tomado => 'Tomado',
        MedicationStatus.atrasado => 'Atrasado',
        MedicationStatus.pendente => 'Pendente',
      };

  IconData get _statusIcon => switch (med.status) {
        MedicationStatus.tomado => Icons.check_circle_rounded,
        MedicationStatus.atrasado => Icons.schedule_rounded,
        MedicationStatus.pendente => Icons.medication_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: _statusColor, width: 4),
        ),
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
                    _statusColor.withAlpha(35),
                    _statusColor.withAlpha(15),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _statusColor.withAlpha(45),
                  width: 1,
                ),
              ),
              child: Icon(_statusIcon, color: _statusColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    med.dose,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          med.formattedTime,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ),
                if (med.status != MedicationStatus.tomado) ...[
                  const SizedBox(height: 8),
                  _GradientButton(onTap: () {}),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GradientButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(70),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Confirmar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.backgroundWhite,
      elevation: 12,
      onTap: (i) {
        if (i == 1) context.go(AppRoutes.history);
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
    );
  }
}
