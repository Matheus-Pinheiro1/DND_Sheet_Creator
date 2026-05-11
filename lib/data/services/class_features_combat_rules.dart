part of 'class_features_service.dart';

extension _ClassFeatureCombatRules on ClassFeaturesService {
  String? _mechanicalEffectFor(String name, {String? className}) {
    if (className == 'barbarian') {
      switch (name) {
        case 'Rage':
          return 'Enter Rage as a Bonus Action if you are not wearing Heavy armor. While raging, you gain Resistance to Bludgeoning, Piercing, and Slashing damage, Advantage on Strength checks and Strength saving throws, and Rage Damage on Strength-based weapon or Unarmed Strike damage rolls.';
        case 'Unarmored Defense':
          return 'While you are not wearing armor, your Armor Class equals 10 plus your Dexterity modifier and Constitution modifier. You can still use a Shield.';
        case 'Weapon Mastery':
          return 'Choose the number of Simple or Martial Melee weapons shown in the Barbarian table. You can use their mastery properties and can change one chosen weapon after a Long Rest.';
        case 'Danger Sense':
          return 'You have Advantage on Dexterity saving throws unless you have the Incapacitated condition.';
        case 'Reckless Attack':
          return 'When you make your first attack roll on your turn, you can gain Advantage on Strength-based attack rolls until the start of your next turn. Attack rolls against you have Advantage during that time.';
        case 'Primal Knowledge':
          return 'Choose one additional skill from the Barbarian skill list. While raging, you can make Acrobatics, Intimidation, Perception, Stealth, and Survival checks as Strength checks.';
        case 'Fast Movement':
          return 'Your Speed increases by 10 feet while you are not wearing Heavy armor.';
        case 'Feral Instinct':
          return 'You have Advantage on Initiative rolls.';
        case 'Instinctive Pounce':
          return 'As part of the Bonus Action you use to enter Rage, you can move up to half your Speed.';
        case 'Brutal Strike':
          return 'When using Reckless Attack, you can forgo Advantage on one eligible Strength-based attack. On a hit, the attack deals an extra 1d10 damage of the same type and applies a Brutal Strike effect.';
        case 'Improved Brutal Strike':
          return 'Your Brutal Strike gains additional effect options and improves again at higher Barbarian levels.';
        case 'Relentless Rage':
          return 'While raging, if you drop to 0 Hit Points and do not die outright, you can try to stay standing. The save DC increases with repeated uses and resets after a rest.';
        case 'Persistent Rage':
          return 'When you roll Initiative, you can regain all expended uses of Rage once per Long Rest. Your Rage also lasts for 10 minutes without needing round-by-round extension.';
        case 'Indomitable Might':
          return 'If your total for a Strength check or Strength saving throw is lower than your Strength score, you can use your Strength score as the total.';
        case 'Primal Champion':
          return 'Your Strength and Constitution scores each increase by 4, to a maximum of 25.';
      }
    }

    if (className == 'rogue' && name == 'Expertise') {
      return 'At Rogue level 1, you choose two of your skill proficiencies to gain Expertise in. At Rogue level 6, you choose two more of your skill proficiencies to gain Expertise in. Expertise doubles your Proficiency Bonus for any ability check you make that uses one of the chosen skill proficiencies.';
    }

    if (className == 'bard') {
      switch (name) {
        case 'Bardic Inspiration':
          return 'As a Bonus Action, give one Bardic Inspiration die to another creature within 60 feet who can see or hear you. Within the next hour, the creature can add the die after failing a D20 Test.';
        case 'Expertise':
          return 'Choose two skill proficiencies at Bard level 2 and two more at level 9. Expertise doubles your Proficiency Bonus for checks using those skills.';
        case 'Jack of All Trades':
          return 'Add half your Proficiency Bonus, rounded down, to skill checks that use a skill proficiency you lack and that do not otherwise use your Proficiency Bonus.';
        case 'Font of Inspiration':
          return 'Your Bardic Inspiration uses refresh on a Short or Long Rest. You can also spend a spell slot with no action to regain one expended Bardic Inspiration use.';
        case 'Countercharm':
          return 'When you or a creature within 30 feet fails a save against Charmed or Frightened, use your Reaction to force a reroll with Advantage.';
        case 'Magical Secrets':
          return 'Your level 1+ Bard spell preparation can draw from the Bard, Cleric, Druid, and Wizard spell lists. Those choices count as Bard spells for you.';
        case 'Superior Inspiration':
          return 'When Initiative is rolled, regain Bardic Inspiration uses until you have two if you currently have fewer than two.';
        case 'Words of Creation':
          return 'Power Word Heal and Power Word Kill are always prepared and do not count against your prepared Bard spells.';
      }
    }

    if (className == 'druid') {
      switch (name) {
        case 'Druidic':
          return 'You know Druidic and always have Speak with Animals prepared. This app adds that spell automatically.';
        case 'Primal Order':
          return 'Magician grants one extra Druid cantrip and adds Wisdom to Arcana and Nature checks. Warden grants Martial weapon and Medium armor proficiency.';
        case 'Wild Shape':
          return 'As a Bonus Action, transform into a known Beast form. Uses and duration scale by Druid level.';
        case 'Wild Companion':
          return 'Cast Find Familiar without Material components by spending a spell slot or a Wild Shape use.';
        case 'Wild Resurgence':
          return 'Recover a Wild Shape use by spending a spell slot when out of uses, or convert one Wild Shape use into a level 1 spell slot once per Long Rest.';
        case 'Elemental Fury':
          return 'Choose Potent Spellcasting for Druid cantrip damage, or Primal Strike for elemental damage on weapon or Wild Shape attacks.';
        case 'Improved Elemental Fury':
          return 'Potent Spellcasting extends eligible Druid cantrip range; Primal Strike damage increases to 2d8.';
        case 'Beast Spells':
          return 'You can cast most spells while in Wild Shape, except spells with costly or consumed Material components.';
        case 'Archdruid':
          return 'Regain Wild Shape when Initiative is rolled if empty, and convert Wild Shape uses into spell slots.';
      }
    }

    if (className == 'sorcerer') {
      switch (name) {
        case 'Innate Sorcery':
          return 'As a Bonus Action, empower your Sorcerer magic for 1 minute. During that time, your Sorcerer spell save DC increases by 1 and your Sorcerer spell attack rolls have Advantage.';
        case 'Font of Magic':
          return 'Track Sorcery Points as a pool equal to your Sorcerer level from level 2 onward. Spend them on Metamagic and temporary spell slots, or convert spell slots into Sorcery Points.';
        case 'Metamagic':
          return 'Choose Metamagic options at Sorcerer levels 2, 10, and 17. Each option modifies a spell you cast and spends Sorcery Points according to the option.';
        case 'Sorcerous Restoration':
          return 'After a Short Rest, regain expended Sorcery Points up to half your Sorcerer level, rounded down. This recovery refreshes on a Long Rest.';
        case 'Sorcery Incarnate':
          return 'If you are out of Innate Sorcery uses, spend 2 Sorcery Points when activating it. While Innate Sorcery is active, you can use up to two Metamagic options on each spell.';
        case 'Arcane Apotheosis':
          return 'While Innate Sorcery is active, one Metamagic option on each of your turns costs no Sorcery Points.';
      }
    }

    if (className == 'warlock') {
      if (name.startsWith('Mystic Arcanum')) {
        return 'Choose one Warlock spell of the listed level. You can cast it once without expending a Pact Magic spell slot, and the use refreshes on a Long Rest.';
      }
      switch (name) {
        case 'Eldritch Invocations':
          return 'Choose the number of Eldritch Invocations shown in the Warlock table. This app records your choices and applies the main automatic spell grants.';
        case 'Pact Magic':
          return 'Warlock spell slots are all the same slot level and refresh on a Short or Long Rest.';
        case 'Magical Cunning':
          return 'Perform a 1-minute rite to regain expended Pact Magic spell slots up to half your maximum, rounded up. This refreshes on a Long Rest.';
        case 'Contact Patron':
          return 'Contact Other Plane is always prepared. You can cast it through this feature once per Long Rest to contact your patron and automatically succeed on the spell save.';
        case 'Eldritch Master':
          return 'When you use Magical Cunning, you regain all expended Pact Magic spell slots.';
      }
    }

    if (className == 'fighter') {
      switch (name) {
        case 'Fighting Style':
          return 'Choose one Fighting Style feat. Whenever you gain a Fighter level, you can replace that choice with another Fighting Style feat.';
        case 'Second Wind':
          return 'As a Bonus Action, regain Hit Points equal to 1d10 plus your Fighter level. You regain one expended use on a Short Rest and all expended uses on a Long Rest.';
        case 'Weapon Mastery':
          return 'Choose the number of Simple or Martial weapons shown in the Fighter table. You can use their mastery properties and can change one chosen weapon after a Long Rest.';
        case 'Action Surge (one use)':
        case 'Action Surge (two uses)':
          return 'On your turn, take one additional action, except the Magic action. At Fighter level 17, you can use this feature twice between rests, but only once on a turn.';
        case 'Tactical Mind':
          return 'When you fail an ability check, expend a Second Wind use to roll 1d10 and add it to the check. If the check still fails, the use is not expended.';
        case 'Tactical Shift':
          return 'When you use Second Wind as a Bonus Action, move up to half your Speed without provoking Opportunity Attacks.';
        case 'Indomitable (one use)':
        case 'Indomitable (two uses)':
        case 'Indomitable (three uses)':
          return 'When you fail a saving throw, reroll it with a bonus equal to your Fighter level. You must use the new roll.';
        case 'Tactical Master':
          return 'When you attack with a weapon whose mastery property you can use, replace that property with Push, Sap, or Slow for that attack.';
        case 'Extra Attack':
          return 'Attack twice instead of once whenever you take the Attack action.';
        case 'Two Extra Attacks':
          return 'Attack three times instead of once whenever you take the Attack action.';
        case 'Studied Attacks':
          return 'If you miss an attack roll against a creature, you have Advantage on your next attack roll against that creature before the end of your next turn.';
        case 'Three Extra Attacks':
          return 'Attack four times instead of once whenever you take the Attack action.';
      }
    }

    if (className == 'monk') {
      switch (name) {
        case 'Unarmored Defense':
          return 'While you aren’t wearing armor or wielding a Shield, your Armor Class equals 10 plus your Dexterity modifier and Wisdom modifier.';
        case 'Martial Arts':
          return 'While you are unarmed or wielding only Monk weapons and aren’t wearing armor or wielding a Shield, you can make an Unarmed Strike as a Bonus Action, you can use your Martial Arts die in place of the normal damage of your Unarmed Strikes and Monk weapons, and you can use Dexterity instead of Strength for the attack rolls, damage rolls, and save DCs of your Unarmed Strike options.';
        case 'Unarmored Movement':
          return 'Your Speed increases while you aren’t wearing armor or wielding a Shield. The bonus is +10 feet at Monk level 2, +15 feet at level 6, +20 feet at level 10, +25 feet at level 14, and +30 feet at level 18.';
        case 'Slow Fall':
          return 'When you fall, you can take a Reaction to reduce the fall damage you take by an amount equal to five times your Monk level.';
        case 'Stunning Strike':
          return 'Once per turn, when you hit a creature with a Monk weapon or an Unarmed Strike, you can expend 1 Focus Point to force the target to make a Constitution saving throw. On a failed save, the target has the Stunned condition until the start of your next turn.';
        case 'Body and Mind':
          return 'Your Dexterity score and Wisdom score each increase by 4, to a maximum of 25.';
      }
    }

    if (className == 'ranger') {
      switch (name) {
        case 'Favored Enemy':
          return "Hunter's Mark is always prepared. You gain limited free castings and they refresh when you finish a Long Rest.";
        case 'Weapon Mastery':
          return 'Choose two Simple or Martial weapons. You can use their mastery properties and can change one chosen weapon after a Long Rest.';
        case 'Deft Explorer':
          return 'Choose one skill proficiency to gain Expertise in, and choose two languages.';
        case 'Fighting Style':
          return 'Choose one Fighting Style feat, or choose Druidic Warrior to learn two Druid cantrips that count as Ranger spells for you.';
        case 'Expertise':
          return 'At Ranger level 9, choose two more skill proficiencies to gain Expertise in.';
        case 'Roving':
          return 'Your Speed increases by 10 feet while you are not wearing Heavy Armor, and you gain Climb and Swim Speeds equal to your Speed.';
        case 'Tireless':
          return 'As a Magic Action, gain Temporary Hit Points equal to 1d8 plus Wisdom modifier, and your Exhaustion decreases by 1 whenever you finish a Short Rest.';
        case 'Relentless Hunter':
          return "Taking damage can no longer break your Concentration on Hunter's Mark.";
        case "Nature's Veil":
        case 'Nature’s Veil':
          return 'As a Bonus Action, become Invisible until the end of your next turn. Uses equal your Wisdom modifier, minimum 1, and refresh on Long Rest.';
        case 'Precise Hunter':
          return "You have Advantage on attack rolls against the target of your Hunter's Mark.";
        case 'Feral Senses':
          return 'You have Blindsight with a range of 30 feet.';
        case 'Foe Slayer':
          return "Your Hunter's Mark damage die becomes a d10 instead of a d6.";
      }
    }

    if (className == 'paladin') {
      switch (name) {
        case 'Lay On Hands':
          return 'You have a healing pool equal to 5 times your Paladin level. As a Bonus Action, spend points to heal a touched creature or spend 5 points to remove Poisoned.';
        case 'Weapon Mastery':
          return 'Choose two Simple or Martial weapons. You can use their mastery properties and can change one chosen weapon after a Long Rest.';
        case 'Fighting Style':
          return 'Choose one Fighting Style. Blessed Warrior lets you learn two Cleric cantrips that count as Paladin spells for you.';
        case "Paladin's Smite":
          return 'Divine Smite is always prepared. You can cast it once without a spell slot, regaining that free casting on a Long Rest.';
        case 'Channel Divinity':
          return 'You gain Channel Divinity with Divine Sense. You have 2 uses, regain 1 use on a Short Rest, and regain all uses on a Long Rest.';
        case 'Faithful Steed':
          return 'Find Steed is always prepared. You can cast it once without a spell slot, regaining that free casting on a Long Rest.';
        case 'Aura of Protection':
          return 'You and allies in your aura add your Charisma modifier, minimum +1, to saving throws.';
        case 'Abjure Foes':
          return 'As a Magic Action, spend Channel Divinity to frighten creatures you can see within 60 feet.';
        case 'Aura of Courage':
          return 'You and allies in your Aura of Protection are immune to the Frightened condition.';
        case 'Radiant Strikes':
          return 'When you hit with a Melee weapon or Unarmed Strike, the target takes an extra 1d8 Radiant damage.';
        case 'Restoring Touch':
          return 'When you use Lay On Hands, you can spend 5 points per condition to remove Blinded, Charmed, Deafened, Frightened, Paralyzed, or Stunned.';
        case 'Aura Expansion':
          return 'Your Aura of Protection expands to a 30-foot Emanation.';
      }
    }

    const map = <String, String>{
      'Rage':
          'Bonus damage on Strength-based melee attacks, Advantage on Strength checks and saves, and resistance to bludgeoning, piercing, and slashing damage while the rage lasts.',
      'Reckless Attack':
          'Grants Advantage on Strength-based melee weapon attacks you make on your turn, but attack rolls against you have Advantage until your next turn.',
      'Danger Sense':
          'Grants Advantage on Dexterity saving throws against effects you can see, unless you are blinded, deafened, or incapacitated.',
      'Turn Undead':
          'Forces undead within 30 feet that can see or hear you to make a Wisdom save or become turned for 1 minute or until they take damage.',
      'Channel Divinity':
          'You can use this class’s Channel Divinity twice. You regain one of its expended uses when you finish a Short Rest, and you regain all expended uses when you finish a Long Rest. You gain additional uses when you reach certain Cleric levels, as shown in the Channel Divinity column of the Cleric Features table.\nIf a Channel Divinity effect requires a saving throw, the DC equals the spell save DC from this class’s Spellcasting feature.\nDivine Spark. As a Magic action, you point your Holy Symbol at another creature you can see within 30 feet of yourself and focus divine energy at it. Roll 1d8 and add your Wisdom modifier. You either restore Hit Points to the creature equal to that total or force the creature to make a Constitution saving throw. On a failed save, the creature takes Necrotic or Radiant damage (your choice) equal to that total. On a successful save, the creature takes half as much damage (round down).\nYou roll an additional d8 when you reach Cleric levels 7 (2d8), 13 (3d8), and 18 (4d8).\nTurn Undead. As a Magic action, you present your Holy Symbol and censure Undead creatures. Each Undead of your choice within 30 feet of you must make a Wisdom saving throw. If the creature fails its save, it has the Frightened and Incapacitated conditions for 1 minute. For that duration, it tries to move as far from you as it can on its turns. This effect ends early on the creature if it takes any damage, if you have the Incapacitated condition, or if you die.',
      'Lay On Hands':
          'Restores Hit Points by touch or removes the Poisoned condition by spending 5 points from the pool.',
      'Divine Sense':
          'Reveals celestials, fiends, and undead nearby until the end of your next turn.',
      'Second Wind': 'Restores 1d10 + your fighter level hit points.',
      'Action Surge': 'Gives one additional action on your turn.',
      'Bardic Inspiration':
          'Gives another creature an inspiration die that can be added to a later d20 Test.',
      'Cunning Action': 'Lets you Dash, Disengage, or Hide as a Bonus Action.',
      'Sneak Attack':
          'Once per turn, when you hit a creature with an attack using a Finesse or Ranged weapon and either have Advantage on the attack roll or meet the Rogue ally requirement, you can deal the extra damage shown in the Rogue Features table.',
      'Thieves’ Cant':
          'You know the rogues\' secret language and coded signs known as Thieves’ Cant.',
      'Steady Aim':
          'As a Bonus Action, you can give yourself Advantage on your next attack roll on the current turn. You can use this feature only if you have not moved during the turn, and after you use it, your Speed becomes 0 until the end of the turn.',
      'Cunning Strike':
          'When you deal Sneak Attack damage, you can forgo Sneak Attack dice to apply one of the listed Cunning Strike effects.',
      'Uncanny Dodge':
          'When an attacker you can see hits you with an attack roll, you can take a Reaction to halve the attack’s damage against you.',
      'Reliable Talent':
          'Whenever you make an ability check that uses one of your skill or tool proficiencies, a d20 roll of 9 or lower counts as a 10.',
      'Evasion':
          'When you are subjected to an effect that lets you make a Dexterity saving throw to take only half damage, you take no damage on a success and only half damage on a failure.',
      'Improved Cunning Strike':
          'When you deal Sneak Attack damage, you can apply more than one Cunning Strike effect at the same time, paying the die cost for each one.',
      'Devious Strikes':
          'You gain the Daze, Knock Out, and Obscure options for use with Cunning Strike.',
      'Elusive':
          'No attack roll can have Advantage against you unless you have the Incapacitated condition.',
      'Stroke of Luck':
          'If you miss with an attack roll, you can turn the miss into a hit. If you fail an ability check, you can treat the d20 roll as a 20.',
      'Wild Shape':
          'The power of nature allows you to assume the form of an animal. As a Bonus Action, you shape-shift into a Beast form that you have learned for this feature (see “Known Forms” below). You stay in that form for a number of hours equal to half your Druid level or until you use Wild Shape again, have the Incapacitated condition, or die. You can also leave the form early as a Bonus Action.\nNumber of Uses. You can use Wild Shape twice. You regain one expended use when you finish a Short Rest, and you regain all expended uses when you finish a Long Rest.\nKnown Forms. You know four Beast forms for this feature, chosen from among Beast stat blocks that have a maximum Challenge Rating of 1/4 and that lack a Fly Speed (see appendix B for stat block options). The Rat, Riding Horse, Spider, and Wolf are recommended. Whenever you finish a Long Rest, you can replace one of your known forms with another eligible form.\nWhen you reach certain Druid levels, your number of known forms and the maximum Challenge Rating for those forms increases, as shown in the Beast Shapes table. In addition, starting at level 8, you can adopt a form that has a Fly Speed.',
      'Extra Attack':
          'You can make two attacks instead of one when you take the Attack action.',
      'Extra Attack (2)':
          'You can make three attacks when you take the Attack action.',
      'Extra Attack (3)':
          'You can make four attacks when you take the Attack action.',
      'Arcane Recovery':
          'Recovers expended spell slots with a combined level up to half your wizard level, rounded up, with the normal level restriction.',
      'Divine Smite':
          'Adds radiant damage to a melee weapon hit by expending a spell slot.',
      'Tides of Chaos':
          'Gives Advantage on one d20 Test, then becomes unavailable until a Wild Magic Surge refreshes it.',
      'Wild Magic Surge':
          'When it triggers, you roll on the Wild Magic Surge table and apply the listed magical result.',
      'Bend Luck':
          'Adds or subtracts 1d4 from another creature\'s d20 Test after the roll but before the outcome is finalized.',
      'Controlled Chaos':
          'Lets you roll twice on the Wild Magic Surge table and choose which result applies.',
      'Spell Bombardment':
          'When you roll the highest number on a damage die for a spell, you roll one of those dice again and add it once per turn.',
      'Large Form':
          'Your size becomes Large for 10 minutes if there is room for the change.',
      'Powerful Build':
          'You count as one size larger when determining carrying capacity and the weight you can push, drag, or lift.',
      'Breath Weapon':
          'You exhale damaging energy in the area and damage type granted by your draconic ancestry.',
      'Draconic Flight':
          'You gain a Fly Speed equal to your Speed until the end of your next turn.',
      'Psionic Energy Dice':
          'Creates the expendable dice pool used by psionic features and disciplines.',
      'Psionic Discipline':
          'Grants the discipline options available to your class level and subclass.',
      'Subtle Telekinesis':
          'Gives you Mage Hand with improved control and Invisible casting options.',
      'Metamagic':
          'Lets you modify sorcerer spells by spending Sorcery Points on the Metamagic options you know.',
      'Innate Sorcery':
          'Enhances your sorcerer spell presence during the active window defined by the feature.',
      'Magical Cunning':
          'Restores part of your warlock spellcasting endurance after a brief reset period.',
      'Frenzy':
          'While raging, if you use Reckless Attack, the first target you hit on your turn with a Strength-based attack takes extra damage based on your Rage Damage bonus.',
      'Mindless Rage':
          'While Rage is active, you are immune to Charmed and Frightened, and those conditions end when you enter Rage.',
      'Retaliation':
          'When a creature within 5 feet damages you, you can use your Reaction to make one melee attack against it.',
      'Intimidating Presence':
          'As a Bonus Action, creatures of your choice in a 30-foot Emanation make a Wisdom save or become Frightened.',
      'Rage of the Wilds':
          'When you activate Rage, choose Bear, Eagle, or Wolf for a temporary animal-spirit benefit.',
      'Aspect of the Wilds':
          'Choose Owl, Panther, or Salmon for a persistent movement or sense benefit, changing after a Long Rest.',
      'Power of the Wilds':
          'When you activate Rage, choose Falcon, Lion, or Ram for a stronger animal-spirit benefit.',
      'Vitality of the Tree':
          'When Rage starts, you gain Temporary Hit Points and can grant Temporary Hit Points to another nearby creature each turn.',
      'Branches of the Tree':
          'While raging, use a Reaction to pull or reposition a creature near you with spectral branches.',
      'Battering Roots':
          'Heavy or Versatile melee weapons gain extra reach and can apply Push or Topple with another mastery.',
      'Travel Along the Tree':
          'Teleport when Rage starts and as a Bonus Action while raging, with a larger once-per-Rage group teleport.',
      'Divine Fury':
          'Once on each turn while raging, your first hit deals extra Necrotic or Radiant damage.',
      'Warrior of the Gods':
          'Spend d12s from a healing pool as a Bonus Action to regain Hit Points.',
      'Fanatical Focus':
          'Once per active Rage, reroll a failed saving throw with a bonus equal to your Rage Damage bonus.',
      'Zealous Presence':
          'As a Bonus Action, give up to ten nearby allies Advantage on attack rolls and saving throws until your next turn.',
      'Rage of the Gods':
          'When Rage starts, assume a divine form with flight, key resistances, and a reaction that can keep an ally from dropping to 0 Hit Points.',
    };
    return map[name];
  }

  bool _showInCombat(String name, {String? className}) {
    final lower = name.toLowerCase();
    if (className == 'barbarian') {
      return lower == 'rage' ||
          lower == 'reckless attack' ||
          lower == 'danger sense' ||
          lower == 'instinctive pounce' ||
          lower == 'brutal strike' ||
          lower == 'improved brutal strike' ||
          lower == 'relentless rage' ||
          lower == 'persistent rage' ||
          lower == 'indomitable might';
    }
    if (className == 'fighter') {
      return lower == 'second wind' ||
          lower.contains('action surge') ||
          lower == 'tactical mind' ||
          lower == 'tactical shift' ||
          lower.contains('indomitable') ||
          lower == 'tactical master' ||
          lower == 'studied attacks';
    }
    if (className == 'ranger') {
      return lower == 'favored enemy' ||
          lower == 'tireless' ||
          lower == 'nature\'s veil' ||
          lower == 'nature’s veil' ||
          lower == 'precise hunter' ||
          lower == 'foe slayer';
    }
    if (className == 'paladin') {
      return lower == 'lay on hands' ||
          lower == "paladin's smite" ||
          lower == 'channel divinity' ||
          lower == 'aura of protection' ||
          lower == 'abjure foes' ||
          lower == 'aura of courage' ||
          lower == 'radiant strikes' ||
          lower == 'restoring touch';
    }
    if (className == 'bard') {
      return lower == 'bardic inspiration' ||
          lower == 'countercharm' ||
          lower == 'font of inspiration' ||
          lower == 'superior inspiration' ||
          lower == 'words of creation';
    }
    if (className == 'druid') {
      return lower == 'wild shape' ||
          lower == 'wild companion' ||
          lower == 'wild resurgence' ||
          lower == 'elemental fury' ||
          lower == 'improved elemental fury' ||
          lower == 'beast spells' ||
          lower == 'archdruid';
    }
    if (className == 'sorcerer') {
      return lower == 'innate sorcery' ||
          lower == 'font of magic' ||
          lower == 'metamagic' ||
          lower == 'sorcery incarnate' ||
          lower == 'arcane apotheosis';
    }
    if (className == 'warlock') {
      return lower == 'eldritch invocations' ||
          lower == 'magical cunning' ||
          lower == 'contact patron' ||
          lower.startsWith('mystic arcanum') ||
          lower == 'eldritch master';
    }
    return lower == 'rage' ||
        lower == 'reckless attack' ||
        lower.contains('turn undead') ||
        lower.contains('channel divinity') ||
        lower == 'lay on hands' ||
        lower == 'divine sense' ||
        lower == 'wild shape' ||
        lower == 'bardic inspiration' ||
        lower == 'second wind' ||
        lower == 'martial arts' ||
        lower.contains('monk\'s focus') ||
        lower == 'slow fall' ||
        lower == 'stunning strike' ||
        lower == 'deflect attacks' ||
        lower == 'deflect energy' ||
        lower == 'superior defense' ||
        lower.contains('action surge') ||
        lower.contains('cunning action') ||
        lower.contains('psionic energy') ||
        lower.contains('subtle telekinesis') ||
        lower.contains('psionic discipline') ||
        lower.contains('metamagic') ||
        lower.contains('breath weapon') ||
        lower.contains('large form') ||
        lower.contains('draconic flight') ||
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
        lower == 'peerless skill';
  }

  String? _summaryFor(String name, {String? className}) {
    if (className == 'barbarian') {
      switch (name) {
        case 'Rage':
          return 'Enter Rage for Strength-based offense, key resistances, and Strength Advantage.';
        case 'Unarmored Defense':
          return 'Use 10 + DEX + CON for Armor Class while unarmored.';
        case 'Weapon Mastery':
          return 'Choose melee weapons and use their mastery properties.';
        case 'Danger Sense':
          return 'Gain Advantage on Dexterity saving throws while not Incapacitated.';
        case 'Reckless Attack':
          return 'Gain Advantage on Strength attacks, but enemies gain Advantage against you.';
        case 'Primal Knowledge':
          return 'Gain one extra Barbarian skill and use Strength for some checks while raging.';
        case 'Fast Movement':
          return 'Gain +10 Speed while not wearing Heavy armor.';
        case 'Feral Instinct':
          return 'Gain Advantage on Initiative rolls.';
        case 'Instinctive Pounce':
          return 'Move up to half your Speed when you enter Rage.';
        case 'Brutal Strike':
          return 'Trade Reckless Advantage for extra damage and a rider effect.';
        case 'Improved Brutal Strike':
          return 'Gain stronger Brutal Strike options.';
        case 'Relentless Rage':
          return 'While raging, try to avoid dropping to 0 Hit Points.';
        case 'Persistent Rage':
          return 'Regain expended Rage uses once per Long Rest when Initiative is rolled, and Rage lasts 10 minutes.';
        case 'Indomitable Might':
          return 'Use your Strength score as a floor for Strength checks and saves.';
        case 'Primal Champion':
          return 'Increase Strength and Constitution by 4, up to 25.';
      }
    }

    if (className == 'rogue' && name == 'Expertise') {
      return 'Double your Proficiency Bonus with chosen Rogue skill proficiencies.';
    }

    if (className == 'bard') {
      switch (name) {
        case 'Bardic Inspiration':
          return 'Give another creature a scaling die after a failed D20 Test.';
        case 'Expertise':
          return 'Double your Proficiency Bonus with chosen Bard skill proficiencies.';
        case 'Jack of All Trades':
          return 'Add half Proficiency Bonus to non-proficient skill checks.';
        case 'Font of Inspiration':
          return 'Refresh Bardic Inspiration on Short Rests and recover uses with spell slots.';
        case 'Countercharm':
          return 'Use a Reaction to help reroll a failed charm or fear save.';
        case 'Magical Secrets':
          return 'Prepare level 1+ Bard spells from Bard, Cleric, Druid, and Wizard lists.';
        case 'Superior Inspiration':
          return 'Regain Bardic Inspiration uses when Initiative is rolled.';
        case 'Words of Creation':
          return 'Always prepare Power Word Heal and Power Word Kill.';
      }
    }

    if (className == 'druid') {
      switch (name) {
        case 'Druidic':
          return 'Know Druidic and always prepare Speak with Animals.';
        case 'Primal Order':
          return 'Choose Magician for extra magic or Warden for martial training.';
        case 'Wild Shape':
          return 'Transform into a known Beast form as a Bonus Action.';
        case 'Wild Companion':
          return 'Cast Find Familiar using a spell slot or Wild Shape use.';
        case 'Wild Resurgence':
          return 'Trade spell slots and Wild Shape uses in limited ways.';
        case 'Elemental Fury':
          return 'Choose cantrip damage or elemental strike support.';
        case 'Improved Elemental Fury':
          return 'Improve the Elemental Fury option you chose.';
        case 'Beast Spells':
          return 'Cast most spells while in Wild Shape.';
        case 'Archdruid':
          return 'Recover and convert Wild Shape uses more freely.';
      }
    }

    if (className == 'sorcerer') {
      switch (name) {
        case 'Innate Sorcery':
          return 'Briefly empower Sorcerer spell DCs and spell attacks.';
        case 'Font of Magic':
          return 'Use Sorcery Points for Metamagic and temporary spell slots.';
        case 'Metamagic':
          return 'Choose spell-modifying options that spend Sorcery Points.';
        case 'Sorcerous Restoration':
          return 'Recover some Sorcery Points after a Short Rest.';
        case 'Sorcery Incarnate':
          return 'Keep Innate Sorcery available and combine more Metamagic.';
        case 'Arcane Apotheosis':
          return 'Use one Metamagic option each turn for free while Innate Sorcery is active.';
      }
    }

    if (className == 'warlock') {
      if (name.startsWith('Mystic Arcanum')) {
        return 'Cast a chosen high-level Warlock spell once per Long Rest.';
      }
      switch (name) {
        case 'Eldritch Invocations':
          return 'Choose occult powers, pact boons, and at-will spell benefits.';
        case 'Pact Magic':
          return 'Cast Warlock spells with short-rest Pact Magic slots.';
        case 'Magical Cunning':
          return 'Recover some Pact Magic slots after a 1-minute rite.';
        case 'Contact Patron':
          return 'Always prepare Contact Other Plane and cast it safely once per Long Rest.';
        case 'Eldritch Master':
          return 'Magical Cunning restores every expended Pact Magic slot.';
      }
    }

    if (className == 'fighter') {
      switch (name) {
        case 'Fighting Style':
          return 'Choose one Fighting Style feat.';
        case 'Second Wind':
          return 'Heal yourself as a Bonus Action using a scaling pool of uses.';
        case 'Weapon Mastery':
          return 'Choose weapons and use their mastery properties.';
        case 'Action Surge (one use)':
        case 'Action Surge (two uses)':
          return 'Gain one additional non-Magic action on your turn.';
        case 'Tactical Mind':
          return 'Spend Second Wind to add 1d10 to a failed ability check.';
        case 'Tactical Shift':
          return 'Move up to half your Speed when you use Second Wind.';
        case 'Indomitable (one use)':
        case 'Indomitable (two uses)':
        case 'Indomitable (three uses)':
          return 'Reroll a failed saving throw with a Fighter level bonus.';
        case 'Tactical Master':
          return 'Swap an eligible weapon mastery property for Push, Sap, or Slow.';
        case 'Extra Attack':
          return 'Attack twice with the Attack action.';
        case 'Two Extra Attacks':
          return 'Attack three times with the Attack action.';
        case 'Studied Attacks':
          return 'Gain Advantage on your next attack against a creature you missed.';
        case 'Three Extra Attacks':
          return 'Attack four times with the Attack action.';
      }
    }

    if (className == 'monk') {
      switch (name) {
        case 'Unarmored Defense':
          return 'Use 10 + DEX + WIS for Armor Class while unarmored and without a Shield.';
        case 'Martial Arts':
          return 'Unlock a bonus Unarmed Strike, Martial Arts damage die, and Dexterity-based Monk attacks.';
        case 'Unarmored Movement':
          return 'Gain extra Speed while unarmored and not using a Shield.';
        case 'Slow Fall':
          return 'Use your Reaction to reduce fall damage.';
        case 'Stunning Strike':
          return 'Spend 1 Focus Point after a hit to try to Stun the target.';
        case 'Body and Mind':
          return 'Increase Dexterity and Wisdom by 4, up to 25.';
      }
    }

    if (className == 'ranger') {
      switch (name) {
        case 'Favored Enemy':
          return "Always prepare Hunter's Mark and gain free castings.";
        case 'Weapon Mastery':
          return 'Choose two weapons and use their mastery properties.';
        case 'Deft Explorer':
          return 'Gain one Expertise choice and two languages.';
        case 'Fighting Style':
          return 'Choose a Fighting Style or Druidic Warrior.';
        case 'Expertise':
          return 'Choose two more Ranger Expertise skills.';
        case 'Roving':
          return 'Gain +10 Speed, plus Climb and Swim Speeds, without Heavy Armor.';
        case 'Tireless':
          return 'Gain temporary HP with a Magic Action and reduce Exhaustion on Short Rests.';
        case 'Relentless Hunter':
          return "Damage cannot break your Hunter's Mark Concentration.";
        case "Nature's Veil":
        case 'Nature’s Veil':
          return 'Become Invisible as a Bonus Action until the end of your next turn.';
        case 'Precise Hunter':
          return "Gain Advantage against your Hunter's Mark target.";
        case 'Feral Senses':
          return 'Gain Blindsight out to 30 feet.';
        case 'Foe Slayer':
          return "Hunter's Mark uses a d10 damage die.";
      }
    }

    if (className == 'paladin') {
      switch (name) {
        case 'Lay On Hands':
          return 'Use a healing pool equal to 5 times your Paladin level.';
        case 'Weapon Mastery':
          return 'Choose two weapons and use their mastery properties.';
        case 'Fighting Style':
          return 'Choose a Fighting Style or Blessed Warrior.';
        case "Paladin's Smite":
          return 'Always prepare Divine Smite and gain one free casting.';
        case 'Channel Divinity':
          return 'Gain Divine Sense and Channel Divinity uses.';
        case 'Faithful Steed':
          return 'Always prepare Find Steed and gain one free casting.';
        case 'Aura of Protection':
          return 'Add your Charisma modifier to your saving throws.';
        case 'Abjure Foes':
          return 'Spend Channel Divinity to frighten nearby foes.';
        case 'Aura of Courage':
          return 'Prevent Frightened inside your Aura of Protection.';
        case 'Radiant Strikes':
          return 'Add 1d8 Radiant damage to melee weapon hits.';
        case 'Restoring Touch':
          return 'Spend Lay On Hands points to remove major conditions.';
        case 'Aura Expansion':
          return 'Expand your aura to 30 feet.';
      }
    }

    const map = <String, String>{
      'Rage':
          'Enter a rage to boost Strength-based melee offense and gain weapon-damage resistance.',
      'Reckless Attack':
          'Trade defense for Advantage on Strength-based melee attacks.',
      'Turn Undead':
          'Force nearby undead to flee unless they succeed on a Wisdom save.',
      'Channel Divinity': 'Spend Channel Divinity to activate a divine option.',
      'Lay On Hands':
          'Spend points from a healing pool to restore HP or remove the Poisoned condition.',
      'Divine Sense': 'Reveal celestials, fiends, and undead nearby.',
      'Second Wind': 'Heal yourself as a Bonus Action.',
      'Wild Shape': 'Transform into a beast under Wild Shape limits.',
      'Bardic Inspiration': 'Give another creature an inspiration die.',
      'Bonus Proficiencies': 'Gain three College of Lore skill proficiencies.',
      'Cutting Words':
          'Subtract a Bardic Inspiration die from a nearby creature\'s successful roll or damage roll.',
      'Magical Discoveries':
          'Choose two Cleric, Druid, or Wizard spells that count as Bard spells.',
      'Peerless Skill':
          'Add a Bardic Inspiration die after failing an ability check or attack roll.',
      'Cunning Action': 'Dash, Disengage, or Hide as a Bonus Action.',
      'Sneak Attack':
          'Deal extra damage once per turn when your Sneak Attack conditions are met.',
      'Thieves’ Cant':
          'Know the secret language and coded messages used by rogues.',
      'Steady Aim':
          'Stand still to gain Advantage on your next attack roll this turn.',
      'Cunning Strike': 'Trade Sneak Attack dice for rider effects.',
      'Uncanny Dodge':
          'Use your Reaction to halve damage from an attack that hits you.',
      'Reliable Talent': 'Treat low rolls on proficient checks as 10s.',
      'Evasion':
          'Take no damage on a successful Dexterity save for half damage effects.',
      'Improved Cunning Strike':
          'Combine more than one Cunning Strike option at once.',
      'Devious Strikes': 'Gain stronger control effects for Cunning Strike.',
      'Elusive':
          'No attack roll can have Advantage against you unless you have the Incapacitated condition.',
      'Stroke of Luck': 'Turn a miss into a hit or a failed check into a 20.',
      'Action Surge': 'Gain one extra action on your turn.',
      'Tides of Chaos':
          'Gain Advantage on one d20 Test until the feature is refreshed.',
      'Large Form': 'Become Large for a limited duration.',
      'Draconic Flight': 'Gain temporary flight.',
      'Breath Weapon': 'Exhale your ancestry\'s damaging energy.',
      'Frenzy': 'Add extra damage to the first Reckless hit while raging.',
      'Mindless Rage': 'Stay immune to Charmed and Frightened while raging.',
      'Retaliation':
          'Strike back with a Reaction when a nearby creature hurts you.',
      'Intimidating Presence': 'Frighten nearby enemies with a Bonus Action.',
      'Animal Speaker': 'Cast Beast Sense and Speak with Animals as rituals.',
      'Rage of the Wilds': 'Choose Bear, Eagle, or Wolf whenever Rage starts.',
      'Aspect of the Wilds':
          'Choose a lasting Owl, Panther, or Salmon benefit.',
      'Nature Speaker': 'Cast Commune with Nature as a ritual.',
      'Power of the Wilds': 'Choose Falcon, Lion, or Ram whenever Rage starts.',
      'Vitality of the Tree':
          'Gain and grant Temporary Hit Points while raging.',
      'Branches of the Tree': 'Use a Reaction to pull and hinder a creature.',
      'Battering Roots': 'Extend reach and stack Push or Topple with mastery.',
      'Travel Along the Tree':
          'Teleport yourself, and sometimes allies, while raging.',
      'Divine Fury':
          'Add Necrotic or Radiant damage to your first hit while raging.',
      'Warrior of the Gods':
          'Spend a d12 pool to heal yourself as a Bonus Action.',
      'Fanatical Focus': 'Reroll one failed save during each Rage.',
      'Zealous Presence': 'Give nearby allies Advantage for a decisive moment.',
      'Rage of the Gods':
          'Assume a divine form with flight, resistances, and rescue power.',
    };
    return map[name];
  }
}
