part of 'class_features_service.dart';

extension _ClassFeatureActionRules on ClassFeaturesService {
  String? _actionTypeFor(String name, {String? className}) {
    if (className == 'barbarian') {
      switch (name) {
        case 'Rage':
          return 'Bonus Action';
        case 'Instinctive Pounce':
          return 'Part of Rage Bonus Action';
        case 'Reckless Attack':
        case 'Brutal Strike':
          return 'No Action';
        case 'Unarmored Defense':
        case 'Weapon Mastery':
        case 'Danger Sense':
        case 'Primal Knowledge':
        case 'Fast Movement':
        case 'Feral Instinct':
        case 'Relentless Rage':
        case 'Persistent Rage':
        case 'Indomitable Might':
        case 'Primal Champion':
        case 'Improved Brutal Strike':
          return 'Passive';
      }
    }

    if (className == 'fighter') {
      switch (name) {
        case 'Second Wind':
          return 'Bonus Action';
        case 'Action Surge (one use)':
        case 'Action Surge (two uses)':
        case 'Tactical Mind':
        case 'Indomitable (one use)':
        case 'Indomitable (two uses)':
        case 'Indomitable (three uses)':
        case 'Tactical Master':
          return 'No Action';
        case 'Tactical Shift':
          return 'Part of Second Wind Bonus Action';
        case 'Fighting Style':
        case 'Weapon Mastery':
        case 'Extra Attack':
        case 'Two Extra Attacks':
        case 'Studied Attacks':
        case 'Three Extra Attacks':
          return 'Passive';
      }
    }

    if (className == 'ranger') {
      switch (name) {
        case 'Favored Enemy':
        case 'Weapon Mastery':
        case 'Deft Explorer':
        case 'Fighting Style':
        case 'Roving':
        case 'Expertise':
        case 'Relentless Hunter':
        case 'Precise Hunter':
        case 'Feral Senses':
        case 'Foe Slayer':
          return 'Passive';
        case 'Tireless':
          return 'Magic Action / Passive';
        case 'Nature\'s Veil':
        case 'Nature’s Veil':
          return 'Bonus Action';
      }
    }

    if (className == 'paladin') {
      switch (name) {
        case 'Lay On Hands':
        case "Paladin's Smite":
          return 'Bonus Action';
        case 'Channel Divinity':
          return 'Bonus Action / Magic Action';
        case 'Abjure Foes':
          return 'Magic Action';
        case 'Restoring Touch':
          return 'Bonus Action';
        case 'Spellcasting':
        case 'Weapon Mastery':
        case 'Fighting Style':
        case 'Faithful Steed':
        case 'Aura of Protection':
        case 'Aura of Courage':
        case 'Radiant Strikes':
        case 'Aura Expansion':
          return 'Passive';
      }
    }

    if (className == 'bard') {
      switch (name) {
        case 'Bardic Inspiration':
          return 'Bonus Action';
        case 'Countercharm':
          return 'Reaction';
        case 'Spellcasting':
        case 'Expertise':
        case 'Jack of All Trades':
        case 'Font of Inspiration':
        case 'Magical Secrets':
        case 'Superior Inspiration':
        case 'Words of Creation':
          return 'Passive';
      }
    }

    if (className == 'druid') {
      switch (name) {
        case 'Wild Shape':
          return 'Bonus Action';
        case 'Wild Companion':
          return 'Magic Action';
        case 'Wild Resurgence':
        case 'Elemental Fury':
        case 'Archdruid':
          return 'No Action / Passive';
        case 'Spellcasting':
        case 'Druidic':
        case 'Primal Order':
        case 'Improved Elemental Fury':
        case 'Beast Spells':
          return 'Passive';
      }
    }

    if (className == 'sorcerer') {
      switch (name) {
        case 'Innate Sorcery':
          return 'Bonus Action';
        case 'Font of Magic':
          return 'Bonus Action / No Action';
        case 'Metamagic':
          return 'Part of Spell';
        case 'Sorcerous Restoration':
          return 'Short Rest';
        case 'Sorcery Incarnate':
          return 'Bonus Action / Passive';
        case 'Spellcasting':
        case 'Sorcerer Subclass':
        case 'Arcane Apotheosis':
          return 'Passive';
      }
    }

    if (className == 'warlock') {
      if (name.startsWith('Mystic Arcanum')) {
        return 'Magic Action';
      }
      switch (name) {
        case 'Eldritch Invocations':
        case 'Pact Magic':
        case 'Warlock Subclass':
        case 'Eldritch Master':
          return 'Passive';
        case 'Magical Cunning':
          return '1 Minute Rite';
        case 'Contact Patron':
          return 'Magic Action';
      }
    }

    const map = <String, String>{
      'Rage': 'Bonus Action',
      'Wild Shape': 'Action',
      'Divine Sense': 'Action',
      'Lay On Hands': 'Bonus Action',
      'Second Wind': 'Bonus Action',
      'Turn Undead': 'Action',
      'Channel Divinity': 'Action',
      'Bardic Inspiration': 'Bonus Action',
      'Bonus Proficiencies': 'Passive',
      'Cutting Words': 'Reaction',
      'Magical Discoveries': 'Passive',
      'Peerless Skill': 'No Action',
      'Cunning Action': 'Bonus Action',
      'Martial Arts': 'Passive',
      'Monk\'s Focus': 'Bonus Action / Passive',
      'Unarmored Defense': 'Passive',
      'Unarmored Movement': 'Passive',
      'Slow Fall': 'Reaction',
      'Stunning Strike': 'No Action',
      'Steady Aim': 'Bonus Action',
      'Uncanny Dodge': 'Reaction',
      'Action Surge': 'No Action',
      'Tides of Chaos': 'No Action',
      'Bend Luck': 'Reaction',
      'Large Form': 'Bonus Action',
      'Breath Weapon': 'Action',
      'Draconic Flight': 'Bonus Action',
      'Powerful Build': 'Passive',
      'Mage Hand Legerdemain': 'Bonus Action',
      'Magical Ambush': 'Passive',
      'Versatile Trickster': 'Part of Cunning Strike',
      'Spell Thief': 'Reaction',
      'Assassinate': 'Passive',
      'Assassin\'s Tools': 'Passive',
      'Envenom Weapons': 'Part of Cunning Strike',
      'Death Strike': 'No Action',
      'Psychic Blades': 'Attack / Bonus Action',
      'Psionic Power': 'Magic Action / No Action',
      'Soul Blades': 'Bonus Action / No Action',
      'Psychic Veil': 'Magic Action',
      'Rend Mind': 'No Action',
      'Fast Hands': 'Bonus Action',
      'Second-Story Work': 'Passive',
      'Thief\'s Reflexes': 'Passive',
      'Bloodthirst': 'Reaction',
      'Dread Allegiance': 'Passive',
      'Combat Superiority': 'Part of Attack',
      'Student of War': 'Passive',
      'Know Your Enemy': 'Bonus Action',
      'Improved Combat Superiority': 'Passive',
      'Relentless': 'No Action',
      'Ultimate Combatant': 'Passive',
      'War Bond': 'Bonus Action / Ritual',
      'War Magic': 'Part of Attack Action',
      'Eldritch Strike': 'No Action',
      'Arcane Charge': 'Part of Action Surge',
      'Improved War Magic': 'Part of Attack Action',
      'Telekinetic Adept': 'Bonus Action / No Action',
      'Guarded Mind': 'Passive / No Action',
      'Bulwark of Force': 'Bonus Action',
      'Telekinetic Master': 'Magic Action',
      'Frenzy': 'No Action',
      'Mindless Rage': 'Passive',
      'Retaliation': 'Reaction',
      'Intimidating Presence': 'Bonus Action',
      'Animal Speaker': 'Ritual',
      'Rage of the Wilds': 'Part of Rage Bonus Action',
      'Aspect of the Wilds': 'Passive',
      'Nature Speaker': 'Ritual',
      'Power of the Wilds': 'Part of Rage',
      'Vitality of the Tree': 'Part of Rage / No Action',
      'Branches of the Tree': 'Reaction',
      'Battering Roots': 'Passive / No Action',
      'Travel Along the Tree': 'Bonus Action / Part of Rage',
      'Divine Fury': 'No Action',
      'Warrior of the Gods': 'Bonus Action',
      'Fanatical Focus': 'No Action',
      'Zealous Presence': 'Bonus Action',
      'Rage of the Gods': 'Part of Rage / Reaction',
    };
    return map[name];
  }

  String? _usageFor(String name, {String? className}) {
    if (className == 'barbarian') {
      switch (name) {
        case 'Rage':
          return 'Uses shown in the Barbarian table; regain 1 on a Short Rest and all on a Long Rest';
        case 'Weapon Mastery':
          return '2-4 chosen melee weapons by Barbarian level; one choice can be changed after a Long Rest';
        case 'Primal Knowledge':
          return '1 chosen Barbarian skill proficiency';
        case 'Brutal Strike':
          return 'Once per turn when using Reckless Attack';
        case 'Relentless Rage':
          return 'Trigger while raging when you would drop to 0 Hit Points';
        case 'Persistent Rage':
          return 'Once per Long Rest when Initiative is rolled; Rage lasts 10 minutes';
      }
    }

    if (className == 'fighter') {
      switch (name) {
        case 'Fighting Style':
          return '1 chosen Fighting Style';
        case 'Second Wind':
          return '2-4 uses by Fighter level; regain 1 on a Short Rest and all on a Long Rest';
        case 'Weapon Mastery':
          return '3-6 chosen weapons by Fighter level; one choice can be changed after a Long Rest';
        case 'Action Surge (one use)':
          return '1 use';
        case 'Action Surge (two uses)':
          return '2 uses, but only once on a turn';
        case 'Indomitable (one use)':
          return '1 use';
        case 'Indomitable (two uses)':
          return '2 uses';
        case 'Indomitable (three uses)':
          return '3 uses';
      }
    }

    if (className == 'ranger') {
      switch (name) {
        case 'Favored Enemy':
          return 'Limited free castings of Hunter\'s Mark per Long Rest';
        case 'Tireless':
          return 'Temporary Hit Points uses equal to Wisdom modifier, minimum 1';
        case 'Nature\'s Veil':
        case 'Nature’s Veil':
          return 'Uses equal to Wisdom modifier, minimum 1';
        case 'Weapon Mastery':
          return '2 chosen weapons; one choice can be changed after a Long Rest';
        case 'Druidic Warrior':
          return '2 chosen Druid cantrips';
      }
    }

    if (className == 'paladin') {
      switch (name) {
        case 'Lay On Hands':
          return 'Healing pool equal to 5 times your Paladin level';
        case 'Weapon Mastery':
          return '2 chosen weapons; one choice can be changed after a Long Rest';
        case 'Fighting Style':
          return '1 chosen Fighting Style';
        case "Paladin's Smite":
          return 'Divine Smite is always prepared; one free casting per Long Rest';
        case 'Channel Divinity':
          return '2 uses; regain 1 on a Short Rest and all on a Long Rest';
        case 'Faithful Steed':
          return 'Find Steed is always prepared; one free casting per Long Rest';
        case 'Abjure Foes':
          return 'Uses Channel Divinity';
        case 'Restoring Touch':
          return 'Spend 5 Lay On Hands points per removed condition';
      }
    }

    if (className == 'bard') {
      switch (name) {
        case 'Bardic Inspiration':
          return 'Uses equal to Charisma modifier, minimum 1';
        case 'Expertise':
          return '2 chosen skill proficiencies at Bard level 2, and 2 more at level 9';
        case 'Jack of All Trades':
          return 'Applies to skill checks that do not use your Proficiency Bonus';
        case 'Font of Inspiration':
          return 'Bardic Inspiration refreshes on Short or Long Rest; spell slots can restore uses';
        case 'Countercharm':
          return 'At will when you or an ally within 30 feet fails the triggering save';
        case 'Magical Secrets':
          return 'Level 1+ prepared Bard spells can come from the Bard, Cleric, Druid, and Wizard lists';
        case 'Superior Inspiration':
          return 'Triggers when Initiative is rolled';
        case 'Words of Creation':
          return 'Power Word Heal and Power Word Kill are always prepared';
      }
    }

    if (className == 'druid') {
      switch (name) {
        case 'Druidic':
          return 'Always prepared: Speak with Animals';
        case 'Primal Order':
          return 'Choose Magician or Warden';
        case 'Wild Shape':
          return 'Uses scale by Druid level; regain one on Short Rest and all on Long Rest';
        case 'Wild Companion':
          return 'Spend a spell slot or Wild Shape use';
        case 'Wild Resurgence':
          return 'Once per turn when out of Wild Shape uses; spell-slot conversion once per Long Rest';
        case 'Elemental Fury':
          return 'Choose Potent Spellcasting or Primal Strike';
        case 'Improved Elemental Fury':
          return 'Improves the Elemental Fury option you chose';
        case 'Archdruid':
          return 'Regain Wild Shape on Initiative and convert Wild Shape uses to spell slots';
      }
    }

    if (className == 'sorcerer') {
      switch (name) {
        case 'Innate Sorcery':
          return '2 uses';
        case 'Font of Magic':
          return 'Sorcery Point maximum equals Sorcerer level from level 2 onward';
        case 'Metamagic':
          return '2 options at Sorcerer level 2, 2 more at level 10, and 2 more at level 17';
        case 'Sorcerous Restoration':
          return 'Once per Long Rest after a Short Rest';
        case 'Sorcery Incarnate':
          return 'Can spend 2 Sorcery Points if Innate Sorcery uses are empty';
        case 'Arcane Apotheosis':
          return 'Once on each of your turns while Innate Sorcery is active';
      }
    }

    if (className == 'warlock') {
      if (name.startsWith('Mystic Arcanum')) {
        return '1 casting per Long Rest for the chosen arcanum spell';
      }
      switch (name) {
        case 'Eldritch Invocations':
          return '1-10 chosen invocations by Warlock level';
        case 'Pact Magic':
          return 'Pact Magic slots refresh on Short or Long Rest';
        case 'Magical Cunning':
          return 'Once per Long Rest';
        case 'Contact Patron':
          return 'Contact Other Plane once per Long Rest through this feature';
        case 'Eldritch Master':
          return 'Improves Magical Cunning';
      }
    }

    const map = <String, String>{
      'Rage': 'Limited uses per Long Rest',
      'Turn Undead': 'Uses Channel Divinity',
      'Channel Divinity': 'Limited uses per Short or Long Rest',
      'Second Wind': '1 use',
      'Action Surge': '1 use',
      'Bardic Inspiration': 'Limited uses based on Charisma modifier',
      'Bonus Proficiencies': '3 chosen skill proficiencies',
      'Cutting Words': 'Spend Bardic Inspiration when the trigger happens',
      'Magical Discoveries': '2 chosen spells',
      'Peerless Skill': 'Spend Bardic Inspiration after a failed roll',
      'Monk\'s Focus': 'Focus Points equal to your Monk level',
      'Slow Fall': 'At will when the trigger happens',
      'Stunning Strike':
          'Once per turn when you hit with a Monk weapon or Unarmed Strike',
      'Sneak Attack': 'Once per turn when its conditions are met',
      'Lay On Hands': 'Pool of healing points',
      'Tides of Chaos': '1 use',
      'Bend Luck': 'Spend 2 Sorcery Points',
      'Large Form': '1 use',
      'Draconic Flight': '1 use',
      'Breath Weapon': 'Limited uses by species rules',
      'Frenzy':
          'Once per turn while Rage is active and Reckless Attack is used',
      'Retaliation': 'At will when the trigger happens',
      'Intimidating Presence':
          'Once per Long Rest, or restore by expending one Rage use',
      'Rage of the Wilds': 'Choose Bear, Eagle, or Wolf each time Rage starts',
      'Aspect of the Wilds':
          'Choose Owl, Panther, or Salmon; can change after a Long Rest',
      'Power of the Wilds': 'Choose Falcon, Lion, or Ram each time Rage starts',
      'Vitality of the Tree': 'Applies while Rage is active',
      'Branches of the Tree': 'At will while Rage is active',
      'Travel Along the Tree':
          'At will while Rage is active; extended range once per Rage',
      'Divine Fury': 'Once on each of your turns while Rage is active',
      'Warrior of the Gods': 'Healing dice pool per Long Rest',
      'Fanatical Focus': 'Once per active Rage',
      'Zealous Presence':
          'Once per Long Rest, or restore by expending one Rage use',
      'Rage of the Gods': 'Once per Long Rest; reaction benefit can spend Rage',
    };
    return map[name];
  }
}
