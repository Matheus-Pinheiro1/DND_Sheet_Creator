part of '../tab_combat.dart';

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: AppTextStyles.cinzel(
            color: AppTheme.gold,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          )),
    );
  }
}

class _StatDisplay extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatDisplay(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return StatBox(label: label, value: value, color: color);
  }
}

class _EditableStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final void Function(int) onEdit;

  const _EditableStat({
    required this.label,
    required this.value,
    required this.color,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final ctrl = TextEditingController(text: '$value');
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.ashGray,
            title:
                Text('Edit $label', style: AppTextStyles.cinzel(color: color)),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: label),
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
                  if (v != null) onEdit(v);
                  Navigator.pop(ctx);
                },
                child: Text('Save', style: AppTextStyles.lato()),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.ashGray,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
        ),
        child: Column(children: [
          Text('$value',
              style: AppTextStyles.cinzel(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label,
                style: AppTextStyles.lato(
                  color: Colors.white38,
                  fontSize: 10,
                )),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 9, color: color),
          ]),
        ]),
      ),
    );
  }
}
