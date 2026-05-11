import 'armor_data.dart';
import 'choice_lists_data.dart';
import 'class_feature_details_data.dart';
import 'class_features_data.dart';
import 'equipment_options_data.dart';
import 'feats_data.dart';
import 'granted_spells_2024.dart';
import 'monster_metadata.dart';
import 'progression_data.dart';
import 'spells_data.dart';
import 'subclasses_2024_data_expanded.dart';
import 'weapons_data.dart';

class LocalDataLoader {
  LocalDataLoader._();

  static Future<void> loadAll() {
    return Future.wait([
      ArmorData.load(),
      ChoiceListsData.load(),
      ClassFeatureDetailsData.load(),
      ClassFeaturesData.load(),
      EquipmentOptionsData.load(),
      FeatsData.load(),
      GrantedSpells2024Data.load(),
      MonsterMetadataData.load(),
      ProgressionData.load(),
      SpellCatalogData.load(),
      Subclasses2024Data.load(),
      WeaponsData.load(),
    ]);
  }
}
