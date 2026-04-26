import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../auth/domain/enums/user_role.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/routes/app_routes.dart';
import '../../../caregiver/presentation/pages/add_elderly_page.dart';
import '../../../caregiver/presentation/pages/caregiver_elderly_management_page.dart';
import '../../../caregiver/presentation/pages/caregiver_history_page.dart';
import '../../../caregiver/presentation/state/caregiver_elderly_store.dart';
import '../../../../../../core/widgets/edit_name_dialog.dart';
import 'change_email_page.dart';
import 'change_password_page.dart';
import 'legal_pages.dart';
import 'profile_photo_page.dart';
import 'support_pages.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifMeds = true;
  bool _notifEsquecido = true;
  bool _notifAcabando = false;

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sair da conta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthController>().logout();
      if (mounted) context.go(AppRoutes.login);
    }
  }

  Future<void> _showEditNameDialog(String currentName) async {
    await showDialog<String>(
      context: context,
      builder: (ctx) => EditNameDialog(initialName: currentName),
    );
  }

  void _showLgpdSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gerenciar dados da conta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Conforme a LGPD (Lei 13.709/2018), você tem direito à portabilidade e exclusão dos seus dados.',
              style:
                  TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Exportar meus dados'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              label: const Text(
                'Excluir minha conta',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final isCaregiver = user?.role == UserRole.cuidador;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _SettingsHeader(
            user: user,
            onEditName: () => _showEditNameDialog(user?.name ?? ''),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                // ── Perfil ───────────────────────────────────────────────
                _SectionLabel('Perfil', color: AppColors.primary),
                _SettingsCard(items: [
                  _SettingsRow(
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.primary,
                    title: 'Editar nome',
                    subtitle: user?.name ?? '',
                    onTap: () =>
                        _showEditNameDialog(user?.name ?? ''),
                  ),
                  _SettingsRow(
                    icon: Icons.email_outlined,
                    iconColor: AppColors.primary,
                    title: 'Alterar e-mail',
                    subtitle: user?.email ?? '',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChangeEmailPage(
                          currentEmail: user?.email ?? '',
                        ),
                      ),
                    ),
                  ),
                  _SettingsRow(
                    icon: Icons.lock_outline_rounded,
                    iconColor: AppColors.primary,
                    title: 'Alterar senha',
                    subtitle: 'Última alteração há 30 dias',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordPage(),
                      ),
                    ),
                  ),
                  _SettingsRow(
                    icon: Icons.camera_alt_outlined,
                    iconColor: AppColors.primary,
                    title: 'Foto de perfil',
                    subtitle: 'Toque para alterar',
                    isLast: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProfilePhotoPage(userName: user?.name ?? ''),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // ── Notificações ─────────────────────────────────────────
                _SectionLabel('Notificações',
                    color: const Color(0xFF8B5CF6)),
                _SettingsCard(items: [
                  _ToggleRow(
                    icon: Icons.notifications_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    title: 'Notificações de medicamentos',
                    subtitle: 'Alertas nos horários cadastrados',
                    value: _notifMeds,
                    onChanged: (v) => setState(() => _notifMeds = v),
                  ),
                  _ToggleRow(
                    icon: Icons.warning_amber_outlined,
                    iconColor: AppColors.warning,
                    title: 'Medicamento esquecido',
                    subtitle: 'Avisa quando não confirmado',
                    value: _notifEsquecido,
                    onChanged: (v) =>
                        setState(() => _notifEsquecido = v),
                  ),
                  _ToggleRow(
                    icon: Icons.inventory_2_outlined,
                    iconColor: AppColors.warning,
                    title: 'Estoque acabando',
                    subtitle: 'Avisa quando estoque está baixo',
                    value: _notifAcabando,
                    isLast: true,
                    onChanged: (v) =>
                        setState(() => _notifAcabando = v),
                  ),
                ]),

                const SizedBox(height: 20),

                // ── Privacidade ──────────────────────────────────────────
                _SectionLabel('Privacidade e segurança',
                    color: const Color(0xFF0EA5E9)),
                _SettingsCard(items: [
                  _SettingsRow(
                    icon: Icons.shield_outlined,
                    iconColor: const Color(0xFF0EA5E9),
                    title: 'Gerenciar dados da conta',
                    subtitle: 'Exportar ou excluir dados (LGPD)',
                    isLast: true,
                    onTap: _showLgpdSheet,
                  ),
                ]),

                const SizedBox(height: 20),

                // ── Idosos (cuidador) ────────────────────────────────────
                if (isCaregiver) ...[
                  _SectionLabel('Idosos monitorados',
                      color: const Color(0xFFF97316)),
                  ValueListenableBuilder<List<CaregiverElderly>>(
                    valueListenable:
                        CaregiverElderlyStore.instance.elderlies,
                    builder: (context, elderlies, _) {
                      final activeCount = elderlies
                          .where((e) =>
                              e.status == CaregiverElderlyStatus.active)
                          .length;

                      return _SettingsCard(items: [
                        _SettingsRow(
                          icon: Icons.manage_accounts_outlined,
                          iconColor: const Color(0xFFF97316),
                          title: 'Gerenciar idosos cadastrados',
                          subtitle: '$activeCount idosos ativos',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ManageElderliesPage(),
                            ),
                          ),
                        ),
                        _SettingsRow(
                          icon: Icons.person_add_outlined,
                          iconColor: const Color(0xFFF97316),
                          title: 'Adicionar novo idoso',
                          subtitle: 'Cadastrar novo acompanhamento',
                          onTap: () async {
                            final result = await Navigator.of(context)
                                .push<AddElderlyResult>(
                              MaterialPageRoute(
                                builder: (_) => const AddElderlyPage(),
                              ),
                            );
                            if (!context.mounted || result == null) return;
                            final nowMs = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            CaregiverElderlyStore.instance.add(
                              CaregiverElderly(
                                id: 'eld-$nowMs',
                                name: result.name,
                                age: result.age,
                                contact: result.contact,
                                medicationCount: 0,
                                lastActivity: 'Sem atividade ainda',
                                caregiverName: user?.name ?? 'Cuidador',
                                status: CaregiverElderlyStatus.active,
                              ),
                            );
                          },
                        ),
                        _SettingsRow(
                          icon: Icons.delete_outline_rounded,
                          iconColor: AppColors.error,
                          title: 'Remover idoso',
                          subtitle: 'Encerrar acompanhamento',
                          isLast: true,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ChooseElderlyForRemovalPage(),
                            ),
                          ),
                        ),
                      ]);
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Suporte ──────────────────────────────────────────────
                _SectionLabel('Suporte',
                    color: const Color(0xFF16A34A)),
                _SettingsCard(items: [
                  _SettingsRow(
                    icon: Icons.help_outline_rounded,
                    iconColor: const Color(0xFF16A34A),
                    title: 'Central de ajuda',
                    subtitle: 'Perguntas frequentes',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HelpCenterPage(),
                      ),
                    ),
                  ),
                  _SettingsRow(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: const Color(0xFF16A34A),
                    title: 'Fale conosco',
                    subtitle: 'Atendimento via e-mail',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ContactSupportPage(),
                      ),
                    ),
                  ),
                  _SettingsRow(
                    icon: Icons.flag_outlined,
                    iconColor: const Color(0xFF16A34A),
                    title: 'Reportar problema',
                    subtitle: 'Nos ajude a melhorar',
                    isLast: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReportProblemPage(),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // ── Sobre ────────────────────────────────────────────────
                _SectionLabel('Sobre o aplicativo',
                    color: AppColors.textSecondary),
                _SettingsCard(items: [
                  _SettingsRow(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.textSecondary,
                    title: 'Versão do aplicativo',
                    subtitle: 'Medsafe v1.0.0 — Projeto Acadêmico',
                    showChevron: false,
                    onTap: null,
                  ),
                  _SettingsRow(
                    icon: Icons.description_outlined,
                    iconColor: AppColors.textSecondary,
                    title: 'Termos de uso',
                    subtitle: '',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TermsOfUsePage(),
                      ),
                    ),
                  ),
                  _SettingsRow(
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.textSecondary,
                    title: 'Política de privacidade',
                    subtitle: '',
                    isLast: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyPage(),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 28),

                // ── Logout ───────────────────────────────────────────────
                _LogoutButton(onTap: _logout),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundWhite,
        elevation: 12,
        onTap: (i) {
          if (i == 0) {
            context.go(isCaregiver ? AppRoutes.caregiverHome : AppRoutes.userHome);
          }
          if (i == 1) {
            if (isCaregiver) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const CaregiverHistoryPage()));
            } else {
              context.go(AppRoutes.history);
            }
          }
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
}

// ── Header ────────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  final dynamic user;
  final VoidCallback onEditName;

  const _SettingsHeader({required this.user, required this.onEditName});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'Usuário';
    final email = user?.email ?? '';
    final initial = name[0].toUpperCase();
    final isCaregiver = user?.role == UserRole.cuidador;
    final roleLabel = isCaregiver ? 'Cuidador' : 'Paciente';
    final roleColor = isCaregiver
        ? const Color(0xFFF97316)
        : const Color(0xFF86EFAC);

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
                  // Title
                  const Text(
                    'Configurações',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'Gerencie seu perfil e preferências',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  // Profile card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(22),
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: Colors.white.withAlpha(45)),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(35),
                            border: Border.all(
                              color: Colors.white.withAlpha(80),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 7),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: roleColor.withAlpha(45),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: roleColor.withAlpha(80),
                                  ),
                                ),
                                child: Text(
                                  roleLabel,
                                  style: TextStyle(
                                    color: roleColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: onEditName,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Editar',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
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

// ── Reusable components ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionLabel(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
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
            text.toUpperCase(),
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

class _SettingsCard extends StatelessWidget {
  final List<Widget> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(7),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLast;
  final bool showChevron;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(18),
            bottom: isLast ? const Radius.circular(18) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (showChevron)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 68, endIndent: 16),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppColors.inputBorder,
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 68, endIndent: 16),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.error.withAlpha(70),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Sair da conta',
              style: TextStyle(
                color: AppColors.error,
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
