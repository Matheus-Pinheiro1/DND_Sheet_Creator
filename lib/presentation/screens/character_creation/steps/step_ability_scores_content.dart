part of 'step_ability_scores.dart';

extension _StepAbilityScoreContent on _StepAbilityScoresState {
  String get _modeDescription {
    switch (_mode) {
      case _AbilityMode.standardArray:
        return 'Assign the values [15, 14, 13, 12, 10, 8] to your six ability scores. Each value can only be used once.';
      case _AbilityMode.pointBuy:
        return 'Spend 27 points to buy ability scores. All scores start at 8. Higher scores cost more points.';
      case _AbilityMode.custom:
        return 'Enter any values you like. Use this for rolled stats or Homebrew rules.';
    }
  }

  Widget _buildBackgroundBonusSection(CreationState creation) {
    final options = creation.backgroundAbilityOptions;
    final choices = creation.backgroundBonusChoices;
    final isHomebrewBackground = creation.background.startsWith('custom_');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Background Ability Bonuses',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isHomebrewBackground
                ? 'Choose the background bonuses for this homebrew background. These bonuses are applied to the final sheet automatically when the character is saved.'
                : 'Official 2024 backgrounds use +2 to one listed ability and +1 to another listed ability. These bonuses are applied to the final sheet automatically when the character is saved.',
            style: AppTextStyles.lato(
              color: Colors.white60,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('+2 and +1'),
                selected: !isHomebrewBackground ||
                    creation.backgroundBonusMode == 'plus2plus1',
                selectedColor: AppTheme.crimson,
                onSelected: (_) => ref
                    .read(creationProvider.notifier)
                    .setBackgroundBonusMode('plus2plus1'),
              ),
              if (isHomebrewBackground)
                ChoiceChip(
                  label: const Text('+1 / +1 / +1'),
                  selected: isHomebrewBackground &&
                      creation.backgroundBonusMode == 'plus1all',
                  selectedColor: AppTheme.crimson,
                  onSelected: (_) => ref
                      .read(creationProvider.notifier)
                      .setBackgroundBonusMode('plus1all'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isHomebrewBackground &&
              creation.backgroundBonusMode == 'plus1all') ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((ability) {
                final selected = choices.contains(ability);
                final disabled = !selected && choices.length >= 3;
                return FilterChip(
                  label: Text(ability.toUpperCase()),
                  selected: selected,
                  selectedColor: AppTheme.crimson,
                  onSelected: disabled
                      ? null
                      : (value) {
                          final updated = List<String>.from(choices);
                          if (value) {
                            if (!updated.contains(ability)) {
                              updated.add(ability);
                            }
                          } else {
                            updated.remove(ability);
                          }
                          ref
                              .read(creationProvider.notifier)
                              .setBackgroundBonusChoices(updated);
                        },
                );
              }).toList(),
            ),
          ] else ...[
            Text('Choose the +2 ability',
                style: AppTextStyles.lato(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((ability) {
                final selected = choices.isNotEmpty && choices.first == ability;
                return ChoiceChip(
                  label: Text(ability.toUpperCase()),
                  selected: selected,
                  selectedColor: AppTheme.crimson,
                  onSelected: (_) {
                    final second = choices.length > 1 && choices[1] != ability
                        ? choices[1]
                        : options.firstWhere((item) => item != ability,
                            orElse: () => ability);
                    ref
                        .read(creationProvider.notifier)
                        .setBackgroundBonusChoices([ability, second]);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text('Choose the +1 ability',
                style: AppTextStyles.lato(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((ability) {
                final selected = choices.length > 1 && choices[1] == ability;
                final disabled = choices.isNotEmpty && choices.first == ability;
                return ChoiceChip(
                  label: Text(ability.toUpperCase()),
                  selected: selected,
                  selectedColor: AppTheme.crimson,
                  onSelected: disabled
                      ? null
                      : (_) {
                          final first =
                              choices.isNotEmpty ? choices.first : ability;
                          ref
                              .read(creationProvider.notifier)
                              .setBackgroundBonusChoices([first, ability]);
                        },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeContent() {
    switch (_mode) {
      case _AbilityMode.standardArray:
        return _buildStandardArray();
      case _AbilityMode.pointBuy:
        return _buildPointBuy();
      case _AbilityMode.custom:
        return _buildCustom();
    }
  }

  Widget _buildStandardArray() {
    final remaining = _remainingValues;
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Available: ',
              style: AppTextStyles.lato(color: Colors.white54, fontSize: 13),
            ),
            ...List<int>.from(_StepAbilityScoresState._standardValues).map((v) {
              final isUsed = !remaining.contains(v) ||
                  remaining.where((r) => r == v).length <
                      _StepAbilityScoresState._standardValues
                          .where((s) => s == v)
                          .length;
              return Container(
                margin: const EdgeInsets.only(right: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isUsed ? Colors.white10 : AppTheme.gold,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isUsed ? Colors.white12 : AppTheme.gold,
                  ),
                ),
                child: Text(
                  '$v',
                  style: AppTextStyles.cinzel(
                    color: isUsed ? Colors.white38 : AppTheme.charcoal,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).fold<List<Widget>>([], (acc, w) {
              if (acc.length < _StepAbilityScoresState._standardValues.length) {
                acc.add(w);
              }
              return acc;
            }),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _resetArray,
            icon: const Icon(Icons.refresh, size: 14, color: Colors.white38),
            label: Text(
              'Reset',
              style: AppTextStyles.lato(color: Colors.white38, fontSize: 12),
            ),
          ),
        ),
        ...List.generate(_StepAbilityScoresState._keys.length, (i) {
          final key = _StepAbilityScoresState._keys[i];
          final label = _StepAbilityScoresState._abilities[i];
          final assigned = _assignments[key];
          final mod =
              assigned != null ? DiceCalculator.getModifier(assigned) : null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(
                width: 44,
                child: Text(
                  label,
                  style: AppTextStyles.cinzel(
                    color: AppTheme.gold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: assigned,
                  hint: Text(
                    'Choose',
                    style: AppTextStyles.lato(color: Colors.white38),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            assigned != null ? AppTheme.gold : Colors.white24,
                      ),
                    ),
                  ),
                  dropdownColor: AppTheme.ashGray,
                  items: [
                    ...{
                      ...remaining,
                      if (assigned != null) assigned,
                    }.toList()
                      ..sort((a, b) => b.compareTo(a)),
                  ]
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(
                              '$v',
                              style: AppTextStyles.cinzel(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) _assignValue(key, v);
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 44,
                child: Text(
                  mod != null ? (mod >= 0 ? '+$mod' : '$mod') : '-”',
                  style: AppTextStyles.cinzel(
                    color: mod == null
                        ? Colors.white24
                        : mod >= 0
                            ? Colors.greenAccent
                            : Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
          );
        }),
        if (!_isArrayComplete)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Assign all values to continue',
              style: AppTextStyles.lato(
                color: Colors.orangeAccent,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPointBuy() {
    final isOver = _pointsLeft < 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isOver ? Colors.red : AppTheme.gold,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOver ? Colors.redAccent : AppTheme.gold,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOver ? Icons.warning_amber_rounded : Icons.toll,
                color: isOver ? Colors.redAccent : AppTheme.gold,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Points: $_pointsLeft / 27 remaining',
                style: AppTextStyles.cinzel(
                  color: isOver ? Colors.redAccent : AppTheme.gold,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_StepAbilityScoresState._keys.length, (i) {
          final key = _StepAbilityScoresState._keys[i];
          final score = _pointBuyScores[key]!;
          final mod = DiceCalculator.getModifier(score);
          final cost = _StepAbilityScoresState._pointCosts[score] ?? 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(
                width: 44,
                child: Text(_StepAbilityScoresState._abilities[i],
                    style: AppTextStyles.cinzel(
                      color: AppTheme.gold,
                      fontSize: 13,
                    )),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 22),
                color: Colors.white54,
                onPressed: () => _adjustPointBuy(key, -1),
                padding: EdgeInsets.zero,
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.gold,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$score',
                        style: AppTextStyles.cinzel(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(
                      mod >= 0 ? '+$mod' : '$mod',
                      style: AppTextStyles.lato(
                        fontSize: 11,
                        color: mod >= 0 ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 22),
                color: Colors.white54,
                onPressed: () => _adjustPointBuy(key, 1),
                padding: EdgeInsets.zero,
              ),
              const Spacer(),
              Text(
                'Cost: $cost',
                style: AppTextStyles.lato(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ]),
          );
        }),
        const SizedBox(height: 8),
        _PointCostTable(),
      ],
    );
  }

  Widget _buildCustom() {
    return Column(
      children: [
        Text(
          'Enter your rolled or custom ability scores below.',
          style: AppTextStyles.lato(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 16),
        ...List.generate(_StepAbilityScoresState._keys.length, (i) {
          final key = _StepAbilityScoresState._keys[i];
          final ctrl = _customCtrl[key]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              SizedBox(
                width: 44,
                child: Text(_StepAbilityScoresState._abilities[i],
                    style: AppTextStyles.cinzel(
                      color: AppTheme.gold,
                      fontSize: 13,
                    )),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.cinzel(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(isDense: true),
                  onChanged: (_) => _saveCustom(),
                ),
              ),
              const SizedBox(width: 16),
              Builder(builder: (ctx) {
                final v = int.tryParse(ctrl.text) ?? 10;
                final m = DiceCalculator.getModifier(v);
                return Text(
                  m >= 0 ? '+$m' : '$m',
                  style: AppTextStyles.cinzel(
                    color: m >= 0 ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ]),
          );
        }),
      ],
    );
  }
}
