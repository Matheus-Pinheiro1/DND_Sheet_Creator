import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/dice_calculator.dart';
import '../core/utils/weapon_bonus_calculator.dart';
import '../data/local/granted_spells_2024.dart';
import '../data/local/weapons_data.dart';
import '../data/models/attack_model.dart';
import '../data/models/character_model.dart';
import '../data/services/artificer_choice_service.dart';
import '../data/services/barbarian_choice_service.dart';
import '../data/services/bard_choice_service.dart';
import '../data/services/cleric_choice_service.dart';
import '../data/services/druid_choice_service.dart';
import '../data/services/equipment_mechanics_service.dart';
import '../data/services/fighter_choice_service.dart';
import '../data/services/monk_choice_service.dart';
import '../data/services/paladin_choice_service.dart';
import '../data/services/progression_service.dart';
import '../data/services/ranger_choice_service.dart';
import '../data/services/rogue_choice_service.dart';
import '../data/services/sorcerer_choice_service.dart';
import '../data/services/starting_equipment_service.dart';
import '../data/services/warlock_choice_service.dart';
import '../data/services/wizard_choice_service.dart';

part 'character_creation_state.dart';
part 'character_creation_helpers.dart';
part 'character_creation_model_builder.dart';
part 'character_creation_ability_builder.dart';
part 'character_creation_attack_builder.dart';
part 'character_creation_advancement_builder.dart';
part 'character_creation_notifier.dart';
part 'character_creation_notifier_class_choices.dart';
part 'character_creation_notifier_warlock_rogue_artificer_choices.dart';
part 'character_creation_notifier_ranger_barbarian_fighter_choices.dart';
part 'character_creation_notifier_paladin_wizard_choices.dart';
part 'character_creation_notifier_loaders.dart';

final creationProvider =
    StateNotifierProvider.autoDispose<CreationNotifier, CreationState>((ref) {
  return CreationNotifier();
});
