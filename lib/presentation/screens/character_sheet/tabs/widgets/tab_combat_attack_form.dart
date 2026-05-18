part of '../tab_combat.dart';

class _AttackFormSheet extends StatefulWidget {
  final CharacterModel character;
  final AttackModel? existing;
  final void Function(AttackModel) onSave;

  const _AttackFormSheet({
    required this.character,
    this.existing,
    required this.onSave,
  });

  @override
  State<_AttackFormSheet> createState() => _AttackFormSheetState();
}

class _AttackFormSheetState extends State<_AttackFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _bonus;
  late final TextEditingController _dice;
  late final TextEditingController _type;
  late final TextEditingController _range;
  late final TextEditingController _props;
  late bool _isMagic;

  static const _damageTypes = [
    'Slashing',
    'Piercing',
    'Bludgeoning',
    'Slashing + Radiant',
    'Piercing + Radiant',
    'Bludgeoning + Radiant',
    'Fire',
    'Cold',
    'Lightning',
    'Thunder',
    'Acid',
    'Poison',
    'Necrotic',
    'Radiant',
    'Psychic',
    'Force',
    'Special',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _bonus = TextEditingController(text: e?.attackBonus ?? '+0');
    _dice = TextEditingController(text: e?.damageDice ?? '1d6');
    _type = TextEditingController(text: e?.damageType ?? 'Slashing');
    _range = TextEditingController(text: e?.range ?? '5 ft');
    _props = TextEditingController(text: e?.properties ?? '');
    _isMagic = e?.isMagic ?? false;

    for (final ctrl in [_name, _bonus, _dice, _type, _range, _props]) {
      ctrl.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _bonus, _dice, _type, _range, _props]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _chooseWeapon() async {
    final weapon = await showWeaponPickerBottomSheet(context);
    if (weapon == null || !mounted) return;

    setState(() {
      _name.text = weapon.name;
      _dice.text = WeaponBonusCalculator.calculateWeaponDamageDice(
        weapon,
        widget.character,
      );
      _type.text = WeaponBonusCalculator.calculateWeaponDamageType(
        weapon,
        widget.character,
      );
      _range.text = weapon.range;
      _props.text = weapon.properties;
      _bonus.text = WeaponBonusCalculator.calculateWeaponBonus(
        weapon,
        widget.character,
      );
    });
  }

  void _save() {
    if (_name.text.trim().isEmpty) return;
    widget.onSave(
      AttackModel(
        name: _name.text.trim(),
        attackBonus: _bonus.text.trim(),
        damageDice: _dice.text.trim(),
        damageType: _type.text.trim(),
        range: _range.text.trim(),
        properties: _props.text.trim(),
        isMagic: _isMagic,
      ),
    );
    Navigator.pop(context);
  }

  DndWeapon? findWeaponByName(String name) {
    final query = name.trim().toLowerCase();
    if (query.isEmpty) return null;

    for (final weapon in kDndWeapons) {
      if (weapon.name.toLowerCase() == query) {
        return weapon;
      }
    }

    for (final weapon in kDndWeapons) {
      if (weapon.name.toLowerCase().contains(query)) {
        return weapon;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom + media.viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              widget.existing != null ? 'Edit Attack' : 'Add Attack',
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _chooseWeapon,
                icon: const Icon(Icons.list_alt_outlined, color: AppTheme.gold),
                label: Text(
                  'Choose from Weapon List',
                  style: AppTextStyles.cinzel(
                    color: AppTheme.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.gold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _FormField('Name *', _name, hint: 'Longsword, Fireball, etc.'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _FormField('Attack Bonus', _bonus, hint: '+5')),
                const SizedBox(width: 12),
                Expanded(child: _FormField('Damage Dice', _dice, hint: '1d8')),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _damageTypes.contains(_type.text)
                  ? _type.text
                  : _damageTypes.first,
              decoration: InputDecoration(
                labelText: 'Damage Type',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownColor: AppTheme.ashGray,
              items: _damageTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        t,
                        style: AppTextStyles.lato(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _type.text = v);
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _FormField('Range', _range, hint: '5 ft')),
                const SizedBox(width: 12),
                Expanded(
                    child:
                        _FormField('Properties', _props, hint: 'Versatile...')),
              ],
            ),
            const SizedBox(height: 10),
            if (_name.text.trim().isNotEmpty)
              Builder(
                builder: (_) {
                  final selectedWeapon = findWeaponByName(_name.text);
                  if (selectedWeapon == null) return const SizedBox.shrink();
                  final autoBonus = WeaponBonusCalculator.calculateWeaponBonus(
                    selectedWeapon,
                    widget.character,
                  );
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.gold.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      'Suggested attack bonus: $autoBonus',
                      style: AppTextStyles.lato(
                        color: AppTheme.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Switch(
                  value: _isMagic,
                  activeThumbColor: Colors.purpleAccent,
                  onChanged: (v) => setState(() => _isMagic = v),
                ),
                const SizedBox(width: 8),
                Text(
                  'Magical weapon/spell',
                  style: AppTextStyles.lato(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _name.text.trim().isEmpty ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  widget.existing != null ? 'Save Changes' : 'Add Attack',
                  style: AppTextStyles.cinzel(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String? hint;

  const _FormField(this.label, this.ctrl, {this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
      ),
      style: AppTextStyles.lato(color: Colors.white),
    );
  }
}
