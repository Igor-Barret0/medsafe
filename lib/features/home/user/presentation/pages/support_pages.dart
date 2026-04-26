import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../core/widgets/custom_text_field.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<_FaqItem> _faqItems = const [
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filteredFaq = _faqItems
        .where((item) => item.question.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const _SupportHeader(title: 'Central de ajuda'),
            const SizedBox(height: 16),
            _SupportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar dúvidas...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                    ),
                  ),
                  if (query.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SuggestionList(
                      suggestions: filteredFaq,
                      onSelect: (question) {
                        _searchController.text = question;
                        setState(() {});
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SupportCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: filteredFaq.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: Text(
                        'Nenhuma pergunta encontrada. Tente outro termo.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : Column(
                      children: filteredFaq
                          .map(
                            (item) => _FaqTile(
                              item: item,
                              key: ValueKey(item.question),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 14),
            _SupportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Não encontrou?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Nossa equipe pode te ajudar por e-mail.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Fale conosco',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ContactSupportPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  String? _selectedSubject;
  PlatformFile? _attachment;
  bool _isSending = false;

  static const List<String> _subjects = [
    'Dúvida sobre cadastro',
    'Problema em notificações',
    'Conta e acesso',
    'Sugestão de melhoria',
    'Outro',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'pdf'],
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    setState(() {
      _attachment = result.files.first;
    });
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios.')),
      );
      return;
    }

    setState(() => _isSending = true);

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _isSending = false;
      _attachment = null;
      _selectedSubject = null;
    });
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mensagem enviada com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const _SupportHeader(title: 'Fale conosco'),
            const SizedBox(height: 16),
            _SupportCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Nome',
                      hint: 'Digite seu nome completo',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe seu nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Email',
                      hint: 'voce@email.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Informe seu e-mail';
                        if (!EmailValidator.validate(text)) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Assunto',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSubject,
                      decoration: const InputDecoration(
                        hintText: 'Selecione um assunto',
                      ),
                      items: _subjects
                          .map(
                            (subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedSubject = value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione um assunto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Mensagem',
                      hint: 'Descreva sua dúvida com detalhes',
                      controller: _messageController,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      validator: (value) {
                        if (value == null || value.trim().length < 10) {
                          return 'Escreva ao menos 10 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _AttachmentField(
                      title: 'Anexo (opcional)',
                      subtitle: 'Print do erro',
                      file: _attachment,
                      onPick: _pickAttachment,
                      onRemove: () => setState(() => _attachment = null),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Respondemos em até 24h.',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Enviar mensagem',
                      isLoading: _isSending,
                      onPressed: _submitForm,
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

class ReportProblemPage extends StatefulWidget {
  const ReportProblemPage({super.key});

  @override
  State<ReportProblemPage> createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String? _problemType;
  PlatformFile? _attachment;
  bool _isSending = false;
  double _progress = 0;

  String _appVersion = 'Carregando...';
  String _device = 'Carregando...';
  String _system = 'Carregando...';

  static const List<String> _problemTypes = [
    'Bug',
    'Erro no app',
    'Problema com notificação',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    _loadDeviceContext();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceContext() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final infoPlugin = DeviceInfoPlugin();

    String deviceName = 'Dispositivo não identificado';
    String systemName = 'Sistema não identificado';

    try {
      if (Platform.isAndroid) {
        final android = await infoPlugin.androidInfo;
        deviceName = '${android.manufacturer} ${android.model}';
        systemName = 'Android ${android.version.release}';
      } else if (Platform.isIOS) {
        final ios = await infoPlugin.iosInfo;
        deviceName = '${ios.name} ${ios.model}';
        systemName = 'iOS ${ios.systemVersion}';
      } else {
        systemName = Platform.operatingSystem;
      }
    } catch (_) {
      systemName = Platform.operatingSystem;
    }

    if (!mounted) return;

    setState(() {
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
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

    setState(() {
      _attachment = result.files.first;
    });
  }

  Future<void> _submitReport() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _problemType == null) {
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
      await Future<void>.delayed(const Duration(milliseconds: 140));
      if (!mounted) return;
      setState(() {
        _progress = i / 10;
      });
    }

    if (!mounted) return;

    setState(() {
      _isSending = false;
      _problemType = null;
      _attachment = null;
      _progress = 0;
    });
    _formKey.currentState?.reset();
    _descriptionController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Relatório enviado com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const _SupportHeader(title: 'Reportar problema'),
            const SizedBox(height: 16),
            _SupportCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de problema',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _problemType,
                      decoration: const InputDecoration(
                        hintText: 'Selecione o tipo',
                      ),
                      items: _problemTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _problemType = value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione o tipo de problema';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Descrição',
                      hint:
                          'Conte o que aconteceu, quando ocorreu e como reproduzir',
                      controller: _descriptionController,
                      maxLines: 6,
                      textInputAction: TextInputAction.newline,
                      validator: (value) {
                        if (value == null || value.trim().length < 12) {
                          return 'Descreva o problema com mais detalhes';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Contexto automático',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ContextInfo(label: 'Versão do app', value: _appVersion),
                    _ContextInfo(label: 'Dispositivo', value: _device),
                    _ContextInfo(label: 'Sistema', value: _system),
                    const SizedBox(height: 12),
                    _AttachmentField(
                      title: 'Upload',
                      subtitle: 'Screenshot ou vídeo',
                      file: _attachment,
                      onPick: _pickAttachment,
                      onRemove: () => setState(() => _attachment = null),
                    ),
                    if (_isSending) ...[
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: _progress,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withAlpha(40),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enviando... ${(_progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Enviar relatório',
                      isLoading: _isSending,
                      onPressed: _submitReport,
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

class _SupportHeader extends StatelessWidget {
  final String title;

  const _SupportHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SupportCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SupportCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FaqTile extends StatelessWidget {
  final _FaqItem item;

  const _FaqTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      childrenPadding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
      iconColor: AppColors.primary,
      collapsedIconColor: AppColors.textSecondary,
      title: Text(
        item.question,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item.answer,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionList extends StatelessWidget {
  final List<_FaqItem> suggestions;
  final ValueChanged<String> onSelect;

  const _SuggestionList({required this.suggestions, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          'Sem sugestões para esse termo.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    return Column(
      children: suggestions
          .take(3)
          .map(
            (item) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.help_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              title: Text(
                item.question,
                style: const TextStyle(fontSize: 13.5),
              ),
              onTap: () => onSelect(item.question),
            ),
          )
          .toList(),
    );
  }
}

class _AttachmentField extends StatelessWidget {
  final String title;
  final String subtitle;
  final PlatformFile? file;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _AttachmentField({
    required this.title,
    required this.subtitle,
    required this.file,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.backgroundWhite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          if (file == null)
            OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.attach_file_rounded),
              label: const Text('Selecionar arquivo'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                side: const BorderSide(color: AppColors.inputBorder),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      file!.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textSecondary,
                    splashRadius: 18,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ContextInfo extends StatelessWidget {
  final String label;
  final String value;

  const _ContextInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
