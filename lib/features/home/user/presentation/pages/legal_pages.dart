import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/widgets/custom_button.dart';
import 'support_pages.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            const _LegalHeader(title: 'Termos de uso'),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Atualizado em 10/04/2026',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _LegalCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegalSection(
                            title: '1. Aceitação dos termos',
                            body:
                                'Ao acessar e utilizar o Medsafe, você concorda com estes Termos de Uso. Caso não concorde com qualquer condição, recomendamos não continuar a utilização do aplicativo.',
                          ),
                          SizedBox(height: 16),
                          _LegalSection(
                            title: '2. Uso do aplicativo',
                            body:
                                'O Medsafe auxilia no gerenciamento de medicamentos, lembretes e acompanhamento de rotina. O uso deve ser feito de forma responsável e com informações verdadeiras.',
                          ),
                          SizedBox(height: 16),
                          _LegalSection(
                            title: '3. Responsabilidades do usuário',
                            body:
                                'Você é responsável pela veracidade dos dados cadastrados, proteção de acesso à conta e uso adequado das funcionalidades. Não compartilhe suas credenciais com terceiros.',
                          ),
                          SizedBox(height: 16),
                          _LegalSection(
                            title: '4. Limitações de responsabilidade',
                            body:
                                'O Medsafe não substitui orientação médica. O aplicativo fornece suporte de organização e lembretes, sem garantia de resultados clínicos ou substituição de tratamento profissional.',
                          ),
                          SizedBox(height: 16),
                          _LegalSection(
                            title: '5. Alterações nos termos',
                            body:
                                'Podemos atualizar estes termos periodicamente para refletir melhorias e exigências legais. Mudanças relevantes serão informadas no aplicativo.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _agreed,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              setState(() {
                                _agreed = value ?? false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Li e concordo com os termos',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Aceitar',
                      onPressed: _agreed
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Termos aceitos com sucesso.'),
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          : null,
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

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            const _LegalHeader(title: 'Política de privacidade'),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _LegalCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegalSection(
                            title: '1. Dados coletados',
                            body:
                                'Coletamos dados como nome, e-mail e informações de uso do aplicativo para permitir autenticação, personalização e funcionamento dos lembretes.',
                          ),
                          SizedBox(height: 16),
                          _LegalSection(
                            title: '2. Como usamos os dados',
                            body:
                                'Utilizamos os dados para melhorar sua experiência, enviar notificações de medicamentos e oferecer suporte com maior qualidade e segurança.',
                          ),
                          SizedBox(height: 16),
                          _LegalSection(
                            title: '3. Compartilhamento',
                            body:
                                'Podemos integrar APIs e serviços de terceiros necessários ao funcionamento do app, sempre com controles e contratos adequados de proteção de dados.',
                          ),
                          SizedBox(height: 16),
                          _LegalSection(
                            title: '4. Segurança',
                            body:
                                'Adotamos boas práticas de segurança, como proteção de credenciais, criptografia em trânsito e controles de acesso para reduzir riscos.',
                          ),
                          SizedBox(height: 16),
                          _LegalSection(
                            title: '5. Direitos do usuário',
                            body:
                                'Você pode acessar, corrigir e solicitar exclusão dos seus dados, conforme legislação aplicável e canais oficiais de atendimento.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(40),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Seus dados são protegidos e não vendidos a terceiros.',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: Color(0xFF1A1A1A),
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Download do PDF em preparação.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Baixar PDF'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ContactSupportPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_outlined),
                            label: const Text('Entrar em contato'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
      ),
    );
  }
}

class _LegalHeader extends StatelessWidget {
  final String title;

  const _LegalHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.of(context).pop(),
              child: Ink(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 31,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalCard extends StatelessWidget {
  final Widget child;

  const _LegalCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(7),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final String body;

  const _LegalSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
