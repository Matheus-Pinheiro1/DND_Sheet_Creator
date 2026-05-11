import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dice_calculator.dart';
import '../../../../core/utils/weapon_bonus_calculator.dart';
import '../../../../data/local/weapons_data.dart';
import '../../../../data/models/class_feature_model.dart';
import '../../../../data/models/attack_model.dart';
import '../../../../data/models/character_model.dart';
import '../../../../data/services/class_features_service.dart';
import '../../../../providers/character_providers.dart';
import '../../../../providers/dnd_api_providers.dart';
import '../../shared/dialogs/feature_detail_dialog.dart';
import '../../shared/dialogs/weapon_picker_bottom_sheet.dart';
import '../../shared/widgets/stat_box.dart';

part 'widgets/tab_combat_attack_form.dart';
part 'widgets/tab_combat_attack_widgets.dart';
part 'widgets/tab_combat_currency_widgets.dart';
part 'widgets/tab_combat_shared_widgets.dart';
part 'widgets/tab_combat_status_widgets.dart';

class TabCombat extends ConsumerWidget {
  final CharacterModel character;

  const TabCombat({super.key, required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void save(CharacterModel updated) {
      ref.read(charactersProvider.notifier).updateCharacter(updated);
    }

    void applyDamage(int value) {
      final tempRemaining = character.temporaryHP;
      final damageToTemp = value.clamp(0, tempRemaining).toInt();
      final damageToHP = value - damageToTemp;

      save(
        character.copyWith(
          temporaryHP: tempRemaining - damageToTemp,
          currentHP:
              (character.currentHP - damageToHP).clamp(0, character.maxHP),
        ),
      );
    }

    final profBonus = DiceCalculator.getProficiencyBonus(character.level);
    final initiative = character.initiative == 0
        ? DiceCalculator.getModifier(character.dexterity)
        : character.initiative;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Hit Points'),
          _HPTracker(
            current: character.currentHP,
            temp: character.temporaryHP,
            max: character.maxHP,
            onDamage: applyDamage,
            onHeal: (value) => save(
              character.copyWith(
                currentHP:
                    (character.currentHP + value).clamp(0, character.maxHP),
              ),
            ),
            onTempHP: (value) => save(
              character.copyWith(temporaryHP: value),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Defense'),
          Row(
            children: [
              Expanded(
                child: _EditableStat(
                  label: 'Armor Class',
                  value: character.armorClass,
                  color: Colors.blueGrey.shade300,
                  onEdit: (value) => save(
                    character.copyWith(armorClass: value),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatDisplay(
                  label: 'Initiative',
                  value: initiative >= 0 ? '+$initiative' : '$initiative',
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _EditableStat(
                  label: 'Speed (ft)',
                  value: character.speed,
                  color: Colors.greenAccent,
                  onEdit: (value) => save(
                    character.copyWith(speed: value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatDisplay(
                  label: 'Hit Dice',
                  value: '${character.level}d${character.hitDie}',
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatDisplay(
                  label: 'Proficiency',
                  value: '+$profBonus',
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Exhaustion'),
          _ExhaustionTracker(
            baseSpeed: character.speed,
            level: character.exhaustionLevel,
            onChanged: (value) => save(
              character.copyWith(exhaustionLevel: value),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Attacks & Actions'),
          _AttacksSection(character: character, onUpdate: save),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          const _SectionLabel('Class Actions'),
          _ClassActionsSection(character: character),
          const SizedBox(height: 16),
          const _SectionLabel('Death Saving Throws'),
          _DeathSavesWidget(character: character, onUpdate: save),
          const SizedBox(height: 16),
          const _SectionLabel('Currency'),
          _CurrencyWidget(character: character, onUpdate: save),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
