import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../widgets/profile_edit_widgets.dart';
import 'support_pages.dart';

// ── Termos de uso ─────────────────────────────────────────────────────────────

class TermsOfUsePage extends StatefulWidget {
  const TermsOfUsePage({super.key});

  @override
  State<TermsOfUsePage> createState() => _TermsOfUsePageState();
}

class _TermsOfUsePageState extends State<TermsOfUsePage> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          const ProfileEditHeader(
            title: 'Termos de uso',
            subtitle: 'Leia antes de utilizar o Medsafe',
            icon: Icons.description_outlined,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta badges
                  Row(
                    children: [
                      _MetaBadge(
                        icon: Icons.calendar_today_outlined,
                        label: 'Atualizado em 10/04/2026',
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      _MetaBadge(
                        icon: Icons.bookmark_outline_rounded,
                        label: 'v1.0',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ProfileInfoCard(
                    icon: Icons.info_outline_rounded,
                    text:
                        'Ao utilizar o Medsafe você concorda com estes termos. Leia com atenção antes de aceitar.',
                  ),
                  const SizedBox(height: 16),
                  _LegalCard(
                    accentColor: AppColors.primary,
                    sections: const [
                      _Section(
                        number: 1,
                        title: 'Aceitação dos termos',
                        body:
                            'Ao acessar e utilizar o Medsafe, você concorda com estes Termos de Uso. Caso não concorde com qualquer condição, recomendamos não continuar a utilização do aplicativo.',
                      ),
                      _Section(
                        number: 2,
                        title: 'Uso do aplicativo',
                        body:
                            'O Medsafe auxilia no gerenciamento de medicamentos, lembretes e acompanhamento de rotina. O uso deve ser feito de forma responsável e com informações verdadeiras.',
                      ),
                      _Section(
                        number: 3,
                        title: 'Responsabilidades do usuário',
                        body:
                            'Você é responsável pela veracidade dos dados cadastrados, proteção de acesso à conta e uso adequado das funcionalidades. Não compartilhe suas credenciais com terceiros.',
                      ),
                      _Section(
                        number: 4,
                        title: 'Limitações de responsabilidade',
                        body:
                            'O Medsafe não substitui orientação médica. O aplicativo fornece suporte de organização e lembretes, sem garantia de resultados clínicos ou substituição de tratamento profissional.',
                      ),
                      _Section(
                        number: 5,
                        title: 'Alterações nos termos',
                        body:
                            'Podemos atualizar estes termos periodicamente para refletir melhorias e exigências legais. Mudanças relevantes serão informadas no aplicativo.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Agree row
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _agreed
                              ? AppColors.primary.withAlpha(90)
                              : AppColors.inputBorder,
                          width: _agreed ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(7),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color:
                                  _agreed ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _agreed
                                    ? AppColors.primary
                                    : AppColors.inputBorder,
                                width: 2,
                              ),
                            ),
                            child: _agreed
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 13)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Li e concordo com os Termos de Uso',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProfileSaveButton(
                    label: 'Aceitar termos',
                    enabled: _agreed,
                    isLoading: false,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Termos aceitos com sucesso!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 10),
                  ProfileCancelButton(
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Política de privacidade ───────────────────────────────────────────────────

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _privacyColor = Color(0xFF0EA5E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          const ProfileEditHeader(
            title: 'Política de privacidade',
            subtitle: 'Como tratamos seus dados',
            icon: Icons.shield_outlined,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _MetaBadge(
                        icon: Icons.calendar_today_outlined,
                        label: 'Atualizado em 10/04/2026',
                        color: _privacyColor,
                      ),
                      const SizedBox(width: 8),
                      _MetaBadge(
                        icon: Icons.gavel_rounded,
                        label: 'LGPD',
                        color: _privacyColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ProfileInfoCard(
                    icon: Icons.verified_user_outlined,
                    text:
                        'Seus dados são usados somente para o funcionamento do app e nunca vendidos a terceiros.',
                    color: _privacyColor,
                  ),
                  const SizedBox(height: 16),
                  const _LegalCard(
                    accentColor: _privacyColor,
                    sections: [
                      _Section(
                        number: 1,
                        title: 'Dados coletados',
                        body:
                            'Coletamos dados como nome, e-mail e informações de uso do aplicativo para permitir autenticação, personalização e funcionamento dos lembretes.',
                      ),
                      _Section(
                        number: 2,
                        title: 'Como usamos os dados',
                        body:
                            'Utilizamos os dados para melhorar sua experiência, enviar notificações de medicamentos e oferecer suporte com maior qualidade e segurança.',
                      ),
                      _Section(
                        number: 3,
                        title: 'Compartilhamento',
                        body:
                            'Podemos integrar APIs e serviços de terceiros necessários ao funcionamento do app, sempre com controles e contratos adequados de proteção de dados.',
                      ),
                      _Section(
                        number: 4,
                        title: 'Segurança',
                        body:
                            'Adotamos boas práticas de segurança, como proteção de credenciais, criptografia em trânsito e controles de acesso para reduzir riscos.',
                      ),
                      _Section(
                        number: 5,
                        title: 'Direitos do usuário',
                        body:
                            'Você pode acessar, corrigir e solicitar exclusão dos seus dados, conforme legislação aplicável e canais oficiais de atendimento.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // LGPD guarantee card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.success.withAlpha(18),
                          AppColors.success.withAlpha(8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.success.withAlpha(55)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.verified_rounded,
                              color: AppColors.success, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dados 100% protegidos',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Seus dados nunca são vendidos a terceiros.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _OutlineActionButton(
                          icon: Icons.download_rounded,
                          label: 'Baixar PDF',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Download em preparação.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _GradientActionButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Contato',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ContactSupportPage(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ProfileCancelButton(
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalCard extends StatelessWidget {
  final Color accentColor;
  final List<_Section> sections;

  const _LegalCard({
    required this.accentColor,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        children: sections.asMap().entries.map((e) {
          final isLast = e.key == sections.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${e.value.number}',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 13,
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
                            e.value.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            e.value.body,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 60,
                  endIndent: 18,
                  color: AppColors.inputBorder,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _Section {
  final int number;
  final String title;
  final String body;

  const _Section({
    required this.number,
    required this.title,
    required this.body,
  });
}

class _OutlineActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlineActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GradientActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(60),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
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
