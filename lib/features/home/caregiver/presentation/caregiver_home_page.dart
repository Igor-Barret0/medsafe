import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';
import 'pages/add_elderly_page.dart';
import 'pages/caregiver_history_page.dart';
import 'pages/elderly_details_page.dart';

class CaregiverHomePage extends StatefulWidget {
  const CaregiverHomePage({super.key});

  @override
  State<CaregiverHomePage> createState() => _CaregiverHomePageState();
}

enum _HomeViewState { loading, ready, error }

class _CaregiverHomePageState extends State<CaregiverHomePage> {
  _HomeViewState _viewState = _HomeViewState.loading;
  _CaregiverHomeData? _data;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() => _viewState = _HomeViewState.loading);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 550));

      const elderlies = [
        _ElderlyItem(
          name: 'Maria Oliveira',
          age: 74,
          medicationCount: 3,
          takenToday: 2,
          status: _ElderlyStatus.normal,
        ),
        _ElderlyItem(
          name: 'João Pereira',
          age: 80,
          medicationCount: 4,
          takenToday: 1,
          status: _ElderlyStatus.attention,
        ),
        _ElderlyItem(
          name: 'Antônio Santos',
          age: 69,
          medicationCount: 2,
          takenToday: 2,
          status: _ElderlyStatus.normal,
        ),
      ];

      const alerts = [
        _ImportantAlert(
          message: 'João Pereira esqueceu o medicamento das 14h.',
          type: _AlertType.missedDose,
          time: '14:05',
        ),
        _ImportantAlert(
          message: 'Maria Oliveira tem medicamento acabando.',
          type: _AlertType.lowStock,
          time: '09:30',
        ),
      ];

      const taken = 6;
      const today = 8;

      _data = _CaregiverHomeData(
        summary: _SummaryData(
          monitoredElderlies: elderlies.length,
          medicationsToday: today,
          taken: taken,
          pending: today - taken,
        ),
        elderlies: elderlies,
        alerts: alerts,
      );

      if (!mounted) return;
      setState(() => _viewState = _HomeViewState.ready);
    } catch (_) {
      if (!mounted) return;
      setState(() => _viewState = _HomeViewState.error);
    }
  }

  Future<void> _goToAddElderly() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddElderlyPage()));
    if (!mounted) return;
    await _loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _CaregiverHeader(
            userName: user?.name ?? 'Cuidador',
            onOpenNotifications: () =>
                ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Notificações em breve.'),
                  behavior: SnackBarBehavior.floating),
            ),
            onLogout: () async {
              await context.read<AuthController>().logout();
              if (!context.mounted) return;
              context.go(AppRoutes.login);
            },
          ),
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundWhite,
        elevation: 12,
        onTap: (i) {
          if (i == 1) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const CaregiverHistoryPage()));
          }
          if (i == 2) context.go(AppRoutes.settings);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Início'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded), label: 'Histórico'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'Config.'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_viewState == _HomeViewState.loading) {
      return const _LoadingState();
    }
    if (_viewState == _HomeViewState.error || _data == null) {
      return _ErrorState(onRetry: _loadHomeData);
    }
    final data = _data!;
    if (data.elderlies.isEmpty) {
      return _EmptyState(onAdd: _goToAddElderly);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _StatsStrip(summary: data.summary),
        const SizedBox(height: 12),
        _AdherenceCard(summary: data.summary),
        const SizedBox(height: 24),
        _SectionLabel(
            text: 'IDOSOS SOB CUIDADOS',
            color: const Color(0xFF7C3AED)),
        const SizedBox(height: 10),
        for (var i = 0; i < data.elderlies.length; i++) ...[
          _ElderlyCard(
            item: data.elderlies[i],
            onDetails: () {
              final d = _resolveElderlyDetails(data.elderlies[i]);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ElderlyDetailsPage(
                  elderlyName: data.elderlies[i].name,
                  age: data.elderlies[i].age,
                  medicationCount: data.elderlies[i].medicationCount,
                  relationship: d.relationship,
                  medications: d.medications,
                  recentHistory: d.recentHistory,
                ),
              ));
            },
          ),
          if (i < data.elderlies.length - 1) const SizedBox(height: 12),
        ],
        if (data.alerts.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionLabel(
              text: 'ALERTAS IMPORTANTES',
              color: AppColors.warning),
          const SizedBox(height: 10),
          _AlertsCard(alerts: data.alerts),
        ],
        const SizedBox(height: 24),
        _AddElderlyButton(onPressed: _goToAddElderly),
      ],
    );
  }

  _ElderlyDetailsData _resolveElderlyDetails(_ElderlyItem item) {
    switch (item.name) {
      case 'João Pereira':
        return const _ElderlyDetailsData(
          relationship: 'Filho',
          medications: [
            ElderlyMedicationItem(
                name: 'Losartana',
                dosage: '50mg — 1 comprimido',
                time: '08:00',
                status: DoseStatus.taken),
            ElderlyMedicationItem(
                name: 'Metformina',
                dosage: '500mg — 2 comprimidos',
                time: '12:00',
                status: DoseStatus.late),
            ElderlyMedicationItem(
                name: 'Dipirona',
                dosage: '500mg — 1 comprimido',
                time: '14:00',
                status: DoseStatus.late),
            ElderlyMedicationItem(
                name: 'Atorvastatina',
                dosage: '20mg — 1 comprimido',
                time: '20:00',
                status: DoseStatus.pending),
          ],
          recentHistory: [
            RecentHistoryItem(message: 'Losartana tomada às 08:02', success: true),
            RecentHistoryItem(message: 'Metformina esquecida às 12:00', success: false),
            RecentHistoryItem(message: 'Dipirona esquecida às 14:00', success: false),
          ],
        );
      case 'Maria Oliveira':
        return const _ElderlyDetailsData(
          relationship: 'Mãe',
          medications: [
            ElderlyMedicationItem(
                name: 'Hidroclorotiazida',
                dosage: '25mg — 1 comprimido',
                time: '07:30',
                status: DoseStatus.taken),
            ElderlyMedicationItem(
                name: 'Sinvastatina',
                dosage: '20mg — 1 comprimido',
                time: '21:00',
                status: DoseStatus.pending),
            ElderlyMedicationItem(
                name: 'AAS',
                dosage: '100mg — 1 comprimido',
                time: '09:00',
                status: DoseStatus.taken),
          ],
          recentHistory: [
            RecentHistoryItem(message: 'Hidroclorotiazida tomada às 07:33', success: true),
            RecentHistoryItem(message: 'AAS tomada às 09:01', success: true),
            RecentHistoryItem(message: 'Sinvastatina pendente para 21:00', success: false),
          ],
        );
      default:
        return const _ElderlyDetailsData(
          relationship: 'Responsável',
          medications: [
            ElderlyMedicationItem(
                name: 'Omeprazol',
                dosage: '20mg — 1 cápsula',
                time: '07:00',
                status: DoseStatus.taken),
            ElderlyMedicationItem(
                name: 'Vitamina D',
                dosage: '1 gota — dose diária',
                time: '10:00',
                status: DoseStatus.pending),
          ],
          recentHistory: [
            RecentHistoryItem(message: 'Omeprazol tomado às 07:05', success: true),
            RecentHistoryItem(message: 'Vitamina D ainda não administrada', success: false),
          ],
        );
    }
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _CaregiverHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onOpenNotifications;
  final VoidCallback onLogout;

  const _CaregiverHeader({
    required this.userName,
    required this.onOpenNotifications,
    required this.onLogout,
  });

  String get _initials {
    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get _firstName => userName.split(' ').first;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

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
            left: -30,
            bottom: -30,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(9),
              ),
            ),
          ),
          Positioned(
            right: 60,
            bottom: -15,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(8),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                children: [
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
                  const SizedBox(width: 14),
                  // Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_greeting, $_firstName!',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          'Área do cuidador',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316).withAlpha(45),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFF97316).withAlpha(80)),
                          ),
                          child: const Text(
                            'Cuidador',
                            style: TextStyle(
                              color: Color(0xFFFBD38D),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification bell
                  _HeaderIconButton(
                    onTap: onOpenNotifications,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.notifications_none_rounded,
                            color: Colors.white, size: 22),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // More menu
                  PopupMenuButton<String>(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    onSelected: (v) {
                      if (v == 'logout') onLogout();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'logout', child: Text('Sair')),
                    ],
                    child: _HeaderIconButton(
                      onTap: null,
                      child: const Icon(Icons.more_horiz_rounded,
                          color: Colors.white, size: 22),
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

class _HeaderIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _HeaderIconButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(45)),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ── Stats strip ───────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final _SummaryData summary;

  const _StatsStrip({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(7),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          _StatCol(
            icon: Icons.groups_rounded,
            value: '${summary.monitoredElderlies}',
            label: 'Idosos',
            color: const Color(0xFF7C3AED),
          ),
          _VerticalDivider(),
          _StatCol(
            icon: Icons.medication_rounded,
            value: '${summary.medicationsToday}',
            label: 'Meds hoje',
            color: AppColors.primary,
          ),
          _VerticalDivider(),
          _StatCol(
            icon: Icons.check_circle_outline_rounded,
            value: '${summary.taken}',
            label: 'Tomados',
            color: AppColors.success,
          ),
          _VerticalDivider(),
          _StatCol(
            icon: Icons.schedule_rounded,
            value: '${summary.pending}',
            label: 'Pendentes',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCol({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50,
      color: AppColors.inputBorder,
    );
  }
}

// ── Adherence card ────────────────────────────────────────────────────────────

class _AdherenceCard extends StatelessWidget {
  final _SummaryData summary;

  const _AdherenceCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final pct = summary.medicationsToday > 0
        ? summary.taken / summary.medicationsToday
        : 0.0;
    final pctInt = (pct * 100).toInt();
    final progressColor = pct >= 0.75
        ? AppColors.success
        : pct >= 0.5
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(7),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: progressColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.track_changes_rounded,
                    color: progressColor, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aderência hoje',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary),
                    ),
                    Text(
                      'Progresso geral dos medicamentos',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                '$pctInt%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: progressColor,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              color: progressColor,
              backgroundColor: Colors.black.withAlpha(10),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _AdherencePill(
                icon: Icons.check_circle_outline_rounded,
                label: '${summary.taken} tomados',
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _AdherencePill(
                icon: Icons.schedule_rounded,
                label: '${summary.pending} pendentes',
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdherencePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _AdherencePill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600),
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
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
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
      ),
    );
  }
}

// ── Elderly card ──────────────────────────────────────────────────────────────

class _ElderlyCard extends StatelessWidget {
  final _ElderlyItem item;
  final VoidCallback onDetails;

  const _ElderlyCard({required this.item, required this.onDetails});

  String get _initials {
    final parts = item.name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color get _statusColor => switch (item.status) {
        _ElderlyStatus.normal => const Color(0xFF7C3AED),
        _ElderlyStatus.attention => const Color(0xFFD97706),
        _ElderlyStatus.critical => const Color(0xFFDC2626),
      };

  List<Color> get _avatarGradient => switch (item.status) {
        _ElderlyStatus.normal => const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        _ElderlyStatus.attention => const [Color(0xFFF59E0B), Color(0xFFD97706)],
        _ElderlyStatus.critical => const [Color(0xFFEF4444), Color(0xFFDC2626)],
      };

  String get _statusLabel => switch (item.status) {
        _ElderlyStatus.normal => 'Normal',
        _ElderlyStatus.attention => 'Atenção',
        _ElderlyStatus.critical => 'Crítico',
      };

  IconData get _statusIcon => switch (item.status) {
        _ElderlyStatus.normal => Icons.check_circle_outline_rounded,
        _ElderlyStatus.attention => Icons.warning_amber_rounded,
        _ElderlyStatus.critical => Icons.error_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final adherencePct = item.medicationCount > 0
        ? item.takenToday / item.medicationCount
        : 0.0;

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
          // Status bar — spans full card height via Positioned
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
          ),
          // Content — determines the Stack's intrinsic height
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Gradient avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _avatarGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _statusColor.withAlpha(50),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info
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
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  '${item.age} anos · ${item.medicationCount} meds',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _statusColor.withAlpha(16),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_statusIcon,
                                      color: _statusColor, size: 11),
                                  const SizedBox(width: 3),
                                  Text(
                                    _statusLabel,
                                    style: TextStyle(
                                      color: _statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Details button
                      GestureDetector(
                        onTap: onDetails,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(50),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Detalhes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Adherence mini bar
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Hoje: ${item.takenToday}/${item.medicationCount} tomados',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        '${(adherencePct * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: adherencePct,
                      minHeight: 5,
                      color: _statusColor,
                      backgroundColor: _statusColor.withAlpha(18),
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

// ── Alerts card ───────────────────────────────────────────────────────────────

class _AlertsCard extends StatelessWidget {
  final List<_ImportantAlert> alerts;

  const _AlertsCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(7),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: alerts.asMap().entries.map((e) {
          final isLast = e.key == alerts.length - 1;
          return Column(
            children: [
              _AlertRow(item: e.value),
              if (!isLast)
                const Divider(height: 1, indent: 62, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final _ImportantAlert item;

  const _AlertRow({required this.item});

  IconData get _icon => switch (item.type) {
        _AlertType.missedDose => Icons.error_outline_rounded,
        _AlertType.lowStock => Icons.inventory_2_outlined,
      };

  Color get _color => switch (item.type) {
        _AlertType.missedDose => AppColors.error,
        _AlertType.lowStock => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _color.withAlpha(18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.time,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _color.withAlpha(14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Ver',
              style: TextStyle(
                color: _color,
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

// ── Add elderly button ────────────────────────────────────────────────────────

class _AddElderlyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddElderlyButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(70),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Adicionar novo idoso',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── States ────────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(14),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Carregando acompanhamento...',
            style: TextStyle(
                color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(14),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 30, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            const Text(
              'Não foi possível carregar',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Verifique sua conexão e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Tentar novamente',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withAlpha(50),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.groups_rounded,
                  color: Colors.white, size: 38),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhum idoso cadastrado',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 17),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione o primeiro idoso para iniciar o acompanhamento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withAlpha(60),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Adicionar idoso',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _CaregiverHomeData {
  final _SummaryData summary;
  final List<_ElderlyItem> elderlies;
  final List<_ImportantAlert> alerts;

  const _CaregiverHomeData({
    required this.summary,
    required this.elderlies,
    required this.alerts,
  });
}

class _SummaryData {
  final int monitoredElderlies;
  final int medicationsToday;
  final int taken;
  final int pending;

  const _SummaryData({
    required this.monitoredElderlies,
    required this.medicationsToday,
    required this.taken,
    required this.pending,
  });
}

enum _ElderlyStatus { normal, attention, critical }

class _ElderlyItem {
  final String name;
  final int age;
  final int medicationCount;
  final int takenToday;
  final _ElderlyStatus status;

  const _ElderlyItem({
    required this.name,
    required this.age,
    required this.medicationCount,
    required this.takenToday,
    required this.status,
  });
}

enum _AlertType { missedDose, lowStock }

class _ImportantAlert {
  final String message;
  final _AlertType type;
  final String time;

  const _ImportantAlert({
    required this.message,
    required this.type,
    required this.time,
  });
}

class _ElderlyDetailsData {
  final String relationship;
  final List<ElderlyMedicationItem> medications;
  final List<RecentHistoryItem> recentHistory;

  const _ElderlyDetailsData({
    required this.relationship,
    required this.medications,
    required this.recentHistory,
  });
}
