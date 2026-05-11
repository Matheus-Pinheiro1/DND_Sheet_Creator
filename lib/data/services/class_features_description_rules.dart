part of 'class_features_service.dart';

extension _ClassFeatureDescriptionRules on ClassFeaturesService {
  String _descriptionFor(String name, {String? className}) {
    if (className == 'barbarian') {
      switch (name) {
        case 'Rage':
          return 'You can imbue yourself with primal power as a Bonus Action if you are not wearing Heavy armor. You regain one expended use when you finish a Short Rest and all expended uses when you finish a Long Rest. While your Rage is active, you have Resistance to Bludgeoning, Piercing, and Slashing damage, you have Advantage on Strength checks and Strength saving throws, and Strength-based weapon or Unarmed Strike damage rolls gain your Rage Damage bonus. You cannot cast spells or maintain Concentration while raging. Rage lasts until the end of your next turn and can be extended by attacking an enemy, forcing an enemy to make a saving throw, or spending a Bonus Action to extend it, up to 10 minutes.';
        case 'Unarmored Defense':
          return 'While you are not wearing armor, your base Armor Class equals 10 plus your Dexterity modifier and Constitution modifier. You can use a Shield and still gain this benefit.';
        case 'Weapon Mastery':
          return 'Your training with weapons allows you to use the mastery properties of two kinds of Simple or Martial Melee weapons of your choice. Whenever you finish a Long Rest, you can practice weapon drills and change one of those weapon choices.';
        case 'Danger Sense':
          return 'You gain an uncanny sense of when things are not as they should be, giving you an edge when you dodge perils. You have Advantage on Dexterity saving throws unless you have the Incapacitated condition.';
        case 'Reckless Attack':
          return 'When you make your first attack roll on your turn, you can decide to attack recklessly. Doing so gives you Advantage on attack rolls using Strength until the start of your next turn, but attack rolls against you have Advantage during that time.';
        case 'Primal Knowledge':
          return 'You gain proficiency in another skill of your choice from the skill list available to Barbarians at level 1. In addition, while your Rage is active, you can use Strength for Acrobatics, Intimidation, Perception, Stealth, or Survival checks.';
        case 'Fast Movement':
          return 'Your Speed increases by 10 feet while you are not wearing Heavy armor. This app applies that bonus automatically to the character Speed.';
        case 'Feral Instinct':
          return 'Your instincts are so honed that you have Advantage on Initiative rolls.';
        case 'Instinctive Pounce':
          return 'As part of the Bonus Action you take to enter your Rage, you can move up to half your Speed.';
        case 'Brutal Strike':
          return 'If you use Reckless Attack, you can forgo Advantage on one Strength-based attack roll of your choice on your turn. The chosen attack roll must not have Disadvantage. If it hits, the target takes an extra 1d10 damage of the same type dealt by the weapon or Unarmed Strike, and you can apply one Brutal Strike effect such as Forceful Blow or Hamstring Blow.';
        case 'Improved Brutal Strike':
          return 'You have honed new ways to attack furiously. Your Brutal Strike gains additional effect options, and the feature improves further at higher Barbarian levels.';
        case 'Relentless Rage':
          return 'While your Rage is active, if you drop to 0 Hit Points and do not die outright, you can attempt to stay standing. Repeated uses become harder until the DC resets after a rest.';
        case 'Persistent Rage':
          return 'When you roll Initiative, you can regain all expended uses of Rage. After you regain uses this way, you cannot do so again until you finish a Long Rest. In addition, your Rage lasts for 10 minutes without needing you to extend it from round to round; it still ends early if you become Unconscious or don Heavy armor.';
        case 'Indomitable Might':
          return 'If your total for a Strength check or Strength saving throw is less than your Strength score, you can use that score in place of the total.';
        case 'Primal Champion':
          return 'You embody primal power. Your Strength and Constitution scores increase by 4, to a maximum of 25. This app applies those increases automatically.';
      }
    }

    if (className == 'bard') {
      switch (name) {
        case 'Bardic Inspiration':
          return 'As a Bonus Action, you inspire another creature within 60 feet of yourself who can see or hear you. That creature gains one of your Bardic Inspiration dice. Once within the next hour when the creature fails a D20 Test, it can roll the die and add the number rolled to the d20, potentially turning the failure into a success. You can confer this die a number of times equal to your Charisma modifier, minimum once, and regain expended uses when you finish a Long Rest. The die is d6 at level 1, d8 at level 5, d10 at level 10, and d12 at level 15.';
        case 'Expertise':
          return 'Choose two of your skill proficiencies at Bard level 2. You gain Expertise in those skills. At Bard level 9, choose two more skill proficiencies. Expertise doubles your Proficiency Bonus for any ability check that uses one of the chosen skills.';
        case 'Jack of All Trades':
          return 'You can add half your Proficiency Bonus, rounded down, to any ability check you make that uses a skill proficiency you lack and that does not otherwise use your Proficiency Bonus. This app applies that bonus to non-proficient skill checks on the sheet.';
        case 'Font of Inspiration':
          return 'You regain all expended uses of Bardic Inspiration when you finish a Short or Long Rest. In addition, you can expend a spell slot with no action required to regain one expended use of Bardic Inspiration.';
        case 'Countercharm':
          return 'If you or a creature within 30 feet of you fails a saving throw against an effect that applies the Charmed or Frightened condition, you can take a Reaction to cause the save to be rerolled, and the new roll has Advantage.';
        case 'Magical Secrets':
          return 'Your magical knowledge now reaches beyond the Bard list. Whenever you reach a Bard level and your number of prepared level 1+ spells increases, you can choose any new prepared spells from the Bard, Cleric, Druid, and Wizard spell lists. Those chosen spells count as Bard spells for you. Whenever you replace a prepared Bard spell, you can also replace it with a spell from one of those lists. This app expands the Bard level 1+ spell picker to those lists at level 10 and higher.';
        case 'Superior Inspiration':
          return 'When you roll Initiative, you regain expended uses of Bardic Inspiration until you have two uses if you currently have fewer than two.';
        case 'Words of Creation':
          return 'You have mastered the words of life and death. Power Word Heal and Power Word Kill are always prepared for you and do not count against your prepared spells. When you cast either spell, you can target a second creature with it if that creature is within 10 feet of the first target. This app adds those spells automatically at Bard level 20.';
      }
    }

    if (className == 'druid') {
      switch (name) {
        case 'Druidic':
          return 'You know Druidic, the secret language of Druids. You also always have Speak with Animals prepared. This app adds Speak with Animals automatically to Druid spell selections.';
        case 'Primal Order':
          return 'Choose Magician or Warden. Magician grants one extra Druid cantrip and adds your Wisdom modifier, minimum +1, to Intelligence (Arcana or Nature) checks. Warden grants Martial weapon proficiency and Medium armor training. This app applies the chosen proficiencies, bonus cantrip, and Arcana/Nature bonus.';
        case 'Wild Shape':
          return 'As a Bonus Action, you transform into a known Beast form. You remain in that form for a number of hours equal to half your Druid level, or until you leave the form, use Wild Shape again, have the Incapacitated condition, or die. You regain one expended use on a Short Rest and all expended uses on a Long Rest.';
        case 'Wild Companion':
          return 'As a Magic Action, you can expend a spell slot or a use of Wild Shape to cast Find Familiar without Material components. The familiar is Fey and disappears when you finish a Long Rest.';
        case 'Wild Resurgence':
          return 'Once on each of your turns, if you have no Wild Shape uses left, you can give yourself one use by expending a spell slot. You can also expend one Wild Shape use to give yourself a level 1 spell slot, but only once before finishing a Long Rest.';
        case 'Elemental Fury':
          return 'Choose Potent Spellcasting or Primal Strike. Potent Spellcasting adds your Wisdom modifier to the damage you deal with any Druid cantrip. Primal Strike adds elemental damage once on each of your turns when you hit with a weapon attack or Beast form attack in Wild Shape.';
        case 'Improved Elemental Fury':
          return 'The option you chose for Elemental Fury improves. Potent Spellcasting increases the range of eligible Druid cantrips by 300 feet. Primal Strike increases its extra damage to 2d8.';
        case 'Beast Spells':
          return 'While using Wild Shape, you can cast spells in Beast form, except spells with a costly Material component or a Material component that is consumed.';
        case 'Archdruid':
          return 'Whenever you roll Initiative and have no Wild Shape uses left, you regain one use. You can also convert unexpended Wild Shape uses into a spell slot, with each use contributing 2 spell levels. Once you use that conversion, you cannot use it again until you finish a Long Rest.';
      }
    }

    if (className == 'sorcerer') {
      switch (name) {
        case 'Innate Sorcery':
          return 'As a Bonus Action, you can unleash the magic within you for 1 minute. During that time, your Sorcerer spell save DC increases by 1, and your Sorcerer spell attack rolls have Advantage. You can use this feature twice, and expended uses return when you finish a Long Rest.';
        case 'Font of Magic':
          return 'You gain Sorcery Points, starting with 2 at Sorcerer level 2 and scaling with your Sorcerer level. You regain all expended Sorcery Points on a Long Rest. You can convert spell slots into Sorcery Points with no action, and you can spend Sorcery Points as a Bonus Action to create temporary spell slots up to level 5 within the level limits of the feature.';
        case 'Metamagic':
          return 'Choose two Metamagic options at Sorcerer level 2, then two more at levels 10 and 17. These choices modify spells you cast by spending Sorcery Points. This app stores each choice by the level where it was gained and shows the chosen options on the feature card.';
        case 'Sorcerous Restoration':
          return 'When you finish a Short Rest, you can regain expended Sorcery Points up to half your Sorcerer level, rounded down. Once you recover points this way, you must finish a Long Rest before doing it again.';
        case 'Sorcery Incarnate':
          return 'If you have no uses of Innate Sorcery left, you can spend 2 Sorcery Points when you take the Bonus Action to activate it. While Innate Sorcery is active, you can apply up to two Metamagic options to each spell you cast.';
        case 'Arcane Apotheosis':
          return 'While Innate Sorcery is active, you can use one Metamagic option on each of your turns without paying that option\'s Sorcery Point cost.';
      }
    }

    if (className == 'warlock') {
      if (name.startsWith('Mystic Arcanum')) {
        return 'Your patron grants a high-level magical secret. Choose one Warlock spell of the listed level. You can cast the chosen spell once without expending a Pact Magic spell slot, and you regain the use when you finish a Long Rest. This app stores each arcanum spell separately from your normal prepared spells.';
      }
      switch (name) {
        case 'Eldritch Invocations':
          return 'You learn Eldritch Invocations, occult lessons that grant magical abilities, pact boons, or special spell benefits. The number you know scales with your Warlock level. This app records your selected invocations, applies their main automatic spell grants, and uses Pact of the Blade for suggested melee weapon attack bonuses.';
        case 'Pact Magic':
          return 'You cast Warlock spells with Pact Magic. Your spell slots are all the same level, and you regain expended Pact Magic slots when you finish a Short or Long Rest. The spell picker follows the Warlock table for cantrips, prepared spells, slot count, and slot level.';
        case 'Magical Cunning':
          return 'You can perform an esoteric rite for 1 minute. At the end of it, you regain expended Pact Magic spell slots up to half your maximum number of Pact Magic slots, rounded up. Once you use this feature, you cannot use it again until you finish a Long Rest.';
        case 'Contact Patron':
          return 'You always have Contact Other Plane prepared. With this feature, you can cast it without expending a spell slot to contact your patron, and you automatically succeed on the spell saving throw. Once you cast it this way, you must finish a Long Rest before doing so again.';
        case 'Eldritch Master':
          return 'When you use Magical Cunning, you regain all your expended Pact Magic spell slots instead of only half your maximum.';
      }
    }

    if (className == 'fighter') {
      switch (name) {
        case 'Fighting Style':
          return 'You have honed your martial prowess and gain a Fighting Style feat of your choice. Defense is recommended. Whenever you gain a Fighter level, you can replace the feat you chose with a different Fighting Style feat.';
        case 'Second Wind':
          return 'You have a limited well of physical and mental stamina. As a Bonus Action, you can regain Hit Points equal to 1d10 plus your Fighter level. You can use this feature twice at level 1, gaining more uses at higher Fighter levels. You regain one expended use when you finish a Short Rest, and you regain all expended uses when you finish a Long Rest.';
        case 'Weapon Mastery':
          return 'Your training with weapons allows you to use the mastery property of three kinds of Simple or Martial weapons of your choice. Whenever you finish a Long Rest, you can practice weapon drills and change one of those weapon choices. You gain more mastery choices at higher Fighter levels.';
        case 'Action Surge (one use)':
        case 'Action Surge (two uses)':
          return 'You can push yourself beyond your normal limits for a moment. On your turn, you can take one additional action, except the Magic action. Once you use this feature, you cannot do so again until you finish a Short or Long Rest. Starting at level 17, you can use it twice before a rest, but only once on a turn.';
        case 'Tactical Mind':
          return 'You have a mind for tactics on and off the battlefield. When you fail an ability check, you can expend a use of Second Wind to roll 1d10 and add the number rolled to the check, potentially turning it into a success. If the check still fails, this use of Second Wind is not expended.';
        case 'Tactical Shift':
          return 'Whenever you activate your Second Wind with a Bonus Action, you can move up to half your Speed without provoking Opportunity Attacks.';
        case 'Indomitable (one use)':
        case 'Indomitable (two uses)':
        case 'Indomitable (three uses)':
          return 'If you fail a saving throw, you can reroll it with a bonus equal to your Fighter level. You must use the new roll. You gain additional uses of this feature at higher Fighter levels.';
        case 'Tactical Master':
          return 'When you attack with a weapon whose mastery property you can use, you can replace that property with Push, Sap, or Slow for that attack.';
        case 'Extra Attack':
          return 'You can attack twice, instead of once, whenever you take the Attack action on your turn.';
        case 'Two Extra Attacks':
          return 'You can attack three times, instead of once, whenever you take the Attack action on your turn.';
        case 'Studied Attacks':
          return 'You study your opponents and learn from each attack you make. If you make an attack roll against a creature and miss, you have Advantage on your next attack roll against that creature before the end of your next turn.';
        case 'Three Extra Attacks':
          return 'You can attack four times, instead of once, whenever you take the Attack action on your turn.';
      }
    }

    if (className == 'rogue' && name == 'Expertise') {
      return 'You gain Expertise in two of your skill proficiencies of your choice. Sleight of Hand and Stealth are recommended if you have proficiency in them. At Rogue level 6, you gain Expertise in two more of your skill proficiencies of your choice. Expertise doubles your Proficiency Bonus for any ability check you make that uses one of your chosen proficiencies.';
    }

    if (className == 'monk') {
      switch (name) {
        case 'Unarmored Defense':
          return 'While you aren’t wearing armor or wielding a Shield, your base Armor Class equals 10 plus your Dexterity modifier and Wisdom modifier.';
        case 'Martial Arts':
          return '''Your practice of martial arts gives you mastery of combat styles that use your Unarmed Strike and Monk weapons, which are the following:
Simple Melee weapons
Martial Melee weapons that have the Light property
You gain the following benefits while you are unarmed or wielding only Monk weapons and you aren’t wearing armor or wielding a Shield.
Bonus Unarmed Strike. You can make an Unarmed Strike as a Bonus Action.
Martial Arts Die. You can roll 1d6 in place of the normal damage of your Unarmed Strike or Monk weapons. This die changes as you gain Monk levels, as shown in the Martial Arts column of the Monk Features table.
Dexterous Attacks. You can use your Dexterity modifier instead of your Strength modifier for the attack and damage rolls of your Unarmed Strikes and Monk weapons. In addition, when you use the Grapple or Shove option of your Unarmed Strike, you can use your Dexterity modifier instead of your Strength modifier to determine the save DC.''';
        case 'Unarmored Movement':
          return 'Your Speed increases by 10 feet while you aren’t wearing armor or wielding a Shield. This bonus increases when you reach certain Monk levels, as shown in the Monk Features table. The bonus becomes +15 feet at level 6, +20 feet at level 10, +25 feet at level 14, and +30 feet at level 18.';
        case 'Slow Fall':
          return 'You can take a Reaction when you fall to reduce any fall damage you take by an amount equal to five times your Monk level.';
        case 'Stunning Strike':
          return 'Once per turn when you hit a creature with a Monk weapon or an Unarmed Strike, you can expend 1 Focus Point to attempt a stunning blow. The target must make a Constitution saving throw. On a failed save, the target has the Stunned condition until the start of your next turn.';
        case 'Body and Mind':
          return 'You have developed your body and mind to new heights. Your Dexterity and Wisdom scores increase by 4, to a maximum of 25.';
      }
    }

    if (className == 'ranger') {
      switch (name) {
        case 'Favored Enemy':
          return "You always have the Hunter's Mark spell prepared. You can cast it twice without expending a spell slot, and you regain all expended uses of this ability when you finish a Long Rest. The number of free castings increases at higher Ranger levels, as shown in the Ranger class table.";
        case 'Weapon Mastery':
          return 'Your training with weapons allows you to use the mastery properties of two kinds of Simple or Martial weapons of your choice. Whenever you finish a Long Rest, you can practice weapon drills and change one of those weapon choices.';
        case 'Deft Explorer':
          return 'Thanks to your travels, you gain the following benefits.\n'
              'Expertise. Choose one of your skill proficiencies with which you lack Expertise. You gain Expertise in that skill.\n'
              'Languages. You know two languages of your choice.';
        case 'Fighting Style':
          return 'You gain one Fighting Style feat of your choice. Instead of choosing one of those feats, you can choose Druidic Warrior: you learn two Druid cantrips of your choice. The chosen cantrips count as Ranger spells for you, and Wisdom is your spellcasting ability for them. Whenever you gain a Ranger level, you can replace one of these cantrips with another Druid cantrip.';
        case 'Expertise':
          return 'You gain Expertise in two of your skill proficiencies of your choice. Expertise doubles your Proficiency Bonus for any ability check you make that uses one of the chosen skill proficiencies.';
        case 'Roving':
          return "Your Speed increases by 10 feet while you aren't wearing Heavy Armor. You also have a Climb Speed and a Swim Speed equal to your Speed.";
        case 'Tireless':
          return 'Primal forces now help fuel you on your journeys, granting you the following benefits.\n'
              'Temporary Hit Points. As a Magic Action, you can give yourself a number of Temporary Hit Points equal to 1d8 plus your Wisdom modifier (minimum of 1). You can use this action a number of times equal to your Wisdom modifier (minimum of once), and you regain all expended uses when you finish a Long Rest.\n'
              'Decrease Exhaustion. Whenever you finish a Short Rest, your Exhaustion level, if any, decreases by 1.';
        case 'Relentless Hunter':
          return "Taking damage can't break your Concentration on Hunter's Mark.";
        case "Nature's Veil":
        case 'Nature’s Veil':
          return 'You invoke spirits of nature to magically hide yourself. As a Bonus Action, you can give yourself the Invisible condition until the end of your next turn. You can use this feature a number of times equal to your Wisdom modifier (minimum of once), and you regain all expended uses when you finish a Long Rest.';
        case 'Precise Hunter':
          return "You have Advantage on attack rolls against the creature currently marked by your Hunter's Mark.";
        case 'Feral Senses':
          return 'You have Blindsight with a range of 30 feet.';
        case 'Foe Slayer':
          return "The damage die of your Hunter's Mark is a d10 rather than a d6.";
      }
    }

    if (className == 'paladin') {
      switch (name) {
        case 'Lay On Hands':
          return 'Your blessed touch can heal wounds. You have a pool of healing power that replenishes when you finish a Long Rest. The pool contains a number of Hit Points equal to five times your Paladin level.\n'
              'As a Bonus Action, you can touch a creature, including yourself, and spend points from the pool to restore that many Hit Points. You can also spend 5 points from the pool to remove the Poisoned condition from the creature; those points do not also restore Hit Points.';
        case 'Weapon Mastery':
          return 'Your training with weapons allows you to use the mastery properties of two kinds of Simple or Martial weapons of your choice. Whenever you finish a Long Rest, you can practice weapon drills and change one of those weapon choices.';
        case 'Fighting Style':
          return 'You gain one Fighting Style of your choice. If you choose Blessed Warrior, you learn two Cleric cantrips of your choice. The chosen cantrips count as Paladin spells for you, and Charisma is your spellcasting ability for them.';
        case "Paladin's Smite":
          return 'You always have the Divine Smite spell prepared. You can cast it once without expending a spell slot, and you regain the ability to cast it this way when you finish a Long Rest.';
        case 'Channel Divinity':
          return 'You can channel divine energy directly from the Outer Planes, using it to fuel magical effects. You start with Divine Sense, and other Paladin features can give you additional Channel Divinity options.\n'
              'You can use this class\'s Channel Divinity twice. You regain one expended use when you finish a Short Rest, and you regain all expended uses when you finish a Long Rest. You gain an additional use at Paladin level 11.\n'
              'Divine Sense. As a Bonus Action, you can detect Celestials, Fiends, and Undead within 60 feet of yourself for 10 minutes, and you also detect consecrated or desecrated places and objects in that range.';
        case 'Faithful Steed':
          return 'You can call on the aid of an otherworldly steed. You always have the Find Steed spell prepared. You can cast it once without expending a spell slot, and you regain the ability to cast it this way when you finish a Long Rest.';
        case 'Aura of Protection':
          return 'You radiate a protective, invisible aura in a 10-foot Emanation. You and your allies in the aura gain a bonus to saving throws equal to your Charisma modifier, minimum bonus of +1. The aura is inactive while you have the Incapacitated condition.';
        case 'Abjure Foes':
          return 'As a Magic Action, you can expend one use of Channel Divinity to overwhelm foes with awe. Choose a number of creatures equal to your Charisma modifier, minimum one, that you can see within 60 feet. Each target must succeed on a Wisdom saving throw or have the Frightened condition for 1 minute or until it takes damage. While Frightened this way, it can do only one of the following on its turns: move, take an action, or take a Bonus Action.';
        case 'Aura of Courage':
          return 'You and your allies have immunity to the Frightened condition while in your Aura of Protection. If a Frightened ally enters the aura, that condition has no effect on that ally while there.';
        case 'Radiant Strikes':
          return 'Your strikes now carry supernatural power. When you hit a target with an attack roll using a Melee weapon or an Unarmed Strike, the target takes an extra 1d8 Radiant damage.';
        case 'Restoring Touch':
          return 'When you use Lay On Hands on a creature, you can also remove one or more of the following conditions from the creature: Blinded, Charmed, Deafened, Frightened, Paralyzed, or Stunned. You must spend 5 Hit Points from the Lay On Hands pool for each condition removed; those points do not also restore Hit Points.';
        case 'Aura Expansion':
          return 'Your Aura of Protection is now a 30-foot Emanation.';
      }
    }

    const exact = <String, String>{
      'Ability Score Improvement':
          'When you gain this feature, you can choose a feat or increase one ability score by 2, or increase two different ability scores by 1 each. Unless a rule says otherwise, this feature cannot raise an ability score above 20.',
      'Action Surge':
          'You can push yourself beyond your normal limits for a moment. On your turn, you can take one additional action, except the Magic action.\nOnce you use this feature, you can’t do so again until you finish a Short or Long Rest. Starting at level 17, you can use it twice before a rest but only once on a turn.',
      'Arcane Recovery':
          'You can regain some of your magical energy by studying your spellbook. When you finish a Short Rest, you can choose expended spell slots to recover. The spell slots can have a combined level equal to no more than half your Wizard level (round up), and none of the slots can be level 6 or higher. For example, if you\'re a level 4 Wizard, you can recover up to two levels’ worth of spell slots, regaining either one level 2 spell slot or two level 1 spell slots.Once you use this feature, you can\'t do so again until you finish a Long Rest.',
      'Bardic Inspiration':
          'Using Bardic Inspiration. As a Bonus Action, you can inspire another creature within 60 feet of yourself who can see or hear you. That creature gains one of your Bardic Inspiration dice. A creature can have only one Bardic Inspiration die at a time.\nOnce within the next hour when the creature fails a D20 Test, the creature can roll the Bardic Inspiration die and add the number rolled to the d20, potentially turning the failure into a success. A Bardic Inspiration die is expended when it\'s rolled.\nNumber of Uses. You can confer a Bardic Inspiration die a number of times equal to your Charisma modifier (minimum of once), and you regain all expended uses when you finish a Long Rest.\nAt Higher Levels. Your Bardic Inspiration die changes when you reach certain Bard levels, as shown in the Bardic Die column of the Bard Features table. The die becomes a d8 at level 5, a d10 at level 10, and a d12 at level 15.',
      'Channel Divinity':
          'You can channel divine energy directly from the Outer Planes, using it to fuel magical effects. You start with one such effect: Divine Sense, which is described below. Other Paladin features give additional Channel Divinity effect options. Each time you use this class\'s Channel Divinity, you choose which effect from this class to create.\nYou can use this class\'s Channel Divinity twice. You regain one of its expended uses when you finish a Short Rest, and you regain all expended uses when you finish a Long Rest. You gain an additional use when you reach Paladin level 11.\nDivine Sense. As a Bonus Action, you can open your awareness to detect Celestials, Fiends, and Undead. For the next 10 minutes or until you have the Incapacitated condition, you know the location of any creature of those types within 60 feet of yourself, and you know its creature type. Within the same radius, you also detect the presence of any place or object that has been consecrated or desecrated, as with the Hallow spell.',
      'Cunning Action':
          'Your quick thinking and agility allow you to move and act quickly. On your turn, you can take one of the following actions as a Bonus Action: Dash, Disengage, or Hide.',
      'Danger Sense':
          'You gain an uncanny sense of when things aren\'t as they should be, giving you an edge when you dodge perils. You have Advantage on Dexterity saving throws unless you have the Incapacitated condition.',
      'Divine Sense':
          'As an Action, until the end of your next turn, you know the location of any celestial, fiend, or undead within 60 feet of you that is not behind total cover. You also know the type of any being whose presence you sense.',
      'Divine Smite':
          'When you hit a creature with a melee weapon attack, you can expend one spell slot to deal radiant damage to the target in addition to the weapon’s damage. The extra damage increases with the slot level and deals extra damage against undead and fiends.',
      'Extra Attack':
          'You can attack twice instead of once whenever you take the Attack action on your turn.',
      'Fast Movement':
          'Your Speed increases by 10 feet while you aren’t wearing Heavy armor.',
      'Fighting Style':
          'You gain a Fighting Style feat of your choice. Defense is recommended.\nWhenever you gain a Fighter level, you can replace the feat you chose with a different Fighting Style feat.',
      'Ki':
          'You gain a pool of Ki Points equal to your monk level. You can spend those points on monk features such as Flurry of Blows, Patient Defense, and Step of the Wind. You regain all expended Ki when you finish a Short or Long Rest.',
      'Rage':
          'You can imbue yourself with a primal power called Rage, a force that grants you extraordinary might and resilience. You can enter it as a Bonus Action if you aren\'t wearing Heavy armor.While active, your Rage follows the rules below.\nDamage Resistance. You have Resistance to Bludgeoning, Piercing, and Slashing damage.\nRage Damage. When you make an attack using Strength—with either a weapon or an Unarmed Strike—and deal damage to the target, you gain a bonus to the damage that increases as you gain levels as a Barbarian.\nStrength Advantage. You have Advantage on Strength checks and Strength saving throws.\nNo Concentration or Spells. You can\'t maintain Concentration, and you can\'t cast spells.',
      'Reckless Attack':
          'You can throw aside all concern for defense to attack with increased ferocity. When you make your first attack roll on your turn, you can decide to attack recklessly. Doing so gives you Advantage on attack rolls using Strength until the start of your next turn, but attack rolls against you have Advantage during that time.',
      'Second Wind':
          'You have a limited well of physical and mental stamina that you can draw on. As a Bonus Action, you can use it to regain Hit Points equal to 1d10 plus your Fighter level.\nYou can use this feature twice. You regain one expended use when you finish a Short Rest, and you regain all expended uses when you finish a Long Rest.\nWhen you reach certain Fighter levels, you gain more uses of this feature, as shown in the Second Wind column of the Fighter Features table.',
      'Spellcasting':
          'This class can cast spells using its spellcasting feature. Your spellcasting ability, spell slots, and prepared or known spells depend on class and level.',
      'Turn Undead':
          'As an Action, you present your holy symbol and censure the undead. Each undead within 30 feet that can see or hear you must make a Wisdom saving throw. On a failure, it is turned for 1 minute or until it takes damage. A turned creature must spend its turns trying to move as far away from you as possible, cannot willingly move to a space within 30 feet of you, cannot take reactions, and can use only the Dash action or attempt to escape an effect preventing movement.',
      'Wild Shape':
          'As an Action, you can magically assume the shape of a beast you have seen before. The forms you can take depend on your druid level and the Wild Shape rules for movement and challenge restrictions. Your mental ability scores remain your own, while the beast form replaces the listed physical statistics as described by the feature.',
      'Metamagic':
          'Because your magic flows from within, you can alter your spells to suit your needs; you gain two Metamagic options of your choice from “Metamagic Options” later in this class’s description. You use the chosen options to temporarily modify spells you cast. To use an option, you must spend the number of Sorcery Points that it costs.\nYou can use only one Metamagic option on a spell when you cast it unless otherwise noted in one of those options.\nWhenever you gain a Sorcerer level, you can replace one of your Metamagic options with one you don’t know. You gain two more options at Sorcerer level 10 and two more at Sorcerer level 17.',
      'Wild Magic Surge':
          'After you cast a Sorcerer spell with a spell slot, the DM can have you roll on the Wild Magic Surge table. Apply the exact result rolled on that table.',
      'Tides of Chaos':
          'You can gain Advantage on one d20 Test. After you use this benefit, you can’t use it again until it is refreshed by the Wild Magic subclass flow, normally when a Wild Magic Surge occurs and the DM restores the feature.',
      'Bend Luck':
          'When another creature you can see makes a d20 Test, you can spend 2 Sorcery Points to roll 1d4 and apply the number rolled as a bonus or penalty to that test, following the timing in the subclass rule.',
      'Controlled Chaos':
          'When you roll on the Wild Magic Surge table, you can roll twice and choose which of the two results applies.',
      'Spell Bombardment':
          'Once per turn, when you roll damage for a spell and roll the highest number on any of the damage dice, choose one of those dice, roll it again, and add that roll to the damage.',
      'Large Form':
          'As a Bonus Action, you can enlarge your body for 10 minutes. While enlarged, your size becomes Large if there is room for the change. Once you use this trait, you can’t use it again until you finish a Long Rest.',
      'Powerful Build':
          'You count as one size larger when determining your carrying capacity and the weight you can push, drag, or lift.',
      'Breath Weapon':
          'You can exhale destructive energy. The shape, saving throw, damage type, and damage scaling are determined by your draconic ancestry and the species feature.',
      'Draconic Flight':
          'At higher levels, you can manifest spectral draconic wings as a Bonus Action and gain a Fly Speed equal to your Speed until the end of your next turn. Once you use this trait, you can’t use it again until you finish a Long Rest.',
      'Psionic Energy Dice':
          'You gain a pool of Psionic Energy Dice that fuel many psion class and subclass features. The class or discipline text explains when a die is spent, rolled, or recovered.',
      'Subtle Telekinesis':
          'You know Mage Hand. You can cast it without Somatic components, and you can make the hand Invisible when you cast it.',
      'Psionic Discipline':
          'You learn psionic discipline options fueled by Psionic Energy Dice. Each discipline describes its trigger, cost, range, and exact mechanical effect.',
      'Psion Subclass':
          'You gain a Psion subclass of your choice. The Metamorph, Psykinetic, and Telepath subclasses are detailed after this class’s description.\nA subclass is a specialization that grants you features at certain Psion levels. For the rest of your career, you gain each of your subclass’s features that are of your Psion level or lower.',
      'Psionic Modes':
          'Psionic Modes are sustained mental stances that alter your offense, defense, movement, or utility according to the mode you activate.',
      'Weapon Mastery':
          'Your training with weapons allows you to use the mastery properties of a set number of Simple or Martial weapons, as defined by your class table. Whenever you finish a Long Rest, you can practice weapon drills and change one of those weapon choices.',
      'Primal Knowledge':
          'You gain proficiency in another skill of your choice from the skill list available to Barbarians at level 1.\nIn addition, while your Rage is active, you can channel primal power when you attempt certain tasks; whenever you make an ability check using one of the following skills, you can make it as a Strength check even if it normally uses a different ability: Acrobatics, Intimidation, Perception, Stealth, or Survival. When you use this ability, your Strength represents primal power coursing through you, honing your agility, bearing, and senses.',
      'Instinctive Pounce':
          'As part of the Bonus Action you take to enter your Rage, you can move up to half your Speed.',
      'Brutal Strike':
          'If you use Reckless Attack, you can forgo any Advantage on one Strength-based attack roll of your choice on your turn. The chosen attack roll mustn\'t have Disadvantage. If the chosen attack roll hits, the target takes an extra 1d10 damage of the same type dealt by the weapon or Unarmed Strike, and you can cause one Brutal Strike effect of your choice.\nForceful Blow. The target is pushed 15 feet straight away from you. You can then move up to half your Speed straight toward the target without provoking Opportunity Attacks.\nHamstring Blow. The target’s Speed is reduced by 15 feet until the start of your next turn. A target can be affected by only one Hamstring Blow at a time— the most recent one.',
      'Improved Brutal Strike':
          'You have honed new ways to attack furiously. The following effects are now among your Brutal Strike options.\nStaggering Blow. The target has Disadvantage on the next saving throw it makes, and it can’t make Opportunity Attacks until the start of your next turn.\nSundering Blow. Before the start of your next turn, the next attack roll made by another creature against the target gains a +5 bonus to the roll. An attack roll can gain only one Sundering Blow bonus',
      'Jack of All Trades':
          'You can add half your Proficiency Bonus (round down) to any ability check you make that uses a skill proficiency you lack and that doesn\'t otherwise use your Proficiency Bonus.\nFor example, if you make a Strength (Athletics) check and lack Athletics proficiency, you can add half your Proficiency Bonus to the check.',
      'Font of Inspiration':
          'You now regain all your expended uses of Bardic Inspiration when you finish a Short or Long Rest.\nIn addition, you can expend a spell slot (no action required) to regain one expended use of Bardic Inspiration.',
      'Countercharm':
          'You can use musical notes or words of power to disrupt mind-influencing effects. If you or a creature within 30 feet of you fails a saving throw against an effect that applies the Charmed or Frightened condition, you can take a Reaction to cause the save to be rerolled, and the new roll has Advantage.',
      'Magical Secrets':
          'You\'ve learned secrets from various magical traditions. Whenever you reach a Bard level (including this level) and the Prepared Spells number in the Bard Features table increases, you can choose any of your new prepared spells from the Bard, Cleric, Druid, and Wizard spell lists, and the chosen spells count as Bard spells for you (see a class’s section for its spell list). In addition, whenever you replace a spell prepared for this class, you can replace it with a spell from those lists.',
      'Superior Inspiration':
          'When you roll Initiative, you regain expended uses of Bardic Inspiration until you have two if you have fewer than that.',
      'Words of Creation':
          'You have mastered two of the Words of Creation: the words of life and death. You therefore always have the Power Word: Heal and Power Word: Kill spells prepared. When you cast either spell, you can target a second creature with it if that creature is within 10 feet of the first target.',
      'Divine Order':
          'Choose Protector or Thaumaturge. Protector grants proficiency with Martial weapons and Heavy armor. Thaumaturge grants one extra Cleric cantrip and adds your Wisdom modifier to Arcana and Religion checks.',
      'Sear Undead':
          'Whenever you use Turn Undead, you can roll a number of d8s equal to your Wisdom modifier (minimum of 1d8) and add the rolls together. Each Undead that fails its saving throw against that use of Turn Undead takes Radiant damage equal to the roll’s total. This damage doesn’t end the turn effect.',
      'Blessed Strikes':
          'Divine power infuses you in battle. You gain one of the following options of your choice (if you get either option from a Cleric subclass in an older book, use only the option you choose for this feature)\nDivine Strike. Once on each of your turns when you hit a creature with an attack roll using a weapon, you can cause the target to take an extra 1d8 Necrotic or Radiant damage (your choice).\nPotent Spellcasting. Add your Wisdom modifier to the damage you deal with any Cleric cantrip.',
      'Improved Blessed Strikes':
          'The option you chose for Blessed Strikes grows more powerful.\nDivine Strike. The extra damage of your Divine Strike increases to 2d8.\nPotent Spellcasting. When you cast a Cleric cantrip and deal damage to a creature with it, you can give vitality to yourself or another creature within 60 feet of yourself, granting a number of Temporary Hit Points equal to twice your Wisdom modifier.',
      'Divine Intervention':
          'You can call on your deity or pantheon to intervene on your behalf. As a Magic action, choose any Cleric spell of level 5 or lower that doesn’t require a Reaction to cast. As part of the same action, you cast that spell without expending a spell slot or needing Material components. You can’t use this feature again until you finish a Long Rest.',
      'Greater Divine Intervention':
          'You can call on even more powerful divine intervention. When you use your Divine Intervention feature, you can choose Wish when you select a spell. If you do so, you can’t use Divine Intervention again until you finish 2d4 Long Rests.',
      'Druidic':
          'You know Druidic, the secret language of Druids. While learning this ancient tongue, you also unlocked the magic of communicating with animals; you always have the Speak with Animals spell prepared.\nYou can use Druidic to leave hidden messages. You and others who know Druidic automatically spot such a message. Others spot the message’s presence with a successful DC 15 Intelligence (Investigation) check but can’t decipher it without magic',
      'Primal Order':
          'You have dedicated yourself to one of the following sacred roles of your choice.\nMagician. You know one extra cantrip from the Druid spell list. In addition, your mystical connection to nature gives you a bonus to your Intelligence (Arcana or Nature) checks. The bonus equals your Wisdom modifier (minimum bonus of +1).\nWarden. Trained for battle, you gain proficiency with Martial weapons and training with Medium armor.',
      'Wild Companion':
          'You can summon a nature spirit that assumes an animal form to aid you. As a Magic action, you can expend a spell slot or a use of Wild Shape to cast the Find Familiar spell without Material components.\nWhen you cast the spell in this way, the familiar is Fey and disappears when you finish a Long Rest.',
      'Wild Resurgence':
          'Once on each of your turns, if you have no uses of Wild Shape left, you can give yourself one use by expending a spell slot (no action required).\nIn addition, you can expend one use of Wild Shape (no action required) to give yourself a level 1 spell slot, but you can’t do so again until you finish a Long Rest.',
      'Elemental Fury':
          'The might of the elements flows through you. You gain one of the following options of your choice.\nPotent Spellcasting. Add your Wisdom modifier to the damage you deal with any Druid cantrip.\nPrimal Strike. Once on each of your turns when you hit a creature with an attack roll using a weapon or a Beast form’s attack in Wild Shape, you can cause the target to take an extra 1d8 Cold, Fire, Lightning, or Thunder damage (choose when you hit).',
      'Improved Elemental Fury':
          'The option you chose for Elemental Fury grows more powerful, as detailed below.\nPotent Spellcasting. When you cast a Druid cantrip with a range of 10 feet or greater, the spell’s range increases by 300 feet.\nPrimal Strike. The extra damage of your Primal Strike increases to 2d8.',
      'Beast Spells':
          'While using Wild Shape, you can cast spells in Beast form, except for any spell that has a Material component with a cost specified or that consumes its Material component.',
      'Archdruid':
          'The vitality of nature constantly blooms within you, granting you the following benefits.\nEvergreen Wild Shape. Whenever you roll Initiative and have no uses of Wild Shape left, you regain one expended use of it.\nNature Magician. You can convert uses of Wild Shape into a spell slot (no action required). Choose a number of your unexpended uses of Wild Shape and convert them into a single spell slot, with each use contributing 2 spell levels. For example, if you convert two uses of Wild Shape, you produce a level 4 spell slot. Once you use this benefit, you can’t do so again until you finish a Long Rest.\nLongevity. The primal magic that you wield causes you to age more slowly. For every ten years that pass, your body ages only one year.',
      'Tactical Mind':
          'You have a mind for tactics on and off the battlefield. When you fail an ability check, you can expend a use of your Second Wind to push yourself toward success. Rather than regaining Hit Points, you roll 1d10 and add the number rolled to the ability check, potentially turning it into a success. If the check still fails, this use of Second Wind isn’t expended.',
      'Tactical Shift':
          'Whenever you activate your Second Wind with a Bonus Action, you can move up to half your Speed without provoking Opportunity Attacks.',
      'Tactical Master':
          'When you attack with a weapon whose mastery property you can use, you can replace that property with the Push, Sap, or Slow property for that attack.',
      'Two Extra Attacks':
          'You can attack three times instead of once whenever you take the Attack action on your turn.',
      'Studied Attacks':
          'You study your opponents and learn from each attack you make. If you make an attack roll against a creature and miss, you have Advantage on your next attack roll against that creature before the end of your next turn.',
      'Three Extra Attacks':
          'You can attack four times instead of once whenever you take the Attack action on your turn.',
      'Monk\'s Focus':
          'Your focus and martial training allow you to harness a well of extraordinary energy within yourself. This energy is represented by Focus Points. Your Monk level determines the number of points you have, as shown in the Focus Points column of the Monk Features table.\nWhen you expend a Focus Point, it is unavailable until you finish a Short or Long Rest, at the end of which you regain all your expended points.\nFlurry of Blows. You can expend 1 Focus Point to make two Unarmed Strikes as a Bonus Action.\nPatient Defense. You can take the Disengage action as a Bonus Action. Alternatively, you can expend 1 Focus Point to take both the Disengage and the Dodge actions as a Bonus Action.\nStep of the Wind. You can take the Dash action as a Bonus Action. Alternatively, you can expend 1 Focus Point to take both the Disengage and Dash actions as a Bonus Action, and your jump distance is doubled for the turn.',
      'Uncanny Metabolism':
          'When you roll Initiative, you can regain all expended Focus Points. When you do so, roll your Martial Arts die, and regain a number of Hit Points equal to your Monk level plus the number rolled.\nOnce you use this feature, you can’t use it again until you finish a Long Rest.',
      'Deflect Attacks':
          'When an attack roll hits you and its damage includes Bludgeoning, Piercing, or Slashing damage, you can take a Reaction to reduce the attack’s total damage against you. The reduction equals 1d10 plus your Dexterity modifier and Monk level.\nIf you reduce the damage to 0, you can expend 1 Focus Point to redirect some of the attack’s force. If you do so, choose a creature you can see within 5 feet of yourself if the attack was a melee attack or a creature you can see within 60 feet of yourself that isn’t behind Total Cover if the attack was a ranged attack. That creature must succeed on a Dexterity saving throw or take damage equal to two rolls of your Martial Arts die plus your Dexterity modifier. The damage is the same type dealt by the attack.',
      'Empowered Strikes':
          'Whenever you deal damage with your Unarmed Strike, it can deal your choice of Force damage or its normal damage type.',
      'Acrobatic Movement':
          'While you aren’t wearing armor or wielding a Shield, you gain the ability to move along vertical surfaces and across liquids on your turn without falling during the movement.',
      'Heightened Focus':
          'Your Flurry of Blows, Patient Defense, and Step of the Wind gain the following benefits.\nFlurry of Blows. You can expend 1 Focus Point to use Flurry of Blows and make three Unarmed Strikes with it instead of two.\nPatient Defense. When you expend a Focus Point to use Patient Defense, you gain a number of Temporary Hit Points equal to two rolls of your Martial Arts die.\nStep of the Wind. When you expend a Focus Point to use Step of the Wind, you can choose a willing creature within 5 feet of yourself that is Large or smaller. You move the creature with you until the end of your turn. The creature’s movement doesn’t provoke Opportunity Attacks.',
      'Self-Restoration':
          'Through sheer force of will, you can remove one of the following conditions from yourself at the end of each of your turns: Charmed, Frightened, or Poisoned.\nIn addition, forgoing food and drink doesn’t give you levels of Exhaustion.',
      'Deflect Energy':
          'You can now use your Deflect Attacks feature against attacks that deal any damage type, not just Bludgeoning, Piercing, or Slashing.',
      'Disciplined Survivor':
          'Your physical and mental discipline grant you proficiency in all saving throws.\nAdditionally, whenever you make a saving throw and fail, you can expend 1 Focus Point to reroll it, and you must use the new roll.',
      'Perfect Focus':
          'When you roll Initiative and don’t use Uncanny Metabolism, you regain expended Focus Points until you have 4 if you have 3 or fewer.',
      'Superior Defense':
          'At the start of your turn, you can expend 3 Focus Points to bolster yourself against harm for 1 minute or until you have the Incapacitated condition. During that time, you have Resistance to all damage except Force damage.',
      'Body and Mind':
          'You have developed your body and mind to new heights. Your Dexterity and Wisdom scores increase by 4, to a maximum of 25.',
      'Lay On Hands':
          'Your blessed touch can heal wounds. You have a pool of healing power that replenishes when you finish a Long Rest. With that pool, you can restore a total number of Hit Points equal to five times your Paladin level.\nAs a Bonus Action, you can touch a creature (which could be yourself) and draw power from the pool of healing to restore a number of Hit Points to that creature, up to the maximum amount remaining in the pool.\nYou can also expend 5 Hit Points from the pool of healing power to remove the Poisoned condition from the creature; those points don\'t also restore Hit Points to the creature.',
      'Paladin’s Smite':
          'You always have the Divine Smite spell prepared.\nYou can cast it without expending a spell slot, but you must finish a Long Rest before you can cast it this way again.',
      'Faithful Steed':
          'You can call on the aid of an otherworldly steed.\nYou always have the Find Steed spell prepared.\nYou can also cast the spell once without expending a spell slot, and you regain your ability to do so when you finish a Long Rest.',
      'Abjure Foes':
          'As a Magic action, you can expend one use of this class\'s Channel Divinity to overwhelm foes with awe. As you present your Holy Symbol or weapon, you can target a number of creatures equal to your Charisma modifier (minimum of one creature) that you can see within 60 feet of yourself. Each target must succeed on a Wisdom saving throw or have the Frightened condition for 1 minute or until it takes any damage. While Frightened in this way, a target can only do one of the following on its turns: move, take an action or take a Bonus Action.',
      'Radiant Strikes':
          'Your strikes now carry supernatural power. When you hit a target with an attack roll using a Melee weapon or an Unarmed Strike, the target takes an extra 1d8 Radiant damage.',
      'Restoring Touch':
          'When you use Lay On Hands on a creature, you can also remove one or more of the following conditions from the creature: Blinded, Charmed, Deafened, Frightened, Paralyzed, or Stunned. You must expend 5 Hit Points from the healing pool of Lay On Hands for each of these conditions you remove; those points don\'t also restore Hit Points to the creature.',
      'Aura Expansion': 'Your Aura of Protection is now a 30-foot Emanation.',
      'Favored Enemy':
          'You always have the Hunter\'s Mark spell prepared.\nYou can cast it twice without expending a spell slot, and you regain all expended uses of this ability when you finish a Long Rest.\nThe number of times you can cast the spell without a spell slot increases when you reach certain Ranger Levels, as shown in the Favored Enemy column of the Ranger Features table.',
      'Deft Explorer':
          'Thanks to your travels, you gain the following benefits.\nExpertise.: Choose one of your skill proficiencies with which you lack Expertise. You gain Expertise in that skill.\nLanguages.: You know two languages of your choice.',
      'Roving':
          'Your speed increases by 10 feet while you aren\'t wearing Heavy Armor. You also have a Climb speed and a Swim Speed equal to your Speed.',
      'Tireless':
          'Primal forces now help fuel you on your journeys, granting you the following benefits.\nTemporary Hit Points. As a Magic Action, you can give yourself a number of Temporary Hit Points equal to 1d8 plus your Wisdom modifier (minimum of 1). You can use this action a number of times equal to your Wisdom modifier (minimum of once), and you regain all expended uses when you finish a Long Rest.\nDecrease Exhaustion. Whenever you finish a Short Rest, your Exhaustion level, if any, decreases by 1.',
      'Relentless Hunter':
          'Taking damage can\'t break your Concentration on Hunter\'s Mark.',
      'Nature’s Veil':
          'You invoke spirits of nature to magically hide yourself. As a Bonus Action you can give yourself the Invisible condition until the end of your next turn.\nYou can use this feature a number of times equal to your Wisdom modifier (minimum of once), and you regain all expended uses when you finish a Long Rest.',
      'Precise Hunter':
          'You have Advantage on attack rolls against the creature currently marked by your Hunter\'s Mark.',
      'Foe Slayer':
          'The damage die of your Hunter\'s Mark is a d10 rather than a d6.',
      'Sneak Attack':
          'You know how to strike subtly and exploit a foe\'s distraction. Once per turn, you can deal an extra 1d6 damage to one creature you hit with an attack roll if you are attacking with a Finesse or Ranged weapon and one of the following requirements is met: you have Advantage on the attack roll, or another enemy of the target is within 5 feet of it, that enemy does not have the Incapacitated condition, and you do not have Disadvantage on the attack roll.\nThe extra damage increases as you gain Rogue levels, as shown in the Sneak Attack column of the Rogue Features table.',
      'Thieves’ Cant':
          'You picked up various languages in the communities where you practiced your roguish talents. You know Thieves\' Cant and one other language of your choice, which you choose from the language tables in the Player\'s Handbook or chapter 2 of this book.',
      'Uncanny Dodge':
          'When an attacker that you can see hits you with an attack roll, you can take a Reaction to halve the attack\'s damage against you.',
      'Evasion':
          'You can nimbly dodge out of the way of certain dangers. When you are subjected to an effect that allows you to make a Dexterity saving throw to take only half damage, you instead take no damage if you succeed on the saving throw and only half damage if you fail. You cannot use this feature if you have the Incapacitated condition.',
      'Elusive':
          'You are so evasive that attackers rarely gain the upper hand against you. No attack roll can have Advantage against you unless you have the Incapacitated condition.',
      'Stroke of Luck':
          'You have a marvelous knack for succeeding when you need to. If you fail a d20 Test, you can turn the roll into a 20. Once you use this feature, you cannot do so again until you finish a Short or Long Rest.',
      'Steady Aim':
          'As a Bonus Action, you give yourself Advantage on your next attack roll on your current turn. You can use this feature only if you have not moved during this turn, and after you use it, your Speed is 0 until the end of the current turn.',
      'Cunning Strike':
          'You\'ve developed cunning ways to use your Sneak Attack. When you deal Sneak Attack damage, you can add one of the following Cunning Strike effects. Each effect has a die cost, which is the number of Sneak Attack dice you must forgo to add the effect. You remove the die before rolling, and the effect occurs immediately after the attack\'s damage is dealt. For example, if you add the Poison effect, remove 1d6 from the Sneak Attack\'s damage before rolling.\nPoison (Cost: 1d6). You add a toxin to your strike, forcing the target to make a Constitution saving throw. On a failed save, the target has the Poisoned condition for 1 minute. At the end of each of its turns, the poisoned target repeats the save, ending the effect on a success.\nTo use this effect, you must have a Poisoner\'s Kit on your person.\nTrip (Cost: 1d6). If the target is Large or smaller, it must succeed on a Dexterity saving throw or have the Prone condition.\nWithdraw (Cost: 1d6). Immediately after the attack, you move up to half your speed without provoking Opportunity Attacks.',
      'Reliable Talent':
          'Whenever you make an ability check that uses one of your skill or tool proficiencies, you can treat a d20 roll of 9 or lower as a 10.',
      'Improved Cunning Strike':
          'You can use up to two Cunning Strike effects when you deal Sneak Attack damage, paying the die cost for each effect.',
      'Devious Strikes':
          'You\'ve practiced new ways to use your Sneak Attack deviously. The following effects are now among your Cunning Strike options.\nDaze (Cost: 2d6). The target must succeed on a Constitution saving throw, or on its next turn, it can do only one of the following: move or take an action or a Bonus Action.\nKnock Out (Cost: 6d6). The target must succeed on a Constitution saving throw, or it has the Unconscious condition for 1 minute or until it takes any damage. The Unconscious target repeats the save at the end of its turns, ending the effect on itself on a success.\nObscure (Cost: 3d6). The target must succeed on a Dexterity saving throw, or it has the Blinded condition until the end of its next turn.',
      'Slippery Mind':
          'Your mind is exceptionally difficult to control. You gain proficiency in Wisdom and Charisma saving throws.',
      'Innate Sorcery':
          'An event in your past left an indelible mark on you, infusing you with simmering magic. As a Bonus Action, you can unleash that magic for 1 minute, during which you gain the following benefits:\nThe spell save DC of your Sorcerer spells increases by 1.\nYou have Advantage on the attack rolls of Sorcerer spells you cast.\nYou can use this feature twice, and you regain all expended uses of it when you finish a Long Rest.',
      'Sorcerous Restoration':
          'When you finish a Short Rest, you can regain expended Sorcery Points, but no more than a number equal to half your Sorcerer level (round down). Once you use this feature, you can’t do so again until you finish a Long Rest.',
      'Sorcery Incarnate':
          'If you have no uses of Innate Sorcery left, you can use it if you spend 2 Sorcery Points when you take the Bonus Action to activate it.\nIn addition, while your Innate Sorcery feature is active, you can use up to two of your Metamagic options on each spell you cast.',
      'Arcane Apotheosis':
          'While your Innate Sorcery feature is active, you can use one Metamagic option on each of your turns without spending Sorcery Points on it.',
      'Pact Magic':
          'You cast Warlock spells using Pact Magic. Your spell slots all share one slot level, refresh on a Short or Long Rest, and scale exactly as shown in the class table.',
      'Eldritch Invocations':
          'You have unearthed Eldritch Invocations, pieces of forbidden knowledge that imbue you with an abiding magical ability or other lessons. You gain one invocation of your choice, such as Pact of the Tome. Invocations are described in the “Eldritch Invocation Options” section later in this class’s description.\nPrerequisites. If an invocation has a prerequisite, you must meet it to learn that invocation. For example, if an invocation requires you to be a level 5+ Warlock, you can select the invocation once you reach Warlock level 5.\nReplacing and Gaining Invocations. Whenever you gain a Warlock level, you can replace one of your invocations with another one for which you qualify. You can’t replace an invocation if it’s a prerequisite for another invocation that you have.\nWhen you gain certain Warlock levels, you gain more invocations of your choice, as shown in the Invocations column of the Warlock Features table.',
      'Magical Cunning':
          'You can perform an esoteric rite for 1 minute. At the end of it, you regain expended Pact Magic spell slots but no more than a number equal to half your maximum (round up). Once you use this feature, you can’t do so again until you finish a Long Rest.',
      'Contact Patron':
          'In the past, you usually contacted your patron through intermediaries. Now you can communicate directly; you always have the Contact Other Plane spell prepared. With this feature, you can cast the spell without expending a spell slot to contact your patron, and you automatically succeed on the spell’s saving throw.\nOnce you cast the spell with this feature, you can’t do so in this way again until you finish a Long Rest.',
      'Mystic Arcanum':
          'Your patron grants you a magical secret called an arcanum. Choose one level 6 Warlock spell as this arcanum.\nYou can cast your arcanum spell once without expending a spell slot, and you must finish a Long Rest before you can cast it in this way again.\nAs shown in the Warlock Features table, you gain another Warlock spell of your choice that can be cast in this way when you reach Warlock levels 13 (level 7 spell), 15 (level 8 spell), and 17 (level 9 spell). You regain all uses of your Mystic Arcanum when you finish a Long Rest.\nWhenever you gain a Warlock level, you can replace one of your arcanum spells with another Warlock spell of the same level.',
      'Eldritch Master':
          'When you use your Magical Cunning feature, you regain all your expended Pact Magic spell slots.',
      'Ritual Adept':
          'You can cast any spell as a Ritual if that spell has the Ritual tag and the spell is in your spellbook. You needn’t have the spell prepared, but you must read from the book to cast a spell in this way.',
      'Scholar':
          'Choose one of the following skills in which you have proficiency: Arcana, History, Investigation, Medicine, Nature, or Religion. You have Expertise in the chosen skill.',
      'Memorize Spell':
          'Whenever you finish a Short Rest, you can study your spellbook and replace one of the level 1+ Wizard spells you have prepared for your Spellcasting feature with another level 1+ spell from the book',
      'Spell Mastery':
          'You have achieved such mastery over certain spells that you can cast them at will. Choose a level 1 and a level 2 spell in your spellbook that have a casting time of an action. You always have those spells prepared, and you can cast them at their lowest level without expending a spell slot. To cast either spell at a higher level, you must expend a spell slot.\nWhenever you finish a Long Rest, you can study your spellbook and replace one of those spells with an eligible spell of the same level from the book.',
      'Signature Spells':
          'Choose two level 3 spells in your spellbook as your signature spells. You always have these spells prepared, and you can cast each of them once at level 3 without expending a spell slot. When you do so, you can\'t cast them in this way again until you finish a Short or Long Rest. To cast either spell at a higher level, you must expend a spell slot.',
      'Barbarian Subclass':
          'At this level, you choose your Barbarian subclass and gain its level 3 features.',
      'Bard Subclass':
          'At this level, you choose your Bard subclass and gain its level 3 features.',
      'Cleric Subclass':
          'At this level, you choose your Cleric subclass and gain its level 3 features.',
      'Druid Subclass':
          'At this level, you choose your Druid subclass and gain its level 3 features.',
      'Fighter Subclass':
          'At this level, you choose your Fighter subclass and gain its level 3 features.',
      'Monk Subclass':
          'At this level, you choose your Monk subclass and gain its level 3 features.',
      'Paladin Subclass':
          'At this level, you choose your Paladin subclass and gain its level 3 features.',
      'Ranger Subclass':
          'At this level, you choose your Ranger subclass and gain its level 3 features.',
      'Rogue Subclass':
          'At this level, you choose your Rogue subclass and gain its level 3 features.',
      'Sorcerer Subclass':
          'At this level, you choose your Sorcerer subclass and gain its level 3 features.',
      'Warlock Subclass':
          'At this level, you choose your Warlock subclass and gain its level 3 features.',
      'Wizard Subclass':
          'At this level, you choose your Wizard subclass and gain its level 3 features.',
      'Subclass Feature':
          'You gain the next feature granted by your chosen subclass at this class level.',
    };

    return exact[name] ??
        'You gain this feature at the listed level. The complete rule text for this feature has not been added to the local catalog yet.';
  }
}
