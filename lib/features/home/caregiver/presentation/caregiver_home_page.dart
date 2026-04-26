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
          status: _ElderlyStatus.normal,
        ),
        _ElderlyItem(
          name: 'João Pereira',
          age: 80,
          medicationCount: 4,
          status: _ElderlyStatus.attention,
        ),
        _ElderlyItem(
          name: 'Antônio Santos',
          age: 69,
          medicationCount: 2,
          status: _ElderlyStatus.normal,
        ),
      ];

      const alerts = [
        _ImportantAlert(
          message: 'João Pereira esqueceu o medicamento das 14h.',
          type: _AlertType.missedDose,
        ),
        _ImportantAlert(
          message: 'Maria Oliveira tem medicamento acabando.',
          type: _AlertType.lowStock,
        ),
      ];

      final taken = 6;
      final today = 8;

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
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddElderlyPage()));
    if (!mounted) return;
    await _loadHomeData();
  }

  void _showFeatureSoon(String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label em breve.')));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          _CaregiverHeader(
            userName: user?.name ?? 'Cuidador',
            onOpenNotifications: () => _showFeatureSoon('Notificações'),
            onProfileAction: (value) async {
              if (value == 'profile') {
                _showFeatureSoon('Perfil do cuidador');
                return;
              }

              if (value == 'logout') {
                final auth = this.context.read<AuthController>();
                await auth.logout();
                if (!mounted) return;
                this.context.go(AppRoutes.login);
              }
            },
          ),
          Expanded(child: _buildHomeContent()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundWhite,
        elevation: 12,
        onTap: (index) {
          if (index == 2) {
            context.push(AppRoutes.settings);
            return;
          }

          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CaregiverHistoryPage(),
              ),
            );
            return;
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

  Widget _buildHomeContent() {
    if (_viewState == _HomeViewState.loading) {
      return const _LoadingState();
    }

    if (_viewState == _HomeViewState.error) {
      return _ErrorState(onRetry: _loadHomeData);
    }

    final data = _data;
    if (data == null) {
      return _ErrorState(onRetry: _loadHomeData);
    }

    final hasNoElderlies = data.elderlies.isEmpty;

    if (hasNoElderlies) {
      return _EmptyState(onAddElderly: _goToAddElderly);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
      children: [
        const _SectionTitle('RESUMO DO ACOMPANHAMENTO'),
        const SizedBox(height: 10),
        _SummaryGrid(summary: data.summary),
        const SizedBox(height: 14),
        const _SectionTitle('IDOSOS SOB SEUS CUIDADOS'),
        const SizedBox(height: 10),
        ..._buildElderlyList(data.elderlies),
        const SizedBox(height: 16),
        const _SectionTitle('AVISOS IMPORTANTES'),
        const SizedBox(height: 10),
        _ImportantAlertsCard(alerts: data.alerts),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _goToAddElderly,
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text('Adicionar novo idoso'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildElderlyList(List<_ElderlyItem> elderlies) {
    final widgets = <Widget>[];
    for (var i = 0; i < elderlies.length; i++) {
      widgets.add(
        _ElderlyCard(
          item: elderlies[i],
          onDetails: () {
            final details = _resolveElderlyDetails(elderlies[i]);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ElderlyDetailsPage(
                  elderlyName: elderlies[i].name,
                  age: elderlies[i].age,
                  medicationCount: elderlies[i].medicationCount,
                  relationship: details.relationship,
                  medications: details.medications,
                  recentHistory: details.recentHistory,
                ),
              ),
            );
          },
        ),
      );

      if (i < elderlies.length - 1) {
        widgets.add(const SizedBox(height: 10));
      }
    }
    return widgets;
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
              status: DoseStatus.taken,
            ),
            ElderlyMedicationItem(
              name: 'Metformina',
              dosage: '500mg — 2 comprimidos',
              time: '12:00',
              status: DoseStatus.late,
            ),
            ElderlyMedicationItem(
              name: 'Dipirona',
              dosage: '500mg — 1 comprimido',
              time: '14:00',
              status: DoseStatus.late,
            ),
            ElderlyMedicationItem(
              name: 'Atorvastatina',
              dosage: '20mg — 1 comprimido',
              time: '20:00',
              status: DoseStatus.pending,
            ),
          ],
          recentHistory: [
            RecentHistoryItem(
              message: 'Losartana tomada às 08:02',
              success: true,
            ),
            RecentHistoryItem(
              message: 'Metformina esquecida às 12:00',
              success: false,
            ),
            RecentHistoryItem(
              message: 'Dipirona esquecida às 14:00',
              success: false,
            ),
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
              status: DoseStatus.taken,
            ),
            ElderlyMedicationItem(
              name: 'Sinvastatina',
              dosage: '20mg — 1 comprimido',
              time: '21:00',
              status: DoseStatus.pending,
            ),
            ElderlyMedicationItem(
              name: 'AAS',
              dosage: '100mg — 1 comprimido',
              time: '09:00',
              status: DoseStatus.taken,
            ),
          ],
          recentHistory: [
            RecentHistoryItem(
              message: 'Hidroclorotiazida tomada às 07:33',
              success: true,
            ),
            RecentHistoryItem(message: 'AAS tomada às 09:01', success: true),
            RecentHistoryItem(
              message: 'Sinvastatina pendente para 21:00',
              success: false,
            ),
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
              status: DoseStatus.taken,
            ),
            ElderlyMedicationItem(
              name: 'Vitamina D',
              dosage: '1 gota — dose diária',
              time: '10:00',
              status: DoseStatus.pending,
            ),
          ],
          recentHistory: [
            RecentHistoryItem(
              message: 'Omeprazol tomado às 07:05',
              success: true,
            ),
            RecentHistoryItem(
              message: 'Vitamina D ainda não administrada',
              success: false,
            ),
          ],
        );
    }
  }
}

class _CaregiverHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onOpenNotifications;
  final ValueChanged<String> onProfileAction;

  const _CaregiverHeader({
    required this.userName,
    required this.onOpenNotifications,
    required this.onProfileAction,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = userName.split(' ').first;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, $firstName!',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      'Área do cuidador',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'Acompanhe os idosos sob seus cuidados.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: onOpenNotifications,
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.textWhite,
                      ),
                      Positioned(
                        top: 4,
                        right: 2,
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
              ),
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                color: AppColors.backgroundWhite,
                onSelected: onProfileAction,
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Text('Perfil'),
                  ),
                  PopupMenuItem<String>(value: 'logout', child: Text('Sair')),
                ],
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ],
          ),
        ),
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

class _SummaryGrid extends StatelessWidget {
  final _SummaryData summary;

  const _SummaryGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  value: '${summary.monitoredElderlies}',
                  label: 'Idosos monitorados',
                  textColor: AppColors.primary,
                  bgColor: Color(0xFFEFF3FF),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  value: '${summary.medicationsToday}',
                  label: 'Medicamentos hoje',
                  textColor: Color(0xFF7C3AED),
                  bgColor: Color(0xFFF3F1FF),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  value: '${summary.taken}',
                  label: 'Tomados',
                  textColor: Color(0xFF16A34A),
                  bgColor: Color(0xFFECF8EF),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  value: '${summary.pending}',
                  label: 'Pendentes',
                  textColor: Color(0xFFD97706),
                  bgColor: Color(0xFFFFF8E8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color textColor;
  final Color bgColor;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.textColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ElderlyStatus { normal, attention, critical }

class _ElderlyCard extends StatelessWidget {
  final _ElderlyItem item;
  final VoidCallback onDetails;

  const _ElderlyCard({required this.item, required this.onDetails});

  String get _initials {
    final parts = item.name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Color get _badgeColor => switch (item.status) {
    _ElderlyStatus.normal => const Color(0xFF7C3AED),
    _ElderlyStatus.attention => const Color(0xFFD97706),
    _ElderlyStatus.critical => const Color(0xFFDC2626),
  };

  Color get _badgeBg => switch (item.status) {
    _ElderlyStatus.normal => const Color(0xFFF1EBFF),
    _ElderlyStatus.attention => const Color(0xFFFFF7E8),
    _ElderlyStatus.critical => const Color(0xFFFEECEC),
  };

  Color get _borderColor => switch (item.status) {
    _ElderlyStatus.normal => Colors.transparent,
    _ElderlyStatus.attention => const Color(0xFFF2D08A),
    _ElderlyStatus.critical => const Color(0xFFFCA5A5),
  };

  String get _statusLabel => switch (item.status) {
    _ElderlyStatus.normal => 'Normal',
    _ElderlyStatus.attention => 'Atenção',
    _ElderlyStatus.critical => 'Crítico',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
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
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _badgeBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _initials,
              style: TextStyle(
                color: _badgeColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _badgeBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel,
                          style: TextStyle(
                            color: _badgeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.age} anos · ${item.medicationCount} medicamentos',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onDetails,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(86, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Ver detalhes'),
          ),
        ],
      ),
    );
  }
}

class _ImportantAlertsCard extends StatelessWidget {
  final List<_ImportantAlert> alerts;

  const _ImportantAlertsCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'Nenhum aviso importante no momento.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Container(
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
      child: Column(
        children: [
          for (var i = 0; i < alerts.length; i++) ...[
            _AlertRow(item: alerts[i]),
            if (i < alerts.length - 1)
              const Divider(height: 1, indent: 58, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final _ImportantAlert item;

  const _AlertRow({required this.item});

  IconData get _icon => switch (item.type) {
    _AlertType.missedDose => Icons.error_outline_rounded,
    _AlertType.lowStock => Icons.warning_amber_rounded,
  };

  Color get _iconColor => switch (item.type) {
    _AlertType.missedDose => AppColors.error,
    _AlertType.lowStock => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Detalhes do alerta em breve.')),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(36, 32),
              side: const BorderSide(color: AppColors.inputBorder),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Ver'),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(
            'Carregando acompanhamento...',
            style: TextStyle(color: AppColors.textSecondary),
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 34,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 10),
            const Text(
              'Não foi possível carregar os dados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Verifique sua conexão e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddElderly;

  const _EmptyState({required this.onAddElderly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nenhum idoso cadastrado ainda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Adicione o primeiro idoso para iniciar o acompanhamento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onAddElderly,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Adicionar novo idoso'),
            ),
          ],
        ),
      ),
    );
  }
}

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

class _ElderlyItem {
  final String name;
  final int age;
  final int medicationCount;
  final _ElderlyStatus status;

  const _ElderlyItem({
    required this.name,
    required this.age,
    required this.medicationCount,
    required this.status,
  });
}

enum _AlertType { missedDose, lowStock }

class _ImportantAlert {
  final String message;
  final _AlertType type;

  const _ImportantAlert({required this.message, required this.type});
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
