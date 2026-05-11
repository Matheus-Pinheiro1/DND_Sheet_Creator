part of 'class_features_service.dart';

extension _ClassFeatureTagRules on ClassFeaturesService {
  List<String> _tagsFor(String name) {
    final lower = name.toLowerCase();
    final tags = <String>[];
    if (lower.contains('spellcasting') || lower == 'pact magic') {
      tags.add('Spellcasting');
    }
    if (lower.contains('feature')) tags.add('Subclass');
    if (lower.contains('ability score improvement')) tags.add('ASI / Feat');
    if (lower.contains('extra attack')) tags.add('Attack Upgrade');
    if (lower.contains('turn undead')) tags.add('Channel Divinity');
    if (lower == 'rage' ||
        lower == 'second wind' ||
        lower == 'countercharm' ||
        lower == 'elemental fury' ||
        lower == 'wild companion' ||
        lower == 'innate sorcery' ||
        lower == 'font of magic' ||
        lower == 'metamagic' ||
        lower == 'sorcery incarnate' ||
        lower == 'arcane apotheosis' ||
        lower == 'eldritch invocations' ||
        lower == 'magical cunning' ||
        lower == 'contact patron' ||
        lower.startsWith('mystic arcanum') ||
        lower == 'eldritch master' ||
        lower == 'mage hand legerdemain' ||
        lower == 'magical ambush' ||
        lower == 'versatile trickster' ||
        lower == 'spell thief' ||
        lower == 'assassinate' ||
        lower == 'envenom weapons' ||
        lower == 'death strike' ||
        lower == 'psychic blades' ||
        lower == 'psionic power' ||
        lower == 'soul blades' ||
        lower == 'psychic veil' ||
        lower == 'rend mind' ||
        lower == 'fast hands' ||
        lower == 'thief\'s reflexes' ||
        lower == 'bloodthirst' ||
        lower == 'combat superiority' ||
        lower == 'know your enemy' ||
        lower == 'relentless' ||
        lower == 'war bond' ||
        lower == 'war magic' ||
        lower == 'eldritch strike' ||
        lower == 'arcane charge' ||
        lower == 'improved war magic' ||
        lower == 'telekinetic adept' ||
        lower == 'guarded mind' ||
        lower == 'bulwark of force' ||
        lower == 'telekinetic master' ||
        lower == 'frenzy' ||
        lower == 'mindless rage' ||
        lower == 'retaliation' ||
        lower == 'intimidating presence' ||
        lower == 'rage of the wilds' ||
        lower == 'power of the wilds' ||
        lower == 'vitality of the tree' ||
        lower == 'branches of the tree' ||
        lower == 'battering roots' ||
        lower == 'travel along the tree' ||
        lower == 'divine fury' ||
        lower == 'warrior of the gods' ||
        lower == 'fanatical focus' ||
        lower == 'zealous presence' ||
        lower == 'rage of the gods' ||
        lower == 'cutting words' ||
        lower == 'peerless skill' ||
        lower == 'bardic inspiration') {
      tags.add('Combat');
    }
    if (lower.contains('wild shape')) tags.add('Transformation');
    return tags;
  }
}
