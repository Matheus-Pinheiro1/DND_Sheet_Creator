import 'package:flutter/material.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/data/local/weapons_data.dart';

Future<DndWeapon?> showWeaponPickerBottomSheet(BuildContext context) {
  return showModalBottomSheet<DndWeapon>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.ashGray,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _WeaponPickerSheet(),
  );
}

class _WeaponPickerSheet extends StatefulWidget {
  const _WeaponPickerSheet();

  @override
  State<_WeaponPickerSheet> createState() => _WeaponPickerSheetState();
}

class _WeaponPickerSheetState extends State<_WeaponPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = kDndWeapons.where((weapon) {
      final q = _query.toLowerCase();
      return weapon.name.toLowerCase().contains(q) ||
          weapon.properties.toLowerCase().contains(q) ||
          weapon.mastery.toLowerCase().contains(q) ||
          weapon.damageType.toLowerCase().contains(q);
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Choose a Weapon',
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search weapon name, property, or mastery...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final weapon = filtered[index];
                  return Card(
                    color: AppTheme.charcoal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white10),
                    ),
                    child: ListTile(
                      title: Text(
                        weapon.name,
                        style: AppTextStyles.cinzel(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _weaponSubtitle(weapon),
                        style: AppTextStyles.lato(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        weapon.category == WeaponCategory.simple
                            ? 'Simple'
                            : 'Martial',
                        style: AppTextStyles.lato(
                          color: AppTheme.gold,
                          fontSize: 11,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(weapon),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weaponSubtitle(DndWeapon weapon) {
    return [
      '${weapon.damageDice} ${weapon.damageType} - ${weapon.range}',
      if (weapon.properties.isNotEmpty) weapon.properties,
      if (weapon.mastery.isNotEmpty) 'Mastery: ${weapon.mastery}',
    ].join('\n');
  }
}
