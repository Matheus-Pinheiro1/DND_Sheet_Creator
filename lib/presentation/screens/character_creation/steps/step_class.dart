import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/data/local/weapons_data.dart';
import 'package:dnd_character_sheet/data/models/custom_class_model.dart';
import 'package:dnd_character_sheet/data/remote/class_dto.dart';
import 'package:dnd_character_sheet/data/services/artificer_choice_service.dart';
import 'package:dnd_character_sheet/data/services/barbarian_choice_service.dart';
import 'package:dnd_character_sheet/data/services/fighter_choice_service.dart';
import 'package:dnd_character_sheet/data/services/paladin_choice_service.dart';
import 'package:dnd_character_sheet/data/services/ranger_choice_service.dart';
import 'package:dnd_character_sheet/data/services/rogue_choice_service.dart';
import 'package:dnd_character_sheet/presentation/screens/custom_options/custom_class_screen.dart';
import 'package:dnd_character_sheet/presentation/screens/character_creation/steps/widgets/step_class_druid_choices.dart';
import 'package:dnd_character_sheet/presentation/screens/character_creation/steps/widgets/step_class_sorcerer_choices.dart';
import 'package:dnd_character_sheet/presentation/screens/character_creation/steps/widgets/step_class_warlock_choices.dart';
import 'package:dnd_character_sheet/providers/character_creation_provider.dart';
import 'package:dnd_character_sheet/providers/custom_options_providers.dart';
import 'package:dnd_character_sheet/providers/dnd_api_providers.dart';
import 'package:dnd_character_sheet/presentation/screens/shared/widgets/loading_dragon.dart';
import 'package:dnd_character_sheet/presentation/screens/shared/dialogs/context_info_dialog.dart';

part 'widgets/step_class_cards.dart';
part 'widgets/step_class_combat_choices.dart';

class StepClass extends ConsumerWidget {
  const StepClass({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classesProvider);
    final customClasses = ref.watch(customClassesProvider);
    final uaClassesAsync = ref.watch(uaClassesProvider);
    final state = ref.watch(creationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Class',
                style: AppTextStyles.cinzel(
                  color: AppTheme.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const ContextInfoButton(
              title: 'Choosing a Class',
              body:
                  'Class defines your hit die, saving throw proficiencies, spellcasting ability if any, and the main feature progression of the character. Some classes also unlock a subclass at level 3, which is chosen in this same step when required.',
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (customClasses.isNotEmpty) ...[
          const _SectionHeader('🧪 Homebrew Classes'),
          ...customClasses.map(
            (customClass) => _CustomClassCard(
              customClass: customClass,
              isSelected: state.className == 'custom_class_${customClass.id}',
              onTap: () {
                ref.read(creationProvider.notifier).setClass(
                      className: 'custom_class_${customClass.id}',
                      classDisplayName: customClass.name,
                      hitDie: customClass.hitDie,
                      spellcastingAbility:
                          customClass.spellcastingAbility ?? '',
                      savingThrows: customClass.savingThrows,
                      proficiencies: customClass.proficiencies,
                    );
              },
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CustomClassScreen(existing: customClass),
                ),
              ),
              onDelete: () => _confirmDelete(context, ref, customClass),
            ),
          ),
          const SizedBox(height: 8),
        ],
        _CreateCustomButton(
          label: 'Create Homebrew Class',
          icon: Icons.add,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CustomClassScreen(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OFFICIAL CLASSES (2024)',
                  style: AppTextStyles.lato(
                    color: Colors.white24,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ),
        classesAsync.when(
          loading: () =>
              const Center(child: LoadingDragon(label: 'Loading...')),
          error: (e, _) => Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                const Text('Failed to load classes.'),
                ElevatedButton(
                  onPressed: () => ref.invalidate(classesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (classes) => Column(
            children: [
              ...classes.map((cls) {
                final isSelected = state.className == cls.index;
                return _ClassCard(
                  cls: cls,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(creationProvider.notifier).setClass(
                          className: cls.index,
                          classDisplayName: cls.name,
                          hitDie: cls.hitDie,
                          spellcastingAbility: cls.spellcastingAbility ?? '',
                          savingThrows: cls.savingThrows,
                          proficiencies: cls.proficiencies,
                        );
                  },
                );
              }),
              const SizedBox(height: 12),
              const _SectionHeader('🧪 Unearthed Arcana Classes'),
              ...uaClassesAsync.maybeWhen(
                data: (uaClasses) => uaClasses.map((cls) {
                  final isSelected = state.className == cls.index;
                  return _ClassCard(
                    cls: cls,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(creationProvider.notifier).setClass(
                            className: cls.index,
                            classDisplayName: cls.name,
                            hitDie: cls.hitDie,
                            spellcastingAbility: cls.spellcastingAbility ?? '',
                            savingThrows: cls.savingThrows,
                            proficiencies: cls.proficiencies,
                          );
                    },
                  );
                }).toList(),
                orElse: () => [
                  Text(
                    'UA classes are loaded from the local catalog so the list stays stable offline.',
                    style:
                        AppTextStyles.lato(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              if (state.className.isNotEmpty &&
                  !state.className.startsWith('custom_class_') &&
                  state.level >=
                      _subclassUnlockLevel(
                          classes, state.className, uaClassesAsync))
                _SubclassSelector(classIndex: state.className),
              if (state.className == 'ranger') ...[
                const SizedBox(height: 16),
                const _RangerCombatChoices(),
              ],
              if (state.className == 'barbarian') ...[
                const SizedBox(height: 16),
                const _BarbarianCombatChoices(),
              ],
              if (state.className == 'fighter') ...[
                const SizedBox(height: 16),
                const _FighterCombatChoices(),
              ],
              if (state.className == 'artificer') ...[
                const SizedBox(height: 16),
                const _ArtificerBaseChoices(),
              ],
              if (FighterChoiceService.isBattleMaster(
                className: state.className,
                subclass: state.subclass,
                level: state.level,
              )) ...[
                const SizedBox(height: 16),
                const _BattleMasterSubclassChoices(),
              ],
              if (state.className == 'paladin') ...[
                const SizedBox(height: 16),
                const _PaladinCombatChoices(),
              ],
              if (state.className == 'druid') ...[
                const SizedBox(height: 16),
                const DruidClassChoices(),
              ],
              if (state.className == 'sorcerer') ...[
                const SizedBox(height: 16),
                const SorcererClassChoices(),
              ],
              if (state.className == 'warlock') ...[
                const SizedBox(height: 16),
                const WarlockClassChoices(),
              ],
              if (RogueChoiceService.needsScionDreadAllegiance(
                className: state.className,
                subclass: state.subclass,
                level: state.level,
              )) ...[
                const SizedBox(height: 16),
                const _RogueScionSubclassChoices(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  int _subclassUnlockLevel(
    List<ClassDto> officialClasses,
    String classIndex,
    AsyncValue<List<ClassDto>> uaClassesAsync,
  ) {
    for (final cls in officialClasses) {
      if (cls.index == classIndex) return cls.subclassLevel;
    }
    final uaClasses = uaClassesAsync.valueOrNull ?? const <ClassDto>[];
    for (final cls in uaClasses) {
      if (cls.index == classIndex) return cls.subclassLevel;
    }
    return 3;
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CustomClassModel customClass,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.ashGray,
        title: Text(
          'Delete ${customClass.name}?',
          style: AppTextStyles.cinzel(color: AppTheme.gold),
        ),
        content: Text(
          'This homebrew class will be permanently deleted.',
          style: AppTextStyles.lato(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(customClassesProvider.notifier).delete(customClass.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
