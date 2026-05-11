part of '../tab_combat.dart';

class _CurrencyWidget extends StatelessWidget {
  final CharacterModel character;
  final void Function(CharacterModel) onUpdate;

  const _CurrencyWidget({required this.character, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final coins = [
      _Coin('CP', character.copper, const Color(0xFFB87333),
          (v) => onUpdate(character.copyWith(copper: v))),
      _Coin('SP', character.silver, Colors.grey.shade300,
          (v) => onUpdate(character.copyWith(silver: v))),
      _Coin('EP', character.electrum, Colors.lightBlue,
          (v) => onUpdate(character.copyWith(electrum: v))),
      _Coin('GP', character.gold, AppTheme.gold,
          (v) => onUpdate(character.copyWith(gold: v))),
      _Coin('PP', character.platinum, const Color(0xFFE5E4E2),
          (v) => onUpdate(character.copyWith(platinum: v))),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.gold),
      ),
      child: Column(children: [
        Text('Tap to edit',
            style: AppTextStyles.lato(
              color: Colors.white38,
              fontSize: 10,
            )),
        const SizedBox(height: 8),
        Row(
            children: coins
                .map((c) => Expanded(
                      child: _CoinButton(
                        coin: c,
                        onTap: () => _editCoin(context, c),
                      ),
                    ))
                .toList()),
      ]),
    );
  }

  void _editCoin(BuildContext context, _Coin coin) {
    final ctrl = TextEditingController(text: '${coin.amount}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.ashGray,
        title:
            Text(coin.symbol, style: AppTextStyles.cinzel(color: coin.color)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: '${coin.symbol} amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.lato(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text);
              if (v != null) coin.onEdit(v);
              Navigator.pop(ctx);
            },
            child: Text('Save', style: AppTextStyles.lato()),
          ),
        ],
      ),
    );
  }
}

class _Coin {
  final String symbol;
  final int amount;
  final Color color;
  final void Function(int) onEdit;
  const _Coin(this.symbol, this.amount, this.color, this.onEdit);
}

class _CoinButton extends StatelessWidget {
  final _Coin coin;
  final VoidCallback onTap;
  const _CoinButton({required this.coin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: coin.color.withValues(alpha: 0.18),
            border: Border.all(color: coin.color, width: 1.5),
          ),
          child: Center(
              child: Text(coin.symbol,
                  style: TextStyle(
                    color: coin.color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ))),
        ),
        const SizedBox(height: 4),
        Text('${coin.amount}',
            style: AppTextStyles.cinzel(
              color: coin.color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
      ]),
    );
  }
}
