part of '../step_spells.dart';

extension _StepSpellsHelpers on _StepSpellsState {
  String _ordinalLabel(int level) {
    switch (level) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '${level}th';
    }
  }

  String _selectedBaseRaceId(String raceValue) {
    if (!raceValue.contains('::')) return raceValue;
    return raceValue.split('::').first;
  }

  int _spellcastingModifier(CreationState state) {
    switch (state.spellcastingAbility) {
      case 'int':
        return DiceCalculator.getModifier(state.intelligence);
      case 'wis':
        return DiceCalculator.getModifier(state.wisdom);
      case 'cha':
        return DiceCalculator.getModifier(state.charisma);
      default:
        return 0;
    }
  }
}

class _BardMagicalSecretsCard extends StatelessWidget {
  final bool hasWordsOfCreation;

  const _BardMagicalSecretsCard({
    required this.hasWordsOfCreation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Magical Secrets',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your level 1+ Bard spell choices can include Bard, Cleric, Druid, and Wizard spells. Cantrips still come from the Bard list.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          if (hasWordsOfCreation) ...[
            const SizedBox(height: 8),
            Text(
              'Words of Creation adds Power Word Heal and Power Word Kill automatically.',
              style: AppTextStyles.lato(
                color: Colors.white54,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
