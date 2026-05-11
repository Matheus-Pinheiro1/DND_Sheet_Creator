import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/character_model.dart';
import '../../../../data/services/equipment_entry_service.dart';
import '../../../../data/services/equipment_mechanics_service.dart';
import '../../../../providers/character_providers.dart';

class TabEquipment extends ConsumerStatefulWidget {
  final CharacterModel character;
  const TabEquipment({super.key, required this.character});
  @override
  ConsumerState<TabEquipment> createState() => _TabEquipmentState();
}

class _TabEquipmentState extends ConsumerState<TabEquipment> {
  final _quickNameCtrl = TextEditingController();

  Future<void> _addItem() async {
    final quickName = _quickNameCtrl.text.trim();
    final result = await showModalBottomSheet<EquipmentEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.ashGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ItemEditorSheet(initialName: quickName),
    );
    if (result == null || result.name.trim().isEmpty) return;

    final updated = _withUpdatedEquipment(
      [...widget.character.equipment, EquipmentEntryService.encode(result)],
    );
    if (!mounted) return;
    await ref.read(charactersProvider.notifier).updateCharacter(updated);
    _quickNameCtrl.clear();
  }

  Future<void> _editItem(int index) async {
    final parsed = _parseItem(widget.character.equipment[index]);
    final result = await showModalBottomSheet<EquipmentEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.ashGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ItemEditorSheet(
        initialName: parsed.name,
        initialDescription: parsed.description,
        initialEquipped: parsed.equipped,
      ),
    );
    if (result == null || result.name.trim().isEmpty) return;

    final list = List<String>.from(widget.character.equipment);
    list[index] = EquipmentEntryService.encode(result);
    if (!mounted) return;
    await ref.read(charactersProvider.notifier).updateCharacter(
          _withUpdatedEquipment(list),
        );
  }

  Future<void> _removeItem(int index) async {
    final list = List<String>.from(widget.character.equipment)..removeAt(index);
    await ref.read(charactersProvider.notifier).updateCharacter(
          _withUpdatedEquipment(list),
        );
  }

  Future<void> _toggleEquipped(int index) async {
    final list = List<String>.from(widget.character.equipment);
    final parsed = _parseItem(list[index]);
    list[index] = EquipmentEntryService.encode(
      parsed.copyWith(equipped: !parsed.equipped),
    );
    await ref.read(charactersProvider.notifier).updateCharacter(
          _withUpdatedEquipment(list),
        );
  }

  CharacterModel _withUpdatedEquipment(List<String> equipment) {
    final updated = widget.character.copyWith(equipment: equipment);
    final currentAttacks =
        EquipmentMechanicsService.removeMissingEquipmentWeaponAttacks(
      existingAttacks: updated.attacks,
      previousEquipment: widget.character.equipment,
      nextEquipment: equipment,
    );
    final syncedAttacks = EquipmentMechanicsService.mergeEquipmentAttacks(
      existingAttacks: currentAttacks,
      equipmentAttacks: EquipmentMechanicsService.weaponAttacksFromEquipment(
        equipment: equipment,
        character: updated,
      ),
    );
    final shouldRecalculateAc = EquipmentMechanicsService.armorClassSourceKey(
          widget.character.equipment,
        ) !=
        EquipmentMechanicsService.armorClassSourceKey(equipment);

    if (!shouldRecalculateAc) {
      return updated.copyWith(attacks: syncedAttacks);
    }

    final armorClass = EquipmentMechanicsService.calculateArmorClass(
      className: updated.className,
      subclass: updated.subclass,
      level: updated.level,
      dexterity: updated.dexterity,
      constitution: updated.constitution,
      wisdom: updated.wisdom,
      charisma: updated.charisma,
      equipment: equipment,
    );

    return updated.copyWith(armorClass: armorClass, attacks: syncedAttacks);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.character.equipment.map(_parseItem).toList();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _quickNameCtrl,
              decoration: const InputDecoration(
                hintText: 'Add item name...',
                prefixIcon: Icon(Icons.add_shopping_cart),
              ),
              onSubmitted: (_) => _addItem(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _addItem, child: const Text('Add')),
        ]),
      ),
      Expanded(
        child: items.isEmpty
            ? Center(
                child: Text('No items yet',
                    style: AppTextStyles.cinzel(color: Colors.white38)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (ctx, i) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: AppTheme.ashGray,
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2_outlined,
                        color: AppTheme.gold),
                    title: Text(items[i].name,
                        style: AppTextStyles.lato(color: Colors.white)),
                    subtitle: _ItemSubtitle(item: items[i]),
                    onTap: () => _editItem(i),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: items[i].equipped ? 'Unequip' : 'Equip',
                          icon: Icon(
                            items[i].equipped
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: items[i].equipped
                                ? AppTheme.gold
                                : Colors.white38,
                          ),
                          onPressed: () => _toggleEquipped(i),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _removeItem(i),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    ]);
  }

  EquipmentEntry _parseItem(String raw) => EquipmentEntryService.parse(raw);

  @override
  void dispose() {
    _quickNameCtrl.dispose();
    super.dispose();
  }
}

class _ItemSubtitle extends StatelessWidget {
  final EquipmentEntry item;

  const _ItemSubtitle({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.description.isEmpty && item.equipped) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.description.isNotEmpty)
            Text(
              item.description,
              style: AppTextStyles.lato(
                color: Colors.white54,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          if (!item.equipped)
            Text(
              'Not equipped',
              style: AppTextStyles.lato(
                color: Colors.white38,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}

class _ItemEditorSheet extends StatefulWidget {
  final String initialName;
  final String initialDescription;
  final bool initialEquipped;

  const _ItemEditorSheet({
    this.initialName = '',
    this.initialDescription = '',
    this.initialEquipped = true,
  });

  @override
  State<_ItemEditorSheet> createState() => _ItemEditorSheetState();
}

class _ItemEditorSheetState extends State<_ItemEditorSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late bool _equipped;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _descCtrl = TextEditingController(text: widget.initialDescription);
    _equipped = widget.initialEquipped;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Item Details',
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: 'Item name',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Item description',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _equipped,
              onChanged: (value) {
                setState(() => _equipped = value ?? true);
              },
              title: Text(
                'Equipped',
                style: AppTextStyles.lato(color: Colors.white70),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(
                    EquipmentEntry(
                      name: _nameCtrl.text.trim(),
                      description: _descCtrl.text.trim(),
                      equipped: _equipped,
                    ),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Save Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
