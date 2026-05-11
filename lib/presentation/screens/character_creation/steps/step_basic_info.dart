import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/character_creation_provider.dart';

class StepBasicInfo extends ConsumerStatefulWidget {
  const StepBasicInfo({super.key});
  @override
  ConsumerState<StepBasicInfo> createState() => _StepBasicInfoState();
}

class _StepBasicInfoState extends ConsumerState<StepBasicInfo> {
  late final TextEditingController _nameCtrl;
  late String _alignment;
  late int _level;

  static const alignments = [
    'Lawful Good',
    'Neutral Good',
    'Chaotic Good',
    'Lawful Neutral',
    'True Neutral',
    'Chaotic Neutral',
    'Lawful Evil',
    'Neutral Evil',
    'Chaotic Evil',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(creationProvider);
    _nameCtrl = TextEditingController(text: state.name);
    _alignment = state.alignment;
    _level = state.level;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(creationProvider.notifier).setBasicInfo(
          name: _nameCtrl.text.trim(),
          alignment: _alignment,
          level: _level,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Character Name *'),
        TextField(
          controller: _nameCtrl,
          onChanged: (_) => _save(),
          decoration: const InputDecoration(
            hintText: 'Enter your character\'s name',
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 24),
        const _Label('Alignment'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: alignments.map((a) {
            final selected = _alignment == a;
            return ChoiceChip(
              label: Text(a, style: AppTextStyles.lato(fontSize: 12)),
              selected: selected,
              onSelected: (_) {
                setState(() => _alignment = a);
                _save();
              },
              selectedColor: AppTheme.crimson,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const _Label('Level'),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: _level > 1
                  ? () {
                      setState(() => _level--);
                      _save();
                    }
                  : null,
            ),
            Expanded(
              child: Text(
                '$_level',
                textAlign: TextAlign.center,
                style: AppTextStyles.cinzel(
                  fontSize: 32,
                  color: AppTheme.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _level < 20
                  ? () {
                      setState(() => _level++);
                      _save();
                    }
                  : null,
            ),
          ],
        ),
        Center(
          child: Text(
            'XP required: ${_xpForLevel(_level)}',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          ),
        ),
      ],
    );
  }

  int _xpForLevel(int level) {
    const xpTable = [
      0,
      300,
      900,
      2700,
      6500,
      14000,
      23000,
      34000,
      48000,
      64000,
      85000,
      100000,
      120000,
      140000,
      165000,
      195000,
      225000,
      265000,
      305000,
      355000
    ];
    return level > 0 && level <= xpTable.length ? xpTable[level - 1] : 0;
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.cinzel(
          color: AppTheme.gold,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
