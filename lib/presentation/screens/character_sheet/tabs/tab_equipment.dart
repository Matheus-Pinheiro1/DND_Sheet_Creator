import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dice_calculator.dart';
import '../../../../data/local/armor_data.dart';
import '../../../../data/local/weapons_data.dart';
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

    final list = [
      ...widget.character.equipment,
      EquipmentEntryService.encode(result)
    ];
    final updated = _withUpdatedEquipment(
      _withSingleActiveArmor(list, activeIndex: list.length - 1),
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
          _withUpdatedEquipment(
              _withSingleActiveArmor(list, activeIndex: index)),
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
    final next = _withSingleActiveArmor(list, activeIndex: index);
    await ref.read(charactersProvider.notifier).updateCharacter(
          _withUpdatedEquipment(next),
        );
  }

  List<String> _withSingleActiveArmor(
    List<String> equipment, {
    required int activeIndex,
  }) {
    if (activeIndex < 0 || activeIndex >= equipment.length) return equipment;
    final activeEntry = equipment[activeIndex];
    final activeItem = EquipmentEntryService.parse(activeEntry);
    if (!activeItem.equipped ||
        !EquipmentMechanicsService.isArmorEntry(activeEntry)) {
      return equipment;
    }

    final next = List<String>.from(equipment);
    for (var i = 0; i < next.length; i++) {
      if (i == activeIndex) continue;
      if (!EquipmentMechanicsService.isArmorEntry(next[i])) continue;
      final item = EquipmentEntryService.parse(next[i]);
      if (!item.equipped) continue;
      next[i] = EquipmentEntryService.encode(item.copyWith(equipped: false));
    }
    return next;
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _EquipmentStatusCard(character: widget.character),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text('No items yet',
                      style: AppTextStyles.cinzel(color: Colors.white38)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final rawEntry = widget.character.equipment[i];
                    final item = items[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: AppTheme.ashGray,
                      child: ListTile(
                        leading: Icon(
                          _itemIcon(rawEntry),
                          color: item.equipped ? AppTheme.gold : Colors.white38,
                        ),
                        title: Text(
                          item.name,
                          style: AppTextStyles.lato(color: Colors.white),
                        ),
                        subtitle: _ItemSubtitle(
                          item: item,
                          rawEntry: rawEntry,
                          character: widget.character,
                        ),
                        onTap: () => _editItem(i),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: item.equipped ? 'Unequip' : 'Equip item',
                              icon: Icon(
                                item.equipped
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: item.equipped
                                    ? AppTheme.gold
                                    : Colors.white38,
                              ),
                              onPressed: () => _toggleEquipped(i),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _removeItem(i),
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
  }

  IconData _itemIcon(String rawEntry) {
    if (EquipmentMechanicsService.isShieldEntry(rawEntry)) {
      return Icons.shield_outlined;
    }
    if (EquipmentMechanicsService.isArmorEntry(rawEntry)) {
      return Icons.health_and_safety_outlined;
    }
    if (EquipmentMechanicsService.weaponFromEquipmentEntry(rawEntry) != null) {
      return Icons.sports_martial_arts_outlined;
    }
    if (_packContentsFor(rawEntry).isNotEmpty) {
      return Icons.backpack_outlined;
    }
    return Icons.inventory_2_outlined;
  }

  EquipmentEntry _parseItem(String raw) => EquipmentEntryService.parse(raw);

  @override
  void dispose() {
    _quickNameCtrl.dispose();
    super.dispose();
  }
}

class _EquipmentStatusCard extends StatelessWidget {
  final CharacterModel character;

  const _EquipmentStatusCard({required this.character});

  @override
  Widget build(BuildContext context) {
    final activeEquipment =
        EquipmentEntryService.equippedEntries(character.equipment);
    final armor = EquipmentMechanicsService.armorFromEquipmentEntries(
      activeEquipment,
    );
    final shieldEquipped = EquipmentMechanicsService.hasShield(activeEquipment);
    final weapons = activeEquipment
        .map(EquipmentMechanicsService.weaponFromEquipmentEntry)
        .nonNulls
        .map((weapon) => weapon.name)
        .toSet()
        .toList();
    final ac = EquipmentMechanicsService.calculateArmorClass(
      className: character.className,
      subclass: character.subclass,
      level: character.level,
      dexterity: character.dexterity,
      constitution: character.constitution,
      wisdom: character.wisdom,
      charisma: character.charisma,
      equipment: character.equipment,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkBrown.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.28)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _EquipmentMetric(
            icon: Icons.shield_outlined,
            label: 'AC',
            value: '$ac',
            highlight: true,
          ),
          _EquipmentMetric(
            icon: Icons.health_and_safety_outlined,
            label: 'Armor',
            value: armor?.name ?? _unarmoredLabel(character),
          ),
          _EquipmentMetric(
            icon: Icons.security_outlined,
            label: 'Shield',
            value: shieldEquipped ? '+2 AC' : 'None',
          ),
          if (weapons.isNotEmpty)
            _EquipmentMetric(
              icon: Icons.sports_martial_arts_outlined,
              label: 'Weapons',
              value: weapons.take(3).join(', '),
            ),
        ],
      ),
    );
  }

  static String _unarmoredLabel(CharacterModel character) {
    if (character.className == 'barbarian') return 'Unarmored Defense';
    if (character.className == 'monk') return 'Unarmored Defense';
    return 'Unarmored';
  }
}

class _EquipmentMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _EquipmentMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: highlight
            ? AppTheme.gold.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight
              ? AppTheme.gold.withValues(alpha: 0.45)
              : Colors.white10,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: highlight ? AppTheme.gold : Colors.white54,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.lato(color: Colors.white38, fontSize: 10),
              ),
              Text(
                value,
                style: AppTextStyles.lato(
                  color: highlight ? AppTheme.gold : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemSubtitle extends StatelessWidget {
  final EquipmentEntry item;
  final String rawEntry;
  final CharacterModel character;

  const _ItemSubtitle({
    required this.item,
    required this.rawEntry,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      ..._statLines(),
      if (item.description.isNotEmpty) item.description,
      if (!item.equipped) 'Not equipped',
    ];

    if (lines.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines
            .map(
              (line) => Text(
                line,
                style: AppTextStyles.lato(
                  color:
                      line == 'Not equipped' ? Colors.white38 : Colors.white54,
                  fontSize: 12,
                  height: 1.35,
                  fontStyle: line == 'Not equipped'
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  List<String> _statLines() {
    final armor = EquipmentMechanicsService.armorFromEquipmentEntry(rawEntry);
    final weapon = EquipmentMechanicsService.weaponFromEquipmentEntry(rawEntry);
    final packContents = _packContentsFor(rawEntry);

    if (armor != null) return [_armorLine(armor)];
    if (weapon != null) return [_weaponLine(weapon)];
    if (packContents.isNotEmpty) {
      return ['Contains: ${packContents.join(', ')}'];
    }

    return const [];
  }

  String _armorLine(DndArmor armor) {
    if (armor.isShield) return '+${armor.acBonus} AC while equipped';
    final dexMod = DiceCalculator.getModifier(character.dexterity);
    final dexText = switch (armor.dexMode) {
      ArmorDexMode.full => ' + DEX',
      ArmorDexMode.maxTwo => ' + DEX max 2',
      ArmorDexMode.none => '',
    };
    final total = armor.baseAc + armor.dexBonus(dexMod);
    return 'Armor AC $total (${armor.baseAc}$dexText)';
  }

  String _weaponLine(DndWeapon weapon) {
    final parts = [
      '${weapon.damageDice} ${weapon.damageType}',
      weapon.range,
      if (weapon.properties.isNotEmpty) weapon.properties,
      if (weapon.mastery.isNotEmpty) 'Mastery: ${weapon.mastery}',
    ];
    return parts.where((part) => part.trim().isNotEmpty).join(' - ');
  }
}

List<String> _packContentsFor(String rawEntry) {
  final item = EquipmentEntryService.parse(rawEntry);
  return _packContents[_normalizeEquipmentName(item.name)] ?? const [];
}

String _normalizeEquipmentName(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'\([^)]*\)'), ' ')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

const Map<String, List<String>> _packContents = {
  'explorer s pack': [
    'Backpack',
    'Bedroll',
    'Mess kit',
    'Tinderbox',
    '10 torches',
    '10 days rations',
    'Waterskin',
    '50 ft rope',
  ],
  'dungeoneer s pack': [
    'Backpack',
    'Crowbar',
    'Hammer',
    '10 pitons',
    '10 torches',
    'Tinderbox',
    '10 days rations',
    'Waterskin',
    '50 ft rope',
  ],
  'burglar s pack': [
    'Backpack',
    '1,000 ball bearings',
    '10 ft string',
    'Bell',
    '5 candles',
    'Crowbar',
    'Hammer',
    '10 pitons',
    'Hooded lantern',
    'Oil',
    '5 days rations',
    'Tinderbox',
    'Waterskin',
    '50 ft rope',
  ],
  'entertainer s pack': [
    'Backpack',
    'Bedroll',
    '2 costumes',
    '5 candles',
    '5 days rations',
    'Waterskin',
    'Disguise kit',
  ],
  'priest s pack': [
    'Backpack',
    'Blanket',
    '10 candles',
    'Tinderbox',
    'Alms box',
    '2 blocks incense',
    'Censer',
    'Vestments',
    '2 days rations',
    'Waterskin',
  ],
  'scholar s pack': [
    'Backpack',
    'Book of lore',
    'Ink',
    'Ink pen',
    '10 parchment sheets',
    'Little bag of sand',
    'Small knife',
  ],
};

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
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom + media.viewPadding.bottom;

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: bottomInset + 20,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
      ),
    );
  }
}
