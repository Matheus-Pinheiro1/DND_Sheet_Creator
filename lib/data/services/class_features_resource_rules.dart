part of 'class_features_service.dart';

extension _ClassFeatureResourceRules on ClassFeaturesService {
  String? _resourceCostFor(String name, {String? className}) {
    if (className == 'barbarian') {
      switch (name) {
        case 'Rage':
          return '1 Rage use';
        case 'Instinctive Pounce':
          return 'No extra cost beyond entering Rage';
        case 'Brutal Strike':
          return 'Forgo Advantage from Reckless Attack on one attack roll';
        case 'Relentless Rage':
          return 'No separate resource; requires active Rage';
      }
    }

    if (className == 'fighter') {
      switch (name) {
        case 'Second Wind':
          return '1 Second Wind use';
        case 'Tactical Mind':
          return '1 Second Wind use; not expended if the check still fails';
        case 'Tactical Shift':
          return 'No extra cost beyond using Second Wind as a Bonus Action';
        case 'Action Surge (one use)':
        case 'Action Surge (two uses)':
          return '1 Action Surge use';
        case 'Indomitable (one use)':
        case 'Indomitable (two uses)':
        case 'Indomitable (three uses)':
          return '1 Indomitable use';
      }
    }

    if (className == 'ranger') {
      switch (name) {
        case 'Favored Enemy':
          return 'One free Hunter\'s Mark casting, or a spell slot after the free uses are expended';
        case 'Tireless':
          return 'One Tireless use for the Temporary Hit Points action';
        case 'Nature\'s Veil':
        case 'Nature’s Veil':
          return 'One Nature\'s Veil use';
      }
    }

    if (className == 'paladin') {
      switch (name) {
        case 'Lay On Hands':
          return 'Lay On Hands points';
        case "Paladin's Smite":
          return 'One free Divine Smite casting, or a spell slot after the free use is expended';
        case 'Channel Divinity':
        case 'Abjure Foes':
          return '1 Channel Divinity use';
        case 'Faithful Steed':
          return 'One free Find Steed casting, or a spell slot after the free use is expended';
        case 'Restoring Touch':
          return '5 Lay On Hands points per condition';
      }
    }

    if (className == 'bard') {
      switch (name) {
        case 'Bardic Inspiration':
          return '1 Bardic Inspiration die';
        case 'Font of Inspiration':
          return 'Optional spell slot to regain 1 Bardic Inspiration use';
        case 'Countercharm':
          return 'Reaction';
      }
    }

    if (className == 'druid') {
      switch (name) {
        case 'Wild Shape':
          return '1 Wild Shape use';
        case 'Wild Companion':
          return '1 spell slot or 1 Wild Shape use';
        case 'Wild Resurgence':
          return '1 spell slot or 1 Wild Shape use';
        case 'Elemental Fury':
          return 'No resource';
        case 'Archdruid':
          return 'Wild Shape uses';
      }
    }

    if (className == 'sorcerer') {
      switch (name) {
        case 'Innate Sorcery':
          return '1 Innate Sorcery use';
        case 'Font of Magic':
          return 'Sorcery Points and spell slots';
        case 'Metamagic':
          return 'Sorcery Point cost varies by option';
        case 'Sorcerous Restoration':
          return 'Short Rest recovery feature';
        case 'Sorcery Incarnate':
          return '2 Sorcery Points if no Innate Sorcery uses remain';
        case 'Arcane Apotheosis':
          return 'No Sorcery Point cost for one Metamagic option each turn';
      }
    }

    if (className == 'warlock') {
      if (name.startsWith('Mystic Arcanum')) {
        return 'Mystic Arcanum use';
      }
      switch (name) {
        case 'Magical Cunning':
          return '1 Magical Cunning use';
        case 'Contact Patron':
          return 'Contact Patron free casting';
        case 'Pact Magic':
          return 'Pact Magic spell slots';
        case 'Eldritch Master':
          return 'Magical Cunning use';
      }
    }

    const map = <String, String>{
      'Rage': '1 Rage use',
      'Turn Undead': '1 Channel Divinity use',
      'Channel Divinity': '1 Channel Divinity use',
      'Second Wind': 'No additional resource beyond the feature use',
      'Action Surge': 'No additional resource beyond the feature use',
      'Bardic Inspiration': '1 Bardic Inspiration die',
      'Cutting Words': '1 Bardic Inspiration die',
      'Peerless Skill': '1 Bardic Inspiration die',
      'Monk\'s Focus':
          '1 Focus Point for Flurry of Blows, Patient Defense, or Step of the Wind',
      'Stunning Strike': '1 Focus Point',
      'Sneak Attack':
          'No separate resource; requires finesse or ranged weapon conditions',
      'Lay On Hands': 'Points from your Lay on Hands pool',
      'Divine Smite': '1 spell slot',
      'Ki': 'Ki points',
      'Tides of Chaos': 'No point cost',
      'Bend Luck': '2 Sorcery Points',
      'Psionic Energy Dice': 'Psionic Energy Dice',
      'Psionic Discipline':
          'Psionic Energy Dice as specified by the discipline',
      'Large Form': 'No point cost',
      'Breath Weapon': 'No point cost',
      'Draconic Flight': 'No point cost',
      'Frenzy': 'Requires active Rage and Reckless Attack',
      'Retaliation': 'Reaction',
      'Intimidating Presence': 'Use of the feature, or 1 Rage use to restore',
      'Rage of the Wilds': 'No extra cost beyond entering Rage',
      'Power of the Wilds': 'No extra cost beyond entering Rage',
      'Vitality of the Tree': 'No extra cost beyond entering Rage',
      'Branches of the Tree': 'Reaction while Rage is active',
      'Travel Along the Tree': 'Bonus Action while Rage is active',
      'Divine Fury': 'No extra cost beyond active Rage',
      'Warrior of the Gods': 'One or more d12s from the healing pool',
      'Fanatical Focus': 'No extra cost beyond active Rage',
      'Zealous Presence': 'Use of the feature, or 1 Rage use to restore',
      'Rage of the Gods': 'Feature use; Revivification spends 1 Rage use',
    };
    return map[name];
  }

  String? _rechargeFor(String name, {String? className}) {
    if (className == 'barbarian') {
      switch (name) {
        case 'Rage':
          return 'Short or Long Rest';
        case 'Relentless Rage':
          return 'DC resets on Short or Long Rest';
        case 'Persistent Rage':
          return 'Long Rest';
      }
    }

    if (className == 'fighter') {
      switch (name) {
        case 'Second Wind':
          return 'Short or Long Rest';
        case 'Action Surge (one use)':
        case 'Action Surge (two uses)':
          return 'Short or Long Rest';
        case 'Indomitable (one use)':
        case 'Indomitable (two uses)':
        case 'Indomitable (three uses)':
          return 'Long Rest';
      }
    }

    if (className == 'ranger') {
      switch (name) {
        case 'Favored Enemy':
        case 'Tireless':
        case 'Nature\'s Veil':
        case 'Nature’s Veil':
          return 'Long Rest';
      }
    }

    if (className == 'paladin') {
      switch (name) {
        case 'Lay On Hands':
        case "Paladin's Smite":
        case 'Faithful Steed':
          return 'Long Rest';
        case 'Channel Divinity':
        case 'Abjure Foes':
          return 'Short or Long Rest';
      }
    }

    if (className == 'bard') {
      switch (name) {
        case 'Bardic Inspiration':
          return 'Long Rest; Short or Long Rest after Font of Inspiration';
        case 'Font of Inspiration':
          return 'Short or Long Rest';
        case 'Superior Inspiration':
          return 'Initiative';
      }
    }

    if (className == 'druid') {
      switch (name) {
        case 'Wild Shape':
          return 'Short or Long Rest';
        case 'Wild Companion':
          return 'Uses spell slots or Wild Shape';
        case 'Wild Resurgence':
          return 'Long Rest for spell-slot conversion';
        case 'Archdruid':
          return 'Initiative / Long Rest';
      }
    }

    if (className == 'sorcerer') {
      switch (name) {
        case 'Innate Sorcery':
        case 'Font of Magic':
          return 'Long Rest';
        case 'Sorcerous Restoration':
          return 'Long Rest';
        case 'Sorcery Incarnate':
        case 'Arcane Apotheosis':
          return 'Uses Innate Sorcery and Sorcery Points';
      }
    }

    if (className == 'warlock') {
      if (name.startsWith('Mystic Arcanum')) {
        return 'Long Rest';
      }
      switch (name) {
        case 'Pact Magic':
          return 'Short or Long Rest';
        case 'Magical Cunning':
        case 'Contact Patron':
          return 'Long Rest';
        case 'Eldritch Master':
          return 'Uses Magical Cunning';
      }
    }

    const map = <String, String>{
      'Rage': 'Long Rest',
      'Turn Undead': 'Short or Long Rest with Channel Divinity',
      'Channel Divinity': 'Short or Long Rest',
      'Second Wind': 'Short or Long Rest',
      'Action Surge': 'Short or Long Rest',
      'Lay On Hands': 'Long Rest',
      'Arcane Recovery': 'Long Rest',
      'Bardic Inspiration': 'Long Rest unless another class feature changes it',
      'Monk\'s Focus': 'Short or Long Rest',
      'Uncanny Dodge': 'No recharge',
      'Tides of Chaos': 'Restored when a Wild Magic Surge refreshes it',
      'Bend Luck': 'No recharge beyond Sorcery Points recovery',
      'Large Form': 'Long Rest',
      'Draconic Flight': 'Long Rest',
      'Breath Weapon': 'Long Rest or species recharge rule',
      'Psionic Energy Dice': 'Short or Long Rest depending on class text',
      'Intimidating Presence': 'Long Rest, or restored by expending Rage',
      'Aspect of the Wilds': 'Long Rest to change choice',
      'Travel Along the Tree': 'Extended range once per Rage',
      'Warrior of the Gods': 'Long Rest',
      'Zealous Presence': 'Long Rest, or restored by expending Rage',
      'Rage of the Gods': 'Long Rest',
    };
    return map[name];
  }
}
