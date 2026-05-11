import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dice_calculator.dart';
import '../../../../providers/character_creation_provider.dart';

part 'step_ability_scores_content.dart';
part 'step_ability_scores_widgets.dart';

enum _AbilityMode { standardArray, pointBuy, custom }

class StepAbilityScores extends ConsumerStatefulWidget {
  const StepAbilityScores({super.key});

  @override
  ConsumerState<StepAbilityScores> createState() => _StepAbilityScoresState();
}

class _StepAbilityScoresState extends ConsumerState<StepAbilityScores> {
  _AbilityMode _mode = _AbilityMode.standardArray;

  static const _standardValues = [15, 14, 13, 12, 10, 8];
  static const _abilities = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];
  static const _keys = ['str', 'dex', 'con', 'int', 'wis', 'cha'];

  final Map<String, int?> _assignments = {
    'str': null,
    'dex': null,
    'con': null,
    'int': null,
    'wis': null,
    'cha': null,
  };

  final Map<String, int> _pointBuyScores = {
    'str': 8,
    'dex': 8,
    'con': 8,
    'int': 8,
    'wis': 8,
    'cha': 8,
  };

  late final Map<String, TextEditingController> _customCtrl;

  static const _pointCosts = {
    8: 0,
    9: 1,
    10: 2,
    11: 3,
    12: 4,
    13: 5,
    14: 7,
    15: 9
  };

  @override
  void initState() {
    super.initState();
    final s = ref.read(creationProvider);

    _customCtrl = {
      'str': TextEditingController(text: '${s.strength}'),
      'dex': TextEditingController(text: '${s.dexterity}'),
      'con': TextEditingController(text: '${s.constitution}'),
      'int': TextEditingController(text: '${s.intelligence}'),
      'wis': TextEditingController(text: '${s.wisdom}'),
      'cha': TextEditingController(text: '${s.charisma}'),
    };

    _hydrateFromState(s);
  }

  void _hydrateFromState(CreationState s) {
    final scores = <String, int>{
      'str': s.strength,
      'dex': s.dexterity,
      'con': s.constitution,
      'int': s.intelligence,
      'wis': s.wisdom,
      'cha': s.charisma,
    };

    for (final entry in scores.entries) {
      _customCtrl[entry.key]!.text = '${entry.value}';
      _pointBuyScores[entry.key] = entry.value.clamp(8, 15).toInt();
      _assignments[entry.key] = null;
    }

    final values = scores.values.toList();
    final sortedValues = [...values]..sort((a, b) => b.compareTo(a));
    final sortedStandard = [..._standardValues]..sort((a, b) => b.compareTo(a));

    if (_listsEqual(sortedValues, sortedStandard)) {
      _mode = _AbilityMode.standardArray;
      for (final entry in scores.entries) {
        _assignments[entry.key] = entry.value;
      }
      return;
    }

    final allDefaultTens = values.every((v) => v == 10);
    if (allDefaultTens) {
      _mode = _AbilityMode.standardArray;
      return;
    }

    final looksLikePointBuy =
        values.every((v) => v >= 8 && v <= 15) && _pointBuyCost(values) <= 27;
    if (looksLikePointBuy) {
      _mode = _AbilityMode.pointBuy;
      return;
    }

    _mode = _AbilityMode.custom;
  }

  bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int _pointBuyCost(List<int> values) {
    return values.fold(0, (sum, value) => sum + (_pointCosts[value] ?? 999));
  }

  @override
  void dispose() {
    for (final c in _customCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _pointsUsed {
    return _pointBuyScores.values.fold(
      0,
      (sum, score) => sum + (_pointCosts[score] ?? 0),
    );
  }

  int get _pointsLeft => 27 - _pointsUsed;

  void _adjustPointBuy(String key, int delta) {
    final current = _pointBuyScores[key]!;
    final next = current + delta;
    if (next < 8 || next > 15) return;

    final currentCost = _pointCosts[current] ?? 0;
    final nextCost = _pointCosts[next] ?? 0;
    if (_pointsLeft - (nextCost - currentCost) < 0) return;

    setState(() => _pointBuyScores[key] = next);
    _savePointBuy();
  }

  void _savePointBuy() {
    ref.read(creationProvider.notifier).setAbilityScores(
          str: _pointBuyScores['str']!,
          dex: _pointBuyScores['dex']!,
          con: _pointBuyScores['con']!,
          int_: _pointBuyScores['int']!,
          wis: _pointBuyScores['wis']!,
          cha: _pointBuyScores['cha']!,
        );
  }

  List<int> get _remainingValues {
    final assigned = _assignments.values.whereType<int>().toList();
    final pool = List<int>.from(_standardValues);
    for (final v in assigned) {
      pool.remove(v);
    }
    return pool;
  }

  bool get _isArrayComplete => _assignments.values.every((v) => v != null);

  void _assignValue(String key, int value) {
    final prev = _assignments.entries
        .where((e) => e.key != key && e.value == value)
        .map((e) => e.key)
        .firstOrNull;

    setState(() {
      if (prev != null) _assignments[prev] = null;
      _assignments[key] = value;
    });

    if (_isArrayComplete) {
      ref.read(creationProvider.notifier).setAbilityScores(
            str: _assignments['str']!,
            dex: _assignments['dex']!,
            con: _assignments['con']!,
            int_: _assignments['int']!,
            wis: _assignments['wis']!,
            cha: _assignments['cha']!,
          );
    }
  }

  void _resetArray() {
    setState(() {
      for (final k in _keys) {
        _assignments[k] = null;
      }
    });
  }

  void _saveCustom() {
    ref.read(creationProvider.notifier).setAbilityScores(
          str: int.tryParse(_customCtrl['str']!.text) ?? 10,
          dex: int.tryParse(_customCtrl['dex']!.text) ?? 10,
          con: int.tryParse(_customCtrl['con']!.text) ?? 10,
          int_: int.tryParse(_customCtrl['int']!.text) ?? 10,
          wis: int.tryParse(_customCtrl['wis']!.text) ?? 10,
          cha: int.tryParse(_customCtrl['cha']!.text) ?? 10,
        );
  }

  @override
  Widget build(BuildContext context) {
    final creation = ref.watch(creationProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (creation.backgroundAbilityOptions.isNotEmpty) ...[
          _buildBackgroundBonusSection(creation),
          const SizedBox(height: 16),
        ],
        SegmentedButton<_AbilityMode>(
          segments: const [
            ButtonSegment(
              value: _AbilityMode.standardArray,
              label: Text('Array'),
              icon: Icon(Icons.format_list_numbered),
            ),
            ButtonSegment(
              value: _AbilityMode.pointBuy,
              label: Text('Point Buy'),
              icon: Icon(Icons.toll),
            ),
            ButtonSegment(
              value: _AbilityMode.custom,
              label: Text('Custom'),
              icon: Icon(Icons.edit),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (val) {
            setState(() => _mode = val.first);
          },
          style: ButtonStyle(
            textStyle: WidgetStatePropertyAll(
              AppTextStyles.lato(fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.ashGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _modeDescription,
            style: AppTextStyles.lato(
              color: Colors.white54,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildModeContent(),
      ],
    );
  }
}
