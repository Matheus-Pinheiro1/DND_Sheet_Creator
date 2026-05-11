part of '../tab_combat.dart';

class _ExhaustionTracker extends StatelessWidget {
  final int level;
  final int baseSpeed;
  final ValueChanged<int> onChanged;

  const _ExhaustionTracker({
    required this.level,
    required this.baseSpeed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpeed = (baseSpeed - (level * 5)).clamp(0, 999).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Exhaustion $level / 6',
                  style: AppTextStyles.cinzel(
                    color: AppTheme.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Effective Speed: ${effectiveSpeed.toInt()} ft',
                style: AppTextStyles.lato(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (value) {
              final selected = value == level;
              return ChoiceChip(
                label: Text(
                  '$value',
                  style: AppTextStyles.lato(fontSize: 12),
                ),
                selected: selected,
                selectedColor:
                    value >= 4 ? Colors.red.shade800 : AppTheme.crimson,
                onSelected: (_) => onChanged(value),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            'Exhaustion: each level gives -2 to d20 tests and -5 ft speed. At exhaustion 6, the character dies.',
            style: AppTextStyles.lato(
              color: Colors.white54,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HPTracker extends StatelessWidget {
  final int current;
  final int temp;
  final int max;
  final void Function(int) onDamage;
  final void Function(int) onHeal;
  final void Function(int) onTempHP;

  const _HPTracker({
    required this.current,
    required this.temp,
    required this.max,
    required this.onDamage,
    required this.onHeal,
    required this.onTempHP,
  });

  Color get _color {
    if (max == 0) return Colors.white;
    final r = current / max;
    if (r > 0.5) return Colors.greenAccent;
    if (r > 0.25) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color, width: 1.5),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('$current',
                style: AppTextStyles.cinzel(
                  color: _color,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                )),
            Text(' / $max',
                style: AppTextStyles.lato(
                  color: Colors.white38,
                  fontSize: 18,
                )),
            if (temp > 0) ...[
              const SizedBox(width: 8),
              Text('+$temp',
                  style: AppTextStyles.cinzel(
                    color: Colors.lightBlue,
                    fontSize: 20,
                  )),
              Text(' temp',
                  style: AppTextStyles.lato(
                    color: Colors.lightBlue,
                    fontSize: 11,
                  )),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: max > 0 ? (current / max).clamp(0, 1) : 0,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(_color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _HPButton('DAMAGE', Colors.redAccent, Icons.remove,
              () => _showInput(context, 'Take Damage', true)),
          _HPButton('HEAL', Colors.greenAccent, Icons.favorite,
              () => _showInput(context, 'Heal', false)),
          _HPButton('TEMP HP', Colors.lightBlue, Icons.add_circle_outline,
              () => _showTempInput(context)),
        ]),
      ]),
    );
  }

  void _showInput(BuildContext context, String title, bool isDamage) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.ashGray,
        title: Text(title,
            style: AppTextStyles.cinzel(
              color: isDamage ? Colors.redAccent : Colors.greenAccent,
            )),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: isDamage ? 'Damage amount' : 'Heal amount',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.lato(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text) ?? 0;
              if (v > 0) isDamage ? onDamage(v) : onHeal(v);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDamage ? Colors.red.shade700 : Colors.green.shade700,
            ),
            child: Text(title, style: AppTextStyles.lato()),
          ),
        ],
      ),
    );
  }

  void _showTempInput(BuildContext context) {
    final ctrl = TextEditingController(text: '$temp');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.ashGray,
        title: Text('Temporary HP',
            style: AppTextStyles.cinzel(
              color: Colors.lightBlue,
            )),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Temp HP amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.lato(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text) ?? 0;
              onTempHP(v);
              Navigator.pop(ctx);
            },
            child: Text('Set', style: AppTextStyles.lato()),
          ),
        ],
      ),
    );
  }
}

class _HPButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _HPButton(this.label, this.color, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.cinzel(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              )),
        ]),
      ),
    );
  }
}

class _DeathSavesWidget extends StatelessWidget {
  final CharacterModel character;
  final void Function(CharacterModel) onUpdate;

  const _DeathSavesWidget({required this.character, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(
              child: _SavesRow(
            label: 'Successes',
            count: character.deathSaveSuccesses,
            color: Colors.greenAccent,
            icon: Icons.check_circle,
            onTap: (i) => onUpdate(character.copyWith(
              deathSaveSuccesses: (i < character.deathSaveSuccesses
                  ? i
                  : (character.deathSaveSuccesses + 1).clamp(0, 3)),
            )),
          )),
          const SizedBox(width: 16),
          Expanded(
              child: _SavesRow(
            label: 'Failures',
            count: character.deathSaveFailures,
            color: Colors.redAccent,
            icon: Icons.cancel,
            onTap: (i) => onUpdate(character.copyWith(
              deathSaveFailures: (i < character.deathSaveFailures
                  ? i
                  : (character.deathSaveFailures + 1).clamp(0, 3)),
            )),
          )),
        ]),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => onUpdate(character.copyWith(
            deathSaveSuccesses: 0,
            deathSaveFailures: 0,
          )),
          icon: const Icon(Icons.refresh, size: 14, color: Colors.white30),
          label: Text('Reset',
              style: AppTextStyles.lato(
                color: Colors.white30,
                fontSize: 12,
              )),
        ),
      ]),
    );
  }
}

class _SavesRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final void Function(int) onTap;

  const _SavesRow({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: AppTextStyles.lato(color: color, fontSize: 12)),
      const SizedBox(height: 8),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (i) => GestureDetector(
              onTap: () => onTap(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  i < count ? icon : Icons.circle_outlined,
                  color: color,
                  size: 30,
                ),
              ),
            ),
          )),
    ]);
  }
}
