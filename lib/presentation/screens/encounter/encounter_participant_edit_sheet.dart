part of 'encounter_screen.dart';

class _ParticipantEditSheet extends ConsumerStatefulWidget {
  final EncounterParticipant participant;
  final EncounterNotifier notifier;
  final ValueChanged<String> onOpenMonster;
  final VoidCallback onRemove;

  const _ParticipantEditSheet({
    required this.participant,
    required this.notifier,
    required this.onOpenMonster,
    required this.onRemove,
  });

  @override
  ConsumerState<_ParticipantEditSheet> createState() =>
      _ParticipantEditSheetState();
}

class _ParticipantEditSheetState extends ConsumerState<_ParticipantEditSheet> {
  late NavigatorState _sheetNavigator;
  bool _participantRemoved = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _damageCtrl;
  late final TextEditingController _healCtrl;
  late final TextEditingController _initCtrl;
  late final TextEditingController _hpCtrl;
  late final TextEditingController _maxHpCtrl;
  late final TextEditingController _tempHpCtrl;
  late final TextEditingController _acCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _legActCtrl;
  late final TextEditingController _legResCtrl;
  late final FocusNode _nameFocusNode;
  late final FocusNode _hpFocusNode;
  late final FocusNode _maxHpFocusNode;
  late final FocusNode _tempHpFocusNode;

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
    _tempHpCtrl = TextEditingController(text: '${p.temporaryHp}');
    _acCtrl = TextEditingController(text: '${p.armorClass}');
    _notesCtrl = TextEditingController(text: p.notes);
    _legActCtrl = TextEditingController(text: '${p.legendaryActionsMax}');
    _legResCtrl = TextEditingController(text: '${p.legendaryResistancesMax}');
    _nameFocusNode = FocusNode();
    _hpFocusNode = FocusNode();
    _maxHpFocusNode = FocusNode();
    _tempHpFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sheetNavigator = Navigator.of(context);
  }

  @override
  void dispose() {
    if (!_participantRemoved) {
      _saveAllFields();
    }
    _nameFocusNode.dispose();
    _hpFocusNode.dispose();
    _maxHpFocusNode.dispose();
    _tempHpFocusNode.dispose();
    _nameCtrl.dispose();
    _damageCtrl.dispose();
    _healCtrl.dispose();
    _initCtrl.dispose();
    _hpCtrl.dispose();
    _maxHpCtrl.dispose();
    _tempHpCtrl.dispose();
    _acCtrl.dispose();
    _notesCtrl.dispose();
    _legActCtrl.dispose();
    _legResCtrl.dispose();
    super.dispose();
  }

  void _saveName() {
    widget.notifier.setParticipantName(widget.participant.id, _nameCtrl.text);
  }

  void _saveHp() {
    final value = int.tryParse(_hpCtrl.text);
    if (value != null) widget.notifier.setHp(widget.participant.id, value);
  }

  void _saveMaxHp() {
    final value = int.tryParse(_maxHpCtrl.text);
    if (value != null) widget.notifier.setMaxHp(widget.participant.id, value);
  }

  void _saveTemporaryHp() {
    final value = int.tryParse(_tempHpCtrl.text);
    if (value != null) {
      widget.notifier.setTemporaryHp(widget.participant.id, value);
    }
  }

  void _saveInitiative() {
    final value = int.tryParse(_initCtrl.text);
    if (value != null) {
      widget.notifier.setInitiative(widget.participant.id, value);
    }
  }

  void _saveAc() {
    final value = int.tryParse(_acCtrl.text);
    if (value != null) widget.notifier.setAc(widget.participant.id, value);
  }

  void _saveLegendaryActions() {
    final text = _legActCtrl.text.trim();
    if (text.isEmpty) return;
    final value = int.tryParse(text) ?? 0;
    widget.notifier.setLegendaryActionsMax(widget.participant.id, value);
  }

  void _saveLegendaryResistances() {
    final text = _legResCtrl.text.trim();
    if (text.isEmpty) return;
    final value = int.tryParse(text) ?? 0;
    widget.notifier.setLegendaryResistancesMax(widget.participant.id, value);
  }

  void _saveNotes() {
    widget.notifier.setNotes(widget.participant.id, _notesCtrl.text);
  }

  void _saveAllFields() {
    _saveName();
    _saveHp();
    _saveMaxHp();
    _saveTemporaryHp();
    _saveInitiative();
    _saveAc();
    _saveLegendaryActions();
    _saveLegendaryResistances();
    _saveNotes();
  }

  void _saveNameAndClose() {
    _saveAllFields();
    _sheetNavigator.maybePop();
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
    final participants = ref.watch(encounterProvider).participants;
    final participantIndex = participants.indexWhere(
      (x) => x.id == widget.participant.id,
    );
    if (participantIndex < 0) {
      _participantRemoved = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sheetNavigator.maybePop();
      });
      return const SizedBox.shrink();
    }

    final p = participants[participantIndex];
    final n = widget.notifier;
    _syncController(_nameCtrl, _nameFocusNode, p.name);
    _syncController(_hpCtrl, _hpFocusNode, '${p.currentHp}');
    _syncController(_maxHpCtrl, _maxHpFocusNode, '${p.maxHp}');
    _syncController(_tempHpCtrl, _tempHpFocusNode, '${p.temporaryHp}');
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom + media.viewPadding.bottom;
    final listBottomPadding = 32.0 + bottomInset;
    final fieldScrollPadding = EdgeInsets.only(bottom: listBottomPadding + 72);

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
                    _ColorMarker(color: encounterColorForTag(p.colorTag)),
                    const SizedBox(width: 6),
                  ],
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    tooltip: 'Close',
                    onPressed: _saveNameAndClose,
                  ),
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
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(20, 16, 20, listBottomPadding),
                children: [
                  _SheetSection(
                    title: 'Identity',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nameCtrl,
                          focusNode: _nameFocusNode,
                          scrollPadding: fieldScrollPadding,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            isDense: true,
                          ),
                          onSubmitted: (value) =>
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
                                scrollPadding: fieldScrollPadding,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  signed: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^-?\d*'))
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Current HP',
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _saveHp(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _maxHpCtrl,
                                focusNode: _maxHpFocusNode,
                                scrollPadding: fieldScrollPadding,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Max HP',
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _saveMaxHp(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _tempHpCtrl,
                          focusNode: _tempHpFocusNode,
                          scrollPadding: fieldScrollPadding,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Temporary HP',
                            isDense: true,
                          ),
                          onSubmitted: (_) => _saveTemporaryHp(),
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
                            scrollPadding: fieldScrollPadding,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^-?\d*'))
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Initiative',
                              isDense: true,
                            ),
                            onSubmitted: (_) => _saveInitiative(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _acCtrl,
                            scrollPadding: fieldScrollPadding,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Armor Class',
                              isDense: true,
                            ),
                            onSubmitted: (_) => _saveAc(),
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
                                scrollPadding: fieldScrollPadding,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Legendary Actions (max)',
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _saveLegendaryActions(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _legResCtrl,
                                scrollPadding: fieldScrollPadding,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Legendary Resist. (max)',
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _saveLegendaryResistances(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!p.isPlayer && p.monsterIndex.isNotEmpty) ...[
                    _MonsterCombatReference(
                      participant: p,
                      onOpenMonster: (monsterIndex) {
                        widget.onOpenMonster(monsterIndex);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  _SheetSection(
                    title: 'Conditions',
                    trailing: p.conditions.isNotEmpty || p.exhaustionLevel > 0
                        ? TextButton(
                            onPressed: () {
                              n.clearConditions(p.id);
                              n.setExhaustionLevel(p.id, 0);
                            },
                            child: Text('Clear all',
                                style: AppTextStyles.lato(
                                    color: Colors.white38, fontSize: 12)),
                          )
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ExhaustionControl(
                          level: p.exhaustionLevel,
                          onDecrease: () => n.decrementExhaustion(p.id),
                          onIncrease: () => n.incrementExhaustion(p.id),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: kDndConditions.map((cond) {
                            final active = p.conditions.contains(cond);
                            return GestureDetector(
                              onTap: () => n.toggleCondition(p.id, cond),
                              child: Tooltip(
                                message: _conditionTooltip(cond),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? AppTheme.crimson
                                            .withValues(alpha: 0.85)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: active
                                          ? AppTheme.crimson
                                          : Colors.white24,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    cond,
                                    style: AppTextStyles.lato(
                                      color: active
                                          ? Colors.white
                                          : Colors.white54,
                                      fontSize: 12,
                                      fontWeight: active
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SheetSection(
                    title: 'Notes',
                    child: TextField(
                      controller: _notesCtrl,
                      scrollPadding: fieldScrollPadding,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tactics, reminders, status effects...',
                        border: OutlineInputBorder(),
                      ),
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
