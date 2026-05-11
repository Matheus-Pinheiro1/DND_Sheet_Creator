part of 'encounter_screen.dart';

class _ParticipantEditSheet extends ConsumerStatefulWidget {
  final EncounterParticipant participant;
  final EncounterNotifier notifier;
  final VoidCallback onRemove;

  const _ParticipantEditSheet({
    required this.participant,
    required this.notifier,
    required this.onRemove,
  });

  @override
  ConsumerState<_ParticipantEditSheet> createState() =>
      _ParticipantEditSheetState();
}

class _ParticipantEditSheetState extends ConsumerState<_ParticipantEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _damageCtrl;
  late final TextEditingController _healCtrl;
  late final TextEditingController _initCtrl;
  late final TextEditingController _hpCtrl;
  late final TextEditingController _maxHpCtrl;
  late final TextEditingController _acCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _legActCtrl;
  late final TextEditingController _legResCtrl;
  late final FocusNode _nameFocusNode;
  late final FocusNode _hpFocusNode;
  late final FocusNode _maxHpFocusNode;

  @override
  void initState() {
    super.initState();
    final p = widget.participant;
    _nameCtrl = TextEditingController(text: p.name);
    _damageCtrl = TextEditingController();
    _healCtrl = TextEditingController();
    _initCtrl = TextEditingController(text: '${p.initiative}');
    _hpCtrl = TextEditingController(text: '${p.currentHp}');
    _maxHpCtrl = TextEditingController(text: '${p.maxHp}');
    _acCtrl = TextEditingController(text: '${p.armorClass}');
    _notesCtrl = TextEditingController(text: p.notes);
    _legActCtrl = TextEditingController(text: '${p.legendaryActionsMax}');
    _legResCtrl = TextEditingController(text: '${p.legendaryResistancesMax}');
    _nameFocusNode = FocusNode();
    _hpFocusNode = FocusNode();
    _maxHpFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _hpFocusNode.dispose();
    _maxHpFocusNode.dispose();
    _nameCtrl.dispose();
    _damageCtrl.dispose();
    _healCtrl.dispose();
    _initCtrl.dispose();
    _hpCtrl.dispose();
    _maxHpCtrl.dispose();
    _acCtrl.dispose();
    _notesCtrl.dispose();
    _legActCtrl.dispose();
    _legResCtrl.dispose();
    super.dispose();
  }

  void _syncController(
    TextEditingController controller,
    FocusNode focusNode,
    String value,
  ) {
    if (focusNode.hasFocus || controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(encounterProvider).participants.firstWhere(
          (x) => x.id == widget.participant.id,
          orElse: () => widget.participant,
        );
    final n = widget.notifier;
    _syncController(_nameCtrl, _nameFocusNode, p.name);
    _syncController(_hpCtrl, _hpFocusNode, '${p.currentHp}');
    _syncController(_maxHpCtrl, _maxHpFocusNode, '${p.maxHp}');

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.charcoal,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: AppTextStyles.cinzel(
                          color: AppTheme.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (p.colorTag != 0) ...[
                    _ColorMarker(color: Color(p.colorTag)),
                    const SizedBox(width: 6),
                  ],
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    tooltip: 'Remove from Encounter',
                    onPressed: widget.onRemove,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white12),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _SheetSection(
                    title: 'Identity',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nameCtrl,
                          focusNode: _nameFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Encounter Name',
                            isDense: true,
                          ),
                          onSubmitted: (value) =>
                              n.setParticipantName(p.id, value),
                          onChanged: (value) =>
                              n.setParticipantName(p.id, value),
                        ),
                        if (p.visibleOriginalName.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Original: ${p.visibleOriginalName}',
                            style: AppTextStyles.lato(
                              color: Colors.white38,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        _ColorTagPicker(
                          selectedColor: p.colorTag,
                          onSelected: (colorTag) =>
                              n.setColorTag(p.id, colorTag),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SheetSection(
                    title: 'Hit Points',
                    child: Column(
                      children: [
                        _HpBar(participant: p),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _NumberField(
                                controller: _damageCtrl,
                                label: 'Damage',
                                prefixIcon: Icons.remove_circle_outline,
                                iconColor: AppTheme.crimson,
                                onConfirm: () {
                                  final v = int.tryParse(_damageCtrl.text) ?? 0;
                                  n.applyDamage(p.id, v);
                                  _damageCtrl.clear();
                                },
                                confirmColor: AppTheme.crimson,
                                confirmLabel: 'Hit',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _NumberField(
                                controller: _healCtrl,
                                label: 'Healing',
                                prefixIcon: Icons.add_circle_outline,
                                iconColor: const Color(0xFF4CAF50),
                                onConfirm: () {
                                  final v = int.tryParse(_healCtrl.text) ?? 0;
                                  n.applyHealing(p.id, v);
                                  _healCtrl.clear();
                                },
                                confirmColor: const Color(0xFF4CAF50),
                                confirmLabel: 'Heal',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _hpCtrl,
                                focusNode: _hpFocusNode,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Current HP',
                                  isDense: true,
                                ),
                                onSubmitted: (v) {
                                  final val = int.tryParse(v);
                                  if (val != null) n.setHp(p.id, val);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _maxHpCtrl,
                                focusNode: _maxHpFocusNode,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Max HP',
                                  isDense: true,
                                ),
                                onSubmitted: (v) {
                                  final val = int.tryParse(v);
                                  if (val != null) n.setMaxHp(p.id, val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SheetSection(
                    title: 'Initiative & Armor',
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _initCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^-?\d*'))
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Initiative',
                              isDense: true,
                            ),
                            onSubmitted: (v) {
                              final val = int.tryParse(v);
                              if (val != null) n.setInitiative(p.id, val);
                            },
                            onChanged: (v) {
                              final val = int.tryParse(v);
                              if (val != null) n.setInitiative(p.id, val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _acCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Armor Class',
                              isDense: true,
                            ),
                            onSubmitted: (v) {
                              final val = int.tryParse(v);
                              if (val != null) n.setAc(p.id, val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SheetSection(
                    title: 'Combat Resources',
                    child: Column(
                      children: [
                        // Concentration + Reaction
                        Row(
                          children: [
                            Expanded(
                              child: _ToggleTile(
                                label: 'Concentrating',
                                icon: Icons.radio_button_on_outlined,
                                active: p.concentrating,
                                activeColor: const Color(0xFF7B68EE),
                                onToggle: () => n.toggleConcentration(p.id),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ToggleTile(
                                label: 'Reaction Used',
                                icon: Icons.flash_on_outlined,
                                active: p.reactionUsed,
                                activeColor: const Color(0xFFFF9800),
                                onToggle: () => p.reactionUsed
                                    ? n.resetReaction(p.id)
                                    : n.useReaction(p.id),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (p.legendaryActionsMax > 0 ||
                            (int.tryParse(_legActCtrl.text) ?? 0) > 0) ...[
                          _LegendaryCounter(
                            label: 'Legendary Actions',
                            used: p.legendaryActionsUsed,
                            max: p.legendaryActionsMax,
                            onUse: () => n.useLegendaryAction(p.id),
                            onReset: () => n.resetLegendaryActions(p.id),
                          ),
                          const SizedBox(height: 8),
                        ],

                        if (p.legendaryResistancesMax > 0 ||
                            (int.tryParse(_legResCtrl.text) ?? 0) > 0) ...[
                          _LegendaryCounter(
                            label: 'Legendary Resistances',
                            used: p.legendaryResistancesUsed,
                            max: p.legendaryResistancesMax,
                            onUse: () => n.useLegendaryResistance(p.id),
                            onReset: () => n.resetLegendaryResistances(p.id),
                          ),
                          const SizedBox(height: 8),
                        ],

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _legActCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Legendary Actions (max)',
                                  isDense: true,
                                ),
                                onSubmitted: (v) {
                                  final val = int.tryParse(v) ?? 0;
                                  n.setLegendaryActionsMax(p.id, val);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _legResCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Legendary Resist. (max)',
                                  isDense: true,
                                ),
                                onSubmitted: (v) {
                                  final val = int.tryParse(v) ?? 0;
                                  n.setLegendaryResistancesMax(p.id, val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!p.isPlayer && p.monsterIndex.isNotEmpty) ...[
                    _MonsterCombatReference(participant: p),
                    const SizedBox(height: 16),
                  ],
                  _SheetSection(
                    title: 'Conditions',
                    trailing: p.conditions.isNotEmpty
                        ? TextButton(
                            onPressed: () => n.clearConditions(p.id),
                            child: Text('Clear all',
                                style: AppTextStyles.lato(
                                    color: Colors.white38, fontSize: 12)),
                          )
                        : null,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kDndConditions.map((cond) {
                        final active = p.conditions.contains(cond);
                        return GestureDetector(
                          onTap: () => n.toggleCondition(p.id, cond),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppTheme.crimson.withValues(alpha: 0.85)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    active ? AppTheme.crimson : Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              cond,
                              style: AppTextStyles.lato(
                                color: active ? Colors.white : Colors.white54,
                                fontSize: 12,
                                fontWeight: active
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SheetSection(
                    title: 'Notes',
                    child: TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tactics, reminders, status effects...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => n.setNotes(p.id, v),
                    ),
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
