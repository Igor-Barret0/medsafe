import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../widgets/profile_edit_widgets.dart';

// ── Central de ajuda ──────────────────────────────────────────────────────────

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  static const _faqItems = [
    _FaqItem(
      question: 'Como adicionar medicamento?',
      answer:
          'Na tela inicial, toque em "Adicionar". Preencha nome, dose, frequência e horário. Confirme em "Salvar" para ativar os lembretes.',
    ),
    _FaqItem(
      question: 'Como cadastrar cuidador?',
      answer:
          'Acesse Configurações e abra a área de gerenciamento da conta. Selecione "Vincular cuidador" e informe o e-mail de convite.',
    ),
    _FaqItem(
      question: 'Como ativar notificações?',
      answer:
          'Vá em Configurações > Notificações e habilite os tipos desejados. No sistema do celular, permita notificações para o app.',
    ),
    _FaqItem(
      question: 'Como recuperar senha?',
      answer:
          'Na tela de login, toque em "Esqueci minha senha". Informe seu e-mail para receber o link de redefinição.',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? _faqItems
        : _faqItems
            .where((f) => f.question.toLowerCase().contains(_query))
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          const ProfileEditHeader(
            title: 'Central de ajuda',
            subtitle: 'Perguntas frequentes',
            icon: Icons.help_outline_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha(7),
                          blurRadius: 12,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Buscar dúvidas...',
                      hintStyle: const TextStyle(
                          color: AppColors.textHint, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textSecondary, size: 20),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded,
                                  size: 18, color: AppColors.textSecondary),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const ProfileInfoCard(
                  icon: Icons.lightbulb_outline_rounded,
                  text:
                      'Toque em uma pergunta para ver a resposta completa.',
                ),
                const SizedBox(height: 16),
                // FAQ card
                Container(
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
                  child: filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(14),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.search_off_rounded,
                                    color: AppColors.primary, size: 26),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Nenhuma pergunta encontrada',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tente outro termo ou entre em contato.',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: filtered
                              .asMap()
                              .entries
                              .map((e) => _FaqTile(
                                    item: e.value,
                                    isLast: e.key == filtered.length - 1,
                                  ))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                // "Não encontrou?" card
                Container(
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
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.headerGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.support_agent_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Não encontrou?',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Nossa equipe responde em até 24h.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ContactSupportPage()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Contatar',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
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

// ── Fale conosco ──────────────────────────────────────────────────────────────

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  String? _selectedSubject;
  PlatformFile? _attachment;
  bool _isSending = false;

  static const _subjects = [
    'Dúvida sobre cadastro',
    'Problema em notificações',
    'Conta e acesso',
    'Sugestão de melhoria',
    'Outro',
  ];

  bool get _canSend =>
      _nameCtrl.text.isNotEmpty &&
      _emailCtrl.text.isNotEmpty &&
      _selectedSubject != null &&
      _messageCtrl.text.length >= 10;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
    _emailCtrl.addListener(() => setState(() {}));
    _messageCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'pdf'],
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    setState(() => _attachment = result.files.first);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _isSending = false;
      _attachment = null;
      _selectedSubject = null;
    });
    _formKey.currentState?.reset();
    _nameCtrl.clear();
    _emailCtrl.clear();
    _messageCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mensagem enviada com sucesso!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          const ProfileEditHeader(
            title: 'Fale conosco',
            subtitle: 'Atendimento via e-mail',
            icon: Icons.chat_bubble_outline_rounded,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  const ProfileInfoCard(
                    icon: Icons.schedule_rounded,
                    text:
                        'Respondemos em até 24 horas úteis. Seja o mais detalhado possível.',
                  ),
                  const SizedBox(height: 20),
                  ProfileFormCard(
                    children: [
                      CustomTextField(
                        label: 'Nome completo',
                        hint: 'Digite seu nome',
                        controller: _nameCtrl,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Informe seu nome'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'E-mail',
                        hint: 'voce@email.com',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Informe seu e-mail';
                          if (!EmailValidator.validate(t)) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _DropdownField<String>(
                        label: 'Assunto',
                        hint: 'Selecione um assunto',
                        icon: Icons.topic_outlined,
                        value: _selectedSubject,
                        items: _subjects,
                        itemLabel: (s) => s,
                        onChanged: (v) => setState(() => _selectedSubject = v),
                        validator: (v) =>
                            v == null ? 'Selecione um assunto' : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Mensagem',
                        hint: 'Descreva sua dúvida com detalhes...',
                        controller: _messageCtrl,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        validator: (v) => (v == null || v.trim().length < 10)
                            ? 'Escreva ao menos 10 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _AttachmentField(
                        subtitle: 'PNG, JPG ou PDF',
                        file: _attachment,
                        onPick: _pickAttachment,
                        onRemove: () => setState(() => _attachment = null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ProfileSaveButton(
                    label: 'Enviar mensagem',
                    enabled: _canSend,
                    isLoading: _isSending,
                    onPressed: _submit,
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

// ── Reportar problema ─────────────────────────────────────────────────────────

class ReportProblemPage extends StatefulWidget {
  const ReportProblemPage({super.key});

  @override
  State<ReportProblemPage> createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();

  String? _problemType;
  PlatformFile? _attachment;
  bool _isSending = false;
  double _progress = 0;

  String _appVersion = '—';
  String _device = '—';
  String _system = '—';

  static const _problemTypes = [
    'Bug no aplicativo',
    'Erro em notificação',
    'Problema com cadastro',
    'Outro',
  ];

  bool get _canSend =>
      _problemType != null && _descCtrl.text.trim().length >= 12;

  @override
  void initState() {
    super.initState();
    _descCtrl.addListener(() => setState(() {}));
    _loadDeviceContext();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceContext() async {
    final pkg = await PackageInfo.fromPlatform();
    final info = DeviceInfoPlugin();
    String deviceName = 'Não identificado';
    String systemName = 'Não identificado';

    try {
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        deviceName = '${a.manufacturer} ${a.model}';
        systemName = 'Android ${a.version.release}';
      } else if (Platform.isIOS) {
        final i = await info.iosInfo;
        deviceName = '${i.name} ${i.model}';
        systemName = 'iOS ${i.systemVersion}';
      } else {
        systemName = Platform.operatingSystem;
      }
    } catch (_) {
      systemName = Platform.operatingSystem;
    }

    if (!mounted) return;
    setState(() {
      _appVersion = '${pkg.version}+${pkg.buildNumber}';
      _device = deviceName;
      _system = systemName;
    });
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'mp4', 'mov'],
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    setState(() => _attachment = result.files.first);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _problemType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
      _progress = 0;
    });

    for (var i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 140));
      if (!mounted) return;
      setState(() => _progress = i / 10);
    }

    if (!mounted) return;
    setState(() {
      _isSending = false;
      _problemType = null;
      _attachment = null;
      _progress = 0;
    });
    _formKey.currentState?.reset();
    _descCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Relatório enviado com sucesso!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          const ProfileEditHeader(
            title: 'Reportar problema',
            subtitle: 'Nos ajude a melhorar o app',
            icon: Icons.flag_outlined,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  const ProfileInfoCard(
                    icon: Icons.info_outline_rounded,
                    text:
                        'Descreva o que aconteceu. Dados técnicos do dispositivo são coletados automaticamente.',
                  ),
                  const SizedBox(height: 20),
                  ProfileFormCard(
                    children: [
                      _DropdownField<String>(
                        label: 'Tipo de problema',
                        hint: 'Selecione o tipo',
                        icon: Icons.bug_report_outlined,
                        value: _problemType,
                        items: _problemTypes,
                        itemLabel: (s) => s,
                        onChanged: (v) => setState(() => _problemType = v),
                        validator: (v) =>
                            v == null ? 'Selecione o tipo de problema' : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Descrição',
                        hint:
                            'Conte o que aconteceu, quando ocorreu e como reproduzir...',
                        controller: _descCtrl,
                        maxLines: 6,
                        textInputAction: TextInputAction.newline,
                        validator: (v) =>
                            (v == null || v.trim().length < 12)
                                ? 'Descreva o problema com mais detalhes'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      // Context info card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(14),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                      Icons.phone_android_outlined,
                                      color: AppColors.primary,
                                      size: 14),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Contexto técnico (automático)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _ContextRow(
                                label: 'Versão', value: _appVersion),
                            _ContextRow(
                                label: 'Dispositivo', value: _device),
                            _ContextRow(label: 'Sistema', value: _system),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _AttachmentField(
                        subtitle: 'Screenshot ou vídeo (PNG, MP4)',
                        file: _attachment,
                        onPick: _pickAttachment,
                        onRemove: () => setState(() => _attachment = null),
                      ),
                    ],
                  ),
                  if (_isSending) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(7),
                              blurRadius: 10,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cloud_upload_outlined,
                                  color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Enviando... ${(_progress * 100).toInt()}%',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              minHeight: 6,
                              value: _progress,
                              color: AppColors.primary,
                              backgroundColor: AppColors.primary.withAlpha(30),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ProfileSaveButton(
                    label: 'Enviar relatório',
                    enabled: _canSend,
                    isLoading: _isSending,
                    onPressed: _submit,
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

class _FaqTile extends StatelessWidget {
  final _FaqItem item;
  final bool isLast;

  const _FaqTile({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            iconColor: AppColors.primary,
            collapsedIconColor: AppColors.textSecondary,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.quiz_outlined,
                  color: AppColors.primary, size: 18),
            ),
            title: Text(
              item.question,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.answer,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 68, endIndent: 16),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(itemLabel(item)),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

class _AttachmentField extends StatelessWidget {
  final String subtitle;
  final PlatformFile? file;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _AttachmentField({
    required this.subtitle,
    required this.file,
    required this.onPick,
    required this.onRemove,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Anexo',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.textHint.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'opcional',
                style:
                    TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (file == null)
          GestureDetector(
            onTap: onPick,
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.upload_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecionar arquivo',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.insert_drive_file_outlined,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file!.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatSize(file!.size),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ContextRow extends StatelessWidget {
  final String label;
  final String value;

  const _ContextRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}
