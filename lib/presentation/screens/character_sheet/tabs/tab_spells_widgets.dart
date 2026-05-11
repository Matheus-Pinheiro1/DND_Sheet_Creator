part of 'tab_spells.dart';

class _ConcentrationBanner extends StatelessWidget {
  final String spellName;
  final VoidCallback onEnd;

  const _ConcentrationBanner({
    required this.spellName,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.orange,
      child: Row(children: [
        const Icon(Icons.track_changes, color: Colors.orangeAccent, size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Concentrating',
                style: AppTextStyles.cinzel(
                  color: Colors.orangeAccent,
                  fontSize: 11,
                )),
            Text(spellName,
                style: AppTextStyles.lato(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
          ],
        )),
        TextButton(
          onPressed: onEnd,
          style: TextButton.styleFrom(
            foregroundColor: Colors.orangeAccent,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text('End', style: AppTextStyles.lato(fontSize: 12)),
        ),
      ]),
    );
  }
}

class _SpellSlotRow extends StatelessWidget {
  final int level;
  final int max;
  final int used;
  final void Function(int) onToggle;

  const _SpellSlotRow({
    required this.level,
    required this.max,
    required this.used,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        SizedBox(
          width: 56,
          child: Text('Lv $level',
              style: AppTextStyles.cinzel(
                color: Colors.white60,
                fontSize: 12,
              )),
        ),
        ...List.generate(max, (i) {
          final isAvailable = i >= used;
          return GestureDetector(
            onTap: () => onToggle(isAvailable ? used + 1 : used - 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAvailable ? AppTheme.gold : Colors.white12,
                border: Border.all(
                  color: isAvailable ? AppTheme.gold : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: isAvailable
                  ? null
                  : const Icon(Icons.close, size: 12, color: Colors.white24),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text('${max - used}/$max',
            style: AppTextStyles.lato(
              color: Colors.white30,
              fontSize: 11,
            )),
      ]),
    );
  }
}
