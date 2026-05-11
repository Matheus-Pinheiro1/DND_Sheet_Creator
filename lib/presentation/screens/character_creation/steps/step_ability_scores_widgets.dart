part of 'step_ability_scores.dart';

class _PointCostTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const costs = {8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9};

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Point Cost Reference',
              style: AppTextStyles.cinzel(
                color: Colors.white38,
                fontSize: 11,
              )),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: costs.entries
                .map((e) => Column(children: [
                      Text('${e.key}',
                          style: AppTextStyles.lato(
                            color: Colors.white70,
                            fontSize: 12,
                          )),
                      Text('${e.value}pt',
                          style: AppTextStyles.lato(
                            color: AppTheme.gold,
                            fontSize: 10,
                          )),
                    ]))
                .toList(),
          ),
        ],
      ),
    );
  }
}
