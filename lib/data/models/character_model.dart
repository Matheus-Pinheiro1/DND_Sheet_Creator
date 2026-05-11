import 'package:hive/hive.dart';
import '../../core/constants/hive_constants.dart';
import 'attack_model.dart';

part 'character_model.g.dart';

@HiveType(typeId: HiveConstants.characterTypeId)
class CharacterModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  @HiveField(2)
  final String race;
  @HiveField(3)
  final String raceName;
  @HiveField(4)
  final String className;
  @HiveField(5)
  final String classDisplayName;
  @HiveField(6)
  final String subclass;
  @HiveField(7)
  final String subclassName;
  @HiveField(8)
  final String background;
  @HiveField(9)
  final String backgroundName;

  @HiveField(10)
  final String alignment;
  @HiveField(11)
  final int level;
  @HiveField(12)
  final int experiencePoints;

  @HiveField(13)
  final int strength;
  @HiveField(14)
  final int dexterity;
  @HiveField(15)
  final int constitution;
  @HiveField(16)
  final int intelligence;
  @HiveField(17)
  final int wisdom;
  @HiveField(18)
  final int charisma;

  @HiveField(19)
  final int maxHP;
  @HiveField(20)
  final int currentHP;
  @HiveField(21)
  final int temporaryHP;
  @HiveField(22)
  final int armorClass;
  @HiveField(23)
  final int speed;
  @HiveField(24)
  final int initiative;
  @HiveField(25)
  final int hitDie;

  @HiveField(26)
  final List<String> proficientSkills;
  @HiveField(27)
  final List<String> savingThrowProfs;
  @HiveField(28)
  final List<String> selectedSpells;
  @HiveField(29)
  final List<String> preparedSpells;
  @HiveField(30)
  final List<int> spellSlotsMax;
  @HiveField(31)
  final List<int> spellSlotsUsed;

  @HiveField(32)
  final String personalityTraits;
  @HiveField(33)
  final String ideals;
  @HiveField(34)
  final String bonds;
  @HiveField(35)
  final String flaws;
  @HiveField(36)
  final String backstory;
  @HiveField(37)
  final String notes;

  @HiveField(38)
  final List<String> equipment;
  @HiveField(39)
  final int copper;
  @HiveField(40)
  final int silver;
  @HiveField(41)
  final int electrum;
  @HiveField(42)
  final int gold;
  @HiveField(43)
  final int platinum;

  @HiveField(44)
  final bool inspiration;
  @HiveField(45)
  final int deathSaveSuccesses;
  @HiveField(46)
  final int deathSaveFailures;
  @HiveField(47)
  final String? avatarChoice;

  @HiveField(48)
  final DateTime createdAt;
  @HiveField(49)
  final DateTime updatedAt;

  @HiveField(50)
  final String spellcastingAbility;
  @HiveField(51)
  final List<String> languages;
  @HiveField(52)
  final List<String> proficiencies;

  @HiveField(53)
  final List<AttackModel> attacks;

  @HiveField(54)
  final String concentrationSpell;

  @HiveField(55)
  final List<String> backgroundSkillProfs;

  @HiveField(56)
  final List<String> levelAdvancements;

  @HiveField(57)
  final int exhaustionLevel;

  CharacterModel({
    required this.id,
    required this.name,
    this.race = '',
    this.raceName = '',
    this.className = '',
    this.classDisplayName = '',
    this.subclass = '',
    this.subclassName = '',
    this.background = '',
    this.backgroundName = '',
    this.alignment = 'True Neutral',
    this.level = 1,
    this.experiencePoints = 0,
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.maxHP = 0,
    this.currentHP = 0,
    this.temporaryHP = 0,
    this.armorClass = 10,
    this.speed = 30,
    this.initiative = 0,
    this.hitDie = 8,
    List<String>? proficientSkills,
    List<String>? savingThrowProfs,
    List<String>? selectedSpells,
    List<String>? preparedSpells,
    List<int>? spellSlotsMax,
    List<int>? spellSlotsUsed,
    this.personalityTraits = '',
    this.ideals = '',
    this.bonds = '',
    this.flaws = '',
    this.backstory = '',
    this.notes = '',
    List<String>? equipment,
    this.copper = 0,
    this.silver = 0,
    this.electrum = 0,
    this.gold = 0,
    this.platinum = 0,
    this.inspiration = false,
    this.deathSaveSuccesses = 0,
    this.deathSaveFailures = 0,
    this.avatarChoice,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.spellcastingAbility = '',
    List<String>? languages,
    List<String>? proficiencies,
    List<AttackModel>? attacks,
    this.concentrationSpell = '',
    List<String>? backgroundSkillProfs,
    List<String>? levelAdvancements,
    this.exhaustionLevel = 0,
  })  : proficientSkills = proficientSkills ?? [],
        savingThrowProfs = savingThrowProfs ?? [],
        selectedSpells = selectedSpells ?? [],
        preparedSpells = preparedSpells ?? [],
        spellSlotsMax = spellSlotsMax ?? List.filled(9, 0),
        spellSlotsUsed = spellSlotsUsed ?? List.filled(9, 0),
        equipment = equipment ?? [],
        languages = languages ?? [],
        proficiencies = proficiencies ?? [],
        attacks = attacks ?? [],
        backgroundSkillProfs = backgroundSkillProfs ?? [],
        levelAdvancements = levelAdvancements ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  CharacterModel copyWith({
    String? id,
    String? name,
    String? race,
    String? raceName,
    String? className,
    String? classDisplayName,
    String? subclass,
    String? subclassName,
    String? background,
    String? backgroundName,
    String? alignment,
    int? level,
    int? experiencePoints,
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
    int? maxHP,
    int? currentHP,
    int? temporaryHP,
    int? armorClass,
    int? speed,
    int? initiative,
    int? hitDie,
    List<String>? proficientSkills,
    List<String>? savingThrowProfs,
    List<String>? selectedSpells,
    List<String>? preparedSpells,
    List<int>? spellSlotsMax,
    List<int>? spellSlotsUsed,
    String? personalityTraits,
    String? ideals,
    String? bonds,
    String? flaws,
    String? backstory,
    String? notes,
    List<String>? equipment,
    int? copper,
    int? silver,
    int? electrum,
    int? gold,
    int? platinum,
    bool? inspiration,
    int? deathSaveSuccesses,
    int? deathSaveFailures,
    String? avatarChoice,
    bool clearAvatarChoice = false,
    DateTime? createdAt,
    String? spellcastingAbility,
    List<String>? languages,
    List<String>? proficiencies,
    List<AttackModel>? attacks,
    String? concentrationSpell,
    List<String>? backgroundSkillProfs,
    List<String>? levelAdvancements,
    int? exhaustionLevel,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      race: race ?? this.race,
      raceName: raceName ?? this.raceName,
      className: className ?? this.className,
      classDisplayName: classDisplayName ?? this.classDisplayName,
      subclass: subclass ?? this.subclass,
      subclassName: subclassName ?? this.subclassName,
      background: background ?? this.background,
      backgroundName: backgroundName ?? this.backgroundName,
      alignment: alignment ?? this.alignment,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
      maxHP: maxHP ?? this.maxHP,
      currentHP: currentHP ?? this.currentHP,
      temporaryHP: temporaryHP ?? this.temporaryHP,
      armorClass: armorClass ?? this.armorClass,
      speed: speed ?? this.speed,
      initiative: initiative ?? this.initiative,
      hitDie: hitDie ?? this.hitDie,
      proficientSkills: proficientSkills ?? List.from(this.proficientSkills),
      savingThrowProfs: savingThrowProfs ?? List.from(this.savingThrowProfs),
      selectedSpells: selectedSpells ?? List.from(this.selectedSpells),
      preparedSpells: preparedSpells ?? List.from(this.preparedSpells),
      spellSlotsMax: spellSlotsMax ?? List.from(this.spellSlotsMax),
      spellSlotsUsed: spellSlotsUsed ?? List.from(this.spellSlotsUsed),
      personalityTraits: personalityTraits ?? this.personalityTraits,
      ideals: ideals ?? this.ideals,
      bonds: bonds ?? this.bonds,
      flaws: flaws ?? this.flaws,
      backstory: backstory ?? this.backstory,
      notes: notes ?? this.notes,
      equipment: equipment ?? List.from(this.equipment),
      copper: copper ?? this.copper,
      silver: silver ?? this.silver,
      electrum: electrum ?? this.electrum,
      gold: gold ?? this.gold,
      platinum: platinum ?? this.platinum,
      inspiration: inspiration ?? this.inspiration,
      deathSaveSuccesses: deathSaveSuccesses ?? this.deathSaveSuccesses,
      deathSaveFailures: deathSaveFailures ?? this.deathSaveFailures,
      avatarChoice:
          clearAvatarChoice ? null : avatarChoice ?? this.avatarChoice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: DateTime.now(),
      spellcastingAbility: spellcastingAbility ?? this.spellcastingAbility,
      languages: languages ?? List.from(this.languages),
      proficiencies: proficiencies ?? List.from(this.proficiencies),
      attacks: attacks ?? List.from(this.attacks),
      concentrationSpell: concentrationSpell ?? this.concentrationSpell,
      backgroundSkillProfs:
          backgroundSkillProfs ?? List.from(this.backgroundSkillProfs),
      levelAdvancements: levelAdvancements ?? List.from(this.levelAdvancements),
      exhaustionLevel: exhaustionLevel ?? this.exhaustionLevel,
    );
  }

  List<String> get allProficientSkills =>
      {...proficientSkills, ...backgroundSkillProfs}.toList();
}
