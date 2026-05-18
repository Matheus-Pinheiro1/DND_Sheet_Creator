part of 'monsters_screen.dart';

class _MonsterQuantitySheet extends StatefulWidget {
  final String name;
  final MonsterMeta? meta;

  const _MonsterQuantitySheet({
    required this.name,
    required this.meta,
  });

  @override
  State<_MonsterQuantitySheet> createState() => _MonsterQuantitySheetState();
}

class _MonsterQuantitySheetState extends State<_MonsterQuantitySheet> {
  final _quantityCtrl = TextEditingController(text: '1');
  int _quantity = 1;

  @override
  void dispose() {
    _quantityCtrl.dispose();
    super.dispose();
  }

  void _setQuantity(int value) {
    final next = value.clamp(1, 50).toInt();
    setState(() {
      _quantity = next;
      _quantityCtrl.value = TextEditingValue(
        text: '$next',
        selection: TextSelection.collapsed(offset: '$next'.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.meta;
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom + media.viewPadding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Add Monster',
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              meta == null
                  ? widget.name
                  : '${widget.name} - CR ${meta.crLabel} ${_capitalize(meta.type)}',
              style: AppTextStyles.lato(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed:
                      _quantity <= 1 ? null : () => _setQuantity(_quantity - 1),
                  icon: const Icon(Icons.remove),
                  tooltip: 'Decrease quantity',
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _quantityCtrl,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      isDense: true,
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null) {
                        setState(() {
                          _quantity = parsed.clamp(1, 50).toInt();
                        });
                      }
                    },
                    onSubmitted: (value) {
                      _setQuantity(int.tryParse(value) ?? _quantity);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: _quantity >= 50
                      ? null
                      : () => _setQuantity(_quantity + 1),
                  icon: const Icon(Icons.add),
                  tooltip: 'Increase quantity',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(_quantity),
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(
                      _quantity == 1
                          ? 'Add ${widget.name}'
                          : 'Add ${widget.name} x$_quantity',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
