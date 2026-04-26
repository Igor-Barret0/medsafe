import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../../../../../core/widgets/edit_name_dialog.dart';
import '../../../user/presentation/pages/history_page.dart';
import 'elderly_details_page.dart';
import '../state/caregiver_elderly_store.dart';

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
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            const _SimpleHeader(title: 'Gerenciar idosos'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: _FilterTabs(
                selected: _filter,
                onChanged: (value) => setState(() => _filter = value),
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
                    return const Center(
                      child: Text(
                        'Nenhum idoso encontrado nesse filtro.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _ElderlyListCard(
                        item: item,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ElderlyManagementDetailPage(
                                elderlyId: item.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
          children: [
            const _SimpleHeader(title: 'Detalhes do idoso'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoLine(label: 'Idade', value: '${item.age} anos'),
                  _InfoLine(label: 'Contato', value: item.contact),
                  _InfoLine(
                    label: 'Medicamentos cadastrados',
                    value: '${item.medicationCount}',
                  ),
                  _InfoLine(
                    label: 'Cuidador vinculado',
                    value: item.caregiverName,
                  ),
                  _InfoLine(
                    label: 'Status',
                    value: item.status == CaregiverElderlyStatus.active
                        ? 'Ativo'
                        : 'Inativo',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _ActionTile(
              icon: Icons.badge_outlined,
              title: 'Editar nome',
              subtitle: 'Alterar o nome do idoso',
              onTap: () => _openNameEditDialog(item),
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.edit_outlined,
              title: 'Editar dados',
              subtitle: 'Atualizar idade ou contato',
              onTap: () => _openEditDialog(item),
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.medication_outlined,
              title: 'Ver medicamentos',
              subtitle: 'Abrir detalhes dos medicamentos',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ElderlyDetailsPage(
                      elderlyName: item.name,
                      age: item.age,
                      medicationCount: item.medicationCount,
                      relationship: 'Responsável',
                      medications: [
                        const ElderlyMedicationItem(
                          name: 'Losartana',
                          dosage: '50mg — 1 comprimido',
                          time: '08:00',
                          status: DoseStatus.taken,
                        ),
                        const ElderlyMedicationItem(
                          name: 'Metformina',
                          dosage: '500mg — 1 comprimido',
                          time: '12:00',
                          status: DoseStatus.pending,
                        ),
                      ],
                      recentHistory: [
                        const RecentHistoryItem(
                          message: 'Losartana tomada às 08:02',
                          success: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.history_rounded,
              title: 'Ver histórico',
              subtitle: 'Consultar registros do idoso',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HistoryPage(
                      title: 'Histórico de ${item.name}',
                      subtitle: 'Registros de medicação deste idoso',
                      showBottomNavigation: false,
                      showBackButton: true,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final removed = await navigator.push<bool>(
                  MaterialPageRoute(
                    builder: (_) => RemoveElderlyPage(elderlyId: item.id),
                  ),
                );

                if (!mounted) return;
                if (removed == true) {
                  navigator.pop();
                }
              },
              icon: const Icon(Icons.remove_circle_outline_rounded),
              label: const Text('Encerrar acompanhamento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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

class RemoveElderlyPage extends StatefulWidget {
  final String elderlyId;

  const RemoveElderlyPage({super.key, required this.elderlyId});

  @override
  State<RemoveElderlyPage> createState() => _RemoveElderlyPageState();
}

class ChooseElderlyForRemovalPage extends StatelessWidget {
  const ChooseElderlyForRemovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = CaregiverElderlyStore.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: ValueListenableBuilder<List<CaregiverElderly>>(
          valueListenable: store.elderlies,
          builder: (context, elderlies, _) {
            final active = elderlies
                .where((e) => e.status == CaregiverElderlyStatus.active)
                .toList();

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: _SimpleHeader(title: 'Remover idoso'),
                ),
                if (active.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Não há idosos ativos para encerrar.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: active.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = active[index];
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    RemoveElderlyPage(elderlyId: item.id),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundWhite,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withAlpha(16),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline_rounded,
                                    color: AppColors.error,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${item.age} anos • ${item.contact}',
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
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RemoveElderlyPageState extends State<RemoveElderlyPage> {
  final TextEditingController _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = CaregiverElderlyStore.instance.byId(widget.elderlyId);

    if (item == null) {
      return const Scaffold(body: Center(child: Text('Idoso não encontrado.')));
    }

    final canRemove = _confirmCtrl.text.trim().toUpperCase() == 'REMOVER';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
          children: [
            const _SimpleHeader(title: 'Remover idoso'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Você está prestes a encerrar o acompanhamento deste idoso. Os dados poderão ser perdidos.',
                style: TextStyle(color: AppColors.textPrimary, height: 1.45),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.age} anos • ${item.contact}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _confirmCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Digite “REMOVER” para confirmar',
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canRemove
                        ? () {
                            CaregiverElderlyStore.instance.softDelete(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Acompanhamento encerrado.'),
                              ),
                            );
                            Navigator.of(context).pop(true);
                          }
                        : null,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Remover idoso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
        color: Color(0xFFF0F4FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
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
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _ageCtrl,
            label: 'Idade',
            hint: 'Ex: 72',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _contactCtrl,
            label: 'Contato',
            hint: 'Telefone ou e-mail',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final age =
                        int.tryParse(_ageCtrl.text.trim()) ?? widget.item.age;
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
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(color: AppColors.textWhite),
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

class _SimpleHeader extends StatelessWidget {
  final String title;

  const _SimpleHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            width: 38,
            height: 38,
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
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
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
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _FilterOption(
            text: 'Ativos',
            selected: selected == _ElderliesFilter.ativos,
            onTap: () => onChanged(_ElderliesFilter.ativos),
          ),
          _FilterOption(
            text: 'Encerrados',
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
  final bool selected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? AppColors.textWhite : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
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

  @override
  Widget build(BuildContext context) {
    final isActive = item.status == CaregiverElderlyStatus.active;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
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
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${isActive ? 'Ativo' : 'Encerrado'} • ${item.medicationCount} medicamentos',
                    style: TextStyle(
                      color: isActive ? AppColors.success : AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 6,
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}
