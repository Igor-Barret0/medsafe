import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/edit_name_dialog.dart';
import '../../../user/presentation/pages/history_page.dart';
import '../../../user/presentation/widgets/profile_edit_widgets.dart';
import 'elderly_details_page.dart';
import '../state/caregiver_elderly_store.dart';

// ── Manage list page ──────────────────────────────────────────────────────────

class ManageElderliesPage extends StatefulWidget {
  const ManageElderliesPage({super.key});

  @override
  State<ManageElderliesPage> createState() => _ManageElderliesPageState();
}

enum _ElderliesFilter { ativos, encerrados }

class _ManageElderliesPageState extends State<ManageElderliesPage> {
  _ElderliesFilter _filter = _ElderliesFilter.ativos;

  @override
  Widget build(BuildContext context) {
    final store = CaregiverElderlyStore.instance;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          ProfileEditHeader(
            title: 'Gerenciar idosos',
            subtitle: 'Acompanhamentos ativos e encerrados',
            icon: Icons.manage_accounts_rounded,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: _FilterTabs(
              selected: _filter,
              onChanged: (v) => setState(() => _filter = v),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<CaregiverElderly>>(
              valueListenable: store.elderlies,
              builder: (context, elderlies, _) {
                final filtered = elderlies
                    .where(
                      (e) => _filter == _ElderliesFilter.ativos
                          ? e.status == CaregiverElderlyStatus.active
                          : e.status == CaregiverElderlyStatus.inactive,
                    )
                    .toList();

                if (filtered.isEmpty) {
                  return _EmptyList(
                    isActive: _filter == _ElderliesFilter.ativos,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _ElderlyListCard(
                      item: item,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ElderlyManagementDetailPage(elderlyId: item.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail page ───────────────────────────────────────────────────────────────

class ElderlyManagementDetailPage extends StatefulWidget {
  final String elderlyId;

  const ElderlyManagementDetailPage({super.key, required this.elderlyId});

  @override
  State<ElderlyManagementDetailPage> createState() =>
      _ElderlyManagementDetailPageState();
}

class _ElderlyManagementDetailPageState
    extends State<ElderlyManagementDetailPage> {
  CaregiverElderly? get _elderly =>
      CaregiverElderlyStore.instance.byId(widget.elderlyId);

  @override
  Widget build(BuildContext context) {
    final item = _elderly;

    if (item == null) {
      return const Scaffold(body: Center(child: Text('Idoso não encontrado.')));
    }

    final isActive = item.status == CaregiverElderlyStatus.active;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          ProfileEditHeader(
            title: 'Detalhes do idoso',
            subtitle: 'Gerenciar acompanhamento',
            icon: Icons.manage_accounts_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // ── Profile card ───────────────────────────────────────
                _ProfileCard(item: item, isActive: isActive),
                const SizedBox(height: 16),

                // ── Actions ────────────────────────────────────────────
                _SectionLabel(label: 'Ações'),
                const SizedBox(height: 10),
                _ActionsCard(
                  children: [
                    _ActionRow(
                      icon: Icons.badge_outlined,
                      iconColor: AppColors.primary,
                      title: 'Editar nome',
                      subtitle: 'Alterar o nome do idoso',
                      onTap: () => _openNameEditDialog(item),
                    ),
                    _ActionRow(
                      icon: Icons.edit_outlined,
                      iconColor: const Color(0xFF7C3AED),
                      title: 'Editar dados',
                      subtitle: 'Atualizar idade ou contato',
                      onTap: () => _openEditDialog(item),
                    ),
                    _ActionRow(
                      icon: Icons.medication_outlined,
                      iconColor: const Color(0xFF0EA5E9),
                      title: 'Ver medicamentos',
                      subtitle: 'Abrir detalhes dos medicamentos',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ElderlyDetailsPage(
                            elderlyName: item.name,
                            age: item.age,
                            medicationCount: item.medicationCount,
                            relationship: 'Responsável',
                            medications: const [
                              ElderlyMedicationItem(
                                name: 'Losartana',
                                dosage: '50mg — 1 comprimido',
                                time: '08:00',
                                status: DoseStatus.taken,
                              ),
                              ElderlyMedicationItem(
                                name: 'Metformina',
                                dosage: '500mg — 1 comprimido',
                                time: '12:00',
                                status: DoseStatus.pending,
                              ),
                            ],
                            recentHistory: const [
                              RecentHistoryItem(
                                message: 'Losartana tomada às 08:02',
                                success: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _ActionRow(
                      icon: Icons.history_rounded,
                      iconColor: AppColors.success,
                      title: 'Ver histórico',
                      subtitle: 'Consultar registros do idoso',
                      isLast: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HistoryPage(
                            title: 'Histórico de ${item.name}',
                            subtitle: 'Registros de medicação deste idoso',
                            showBottomNavigation: false,
                            showBackButton: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Danger zone ────────────────────────────────────────
                _EndButton(
                  onTap: () async {
                    final navigator = Navigator.of(context);
                    final removed = await navigator.push<bool>(
                      MaterialPageRoute(
                        builder: (_) => RemoveElderlyPage(elderlyId: item.id),
                      ),
                    );
                    if (!mounted) return;
                    if (removed == true) navigator.pop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openNameEditDialog(CaregiverElderly item) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => EditNameDialog(initialName: item.name),
    );
    if (!mounted || newName == null || newName.isEmpty) return;
    CaregiverElderlyStore.instance.update(item.copyWith(name: newName));
    setState(() {});
  }

  Future<void> _openEditDialog(CaregiverElderly item) async {
    final updated = await showModalBottomSheet<CaregiverElderly>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditElderlySheet(item: item),
    );
    if (!mounted || updated == null) return;
    CaregiverElderlyStore.instance.update(updated);
    setState(() {});
  }
}

// ── Remove pages ──────────────────────────────────────────────────────────────

class ChooseElderlyForRemovalPage extends StatelessWidget {
  const ChooseElderlyForRemovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = CaregiverElderlyStore.instance;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          ProfileEditHeader(
            title: 'Remover idoso',
            subtitle: 'Escolha o acompanhamento a encerrar',
            icon: Icons.person_remove_rounded,
          ),
          Expanded(
            child: ValueListenableBuilder<List<CaregiverElderly>>(
              valueListenable: store.elderlies,
              builder: (context, elderlies, _) {
                final active = elderlies
                    .where((e) => e.status == CaregiverElderlyStatus.active)
                    .toList();

                if (active.isEmpty) {
                  return const _EmptyList(isActive: true);
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  itemCount: active.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = active[index];
                    return _RemovableElderlyCard(
                      item: item,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RemoveElderlyPage(elderlyId: item.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RemoveElderlyPage extends StatefulWidget {
  final String elderlyId;

  const RemoveElderlyPage({super.key, required this.elderlyId});

  @override
  State<RemoveElderlyPage> createState() => _RemoveElderlyPageState();
}

class _RemoveElderlyPageState extends State<RemoveElderlyPage> {
  final _confirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _confirmCtrl.addListener(_onConfirmChanged);
  }

  @override
  void dispose() {
    _confirmCtrl.removeListener(_onConfirmChanged);
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _onConfirmChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final item = CaregiverElderlyStore.instance.byId(widget.elderlyId);

    if (item == null) {
      return const Scaffold(body: Center(child: Text('Idoso não encontrado.')));
    }

    final canRemove = _confirmCtrl.text.trim().toUpperCase() == 'REMOVER';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          ProfileEditHeader(
            title: 'Encerrar acompanhamento',
            subtitle: 'Esta ação não pode ser desfeita',
            icon: Icons.warning_amber_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // Warning card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withAlpha(50)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'Você está prestes a encerrar o acompanhamento. Os dados do idoso poderão ser perdidos.',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Person info card
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(14),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _initials(item.name),
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 17,
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
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${item.age} anos · ${item.contact}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Confirmation field
                ProfileInfoCard(
                  icon: Icons.keyboard_rounded,
                  text: 'Digite "REMOVER" no campo abaixo para confirmar.',
                  color: AppColors.warning,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _confirmCtrl,
                  label: 'Confirmação',
                  hint: 'Digite REMOVER',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                ),
                const SizedBox(height: 20),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: GestureDetector(
                    onTap: canRemove
                        ? () {
                            CaregiverElderlyStore.instance.softDelete(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Acompanhamento encerrado.'),
                                  ],
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                            Navigator.of(context).pop(true);
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: canRemove
                            ? const LinearGradient(
                                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                              )
                            : null,
                        color: canRemove ? null : AppColors.inputBorder,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: canRemove
                            ? [
                                BoxShadow(
                                  color: AppColors.error.withAlpha(60),
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
                            Icons.delete_outline_rounded,
                            color: canRemove
                                ? Colors.white
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Remover idoso',
                            style: TextStyle(
                              color: canRemove
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ProfileCancelButton(
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ── Edit bottom sheet ─────────────────────────────────────────────────────────

class _EditElderlySheet extends StatefulWidget {
  final CaregiverElderly item;

  const _EditElderlySheet({required this.item});

  @override
  State<_EditElderlySheet> createState() => _EditElderlySheetState();
}

class _EditElderlySheetState extends State<_EditElderlySheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _contactCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _ageCtrl = TextEditingController(text: widget.item.age.toString());
    _contactCtrl = TextEditingController(text: widget.item.contact);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Editar dados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Atualize as informações do idoso.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _nameCtrl,
            label: 'Nome completo',
            hint: 'Nome do idoso',
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _ageCtrl,
            label: 'Idade',
            hint: 'Ex: 72',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.cake_outlined),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _contactCtrl,
            label: 'Contato',
            hint: 'Telefone ou e-mail',
            prefixIcon: const Icon(Icons.phone_iphone_outlined),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.inputBorder,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        final age =
                            int.tryParse(_ageCtrl.text.trim()) ??
                            widget.item.age;
                        Navigator.of(context).pop(
                          widget.item.copyWith(
                            name: _nameCtrl.text.trim().isEmpty
                                ? widget.item.name
                                : _nameCtrl.text.trim(),
                            age: age,
                            contact: _contactCtrl.text.trim().isEmpty
                                ? widget.item.contact
                                : _contactCtrl.text.trim(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Salvar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final CaregiverElderly item;
  final bool isActive;

  const _ProfileCard({required this.item, required this.isActive});

  String get _initials {
    final parts = item.name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = isActive ? AppColors.success : AppColors.error;
    final statusLabel = isActive ? 'Ativo' : 'Encerrado';

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
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(50),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
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
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          // Info chips row
          Row(
            children: [
              _InfoChip(
                icon: Icons.cake_outlined,
                value: '${item.age} anos',
                color: const Color(0xFF7C3AED),
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.medication_outlined,
                value: '${item.medicationCount} meds',
                color: const Color(0xFF0EA5E9),
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.people_outline_rounded,
                value: item.caregiverName.split(' ').first,
                color: AppColors.success,
              ),
            ],
          ),
          if (item.contact.isNotEmpty) ...[
            const SizedBox(height: 10),
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
                    Icons.phone_iphone_outlined,
                    color: AppColors.primary,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  item.contact,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _ActionsCard extends StatelessWidget {
  final List<Widget> children;

  const _ActionsCard({required this.children});

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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(20),
            bottom: isLast ? const Radius.circular(20) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 68, endIndent: 16),
      ],
    );
  }
}

class _EndButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EndButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withAlpha(60), width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.remove_circle_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Encerrar acompanhamento',
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

class _FilterTabs extends StatelessWidget {
  final _ElderliesFilter selected;
  final ValueChanged<_ElderliesFilter> onChanged;

  const _FilterTabs({required this.selected, required this.onChanged});

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
          _FilterOption(
            text: 'Ativos',
            icon: Icons.check_circle_outline_rounded,
            selected: selected == _ElderliesFilter.ativos,
            onTap: () => onChanged(_ElderliesFilter.ativos),
          ),
          _FilterOption(
            text: 'Encerrados',
            icon: Icons.cancel_outlined,
            selected: selected == _ElderliesFilter.encerrados,
            onTap: () => onChanged(_ElderliesFilter.encerrados),
          ),
        ],
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterOption({
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ElderlyListCard extends StatelessWidget {
  final CaregiverElderly item;
  final VoidCallback onTap;

  const _ElderlyListCard({required this.item, required this.onTap});

  String get _initials {
    final parts = item.name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = item.status == CaregiverElderlyStatus.active;
    final statusColor = isActive ? AppColors.success : AppColors.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]
                      : [AppColors.textSecondary, const Color(0xFF374151)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${isActive ? 'Ativo' : 'Encerrado'} · ${item.medicationCount} medicamentos',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Última atividade: ${item.lastActivity}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemovableElderlyCard extends StatelessWidget {
  final CaregiverElderly item;
  final VoidCallback onTap;

  const _RemovableElderlyCard({required this.item, required this.onTap});

  String get _initials {
    final parts = item.name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(14),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 16,
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
                    item.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.age} anos · ${item.contact}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  final bool isActive;

  const _EmptyList({required this.isActive});

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
                color: AppColors.primary.withAlpha(12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups_outlined,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isActive
                  ? 'Nenhum idoso ativo'
                  : 'Nenhum acompanhamento encerrado',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              isActive
                  ? 'Adicione idosos pelo menu de configurações.'
                  : 'Os acompanhamentos encerrados aparecerão aqui.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
