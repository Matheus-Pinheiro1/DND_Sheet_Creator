import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';

Future<void> showDiceRollerSheet(
  BuildContext context, {
  int initialSides = 20,
  int initialModifier = 0,
  String title = 'Dice Roller',
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.ashGray,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _DiceRollerSheet(
      initialSides: initialSides,
      initialModifier: initialModifier,
      title: title,
    ),
  );
}

class _DiceRollerSheet extends StatefulWidget {
  final int initialSides;
  final int initialModifier;
  final String title;

  const _DiceRollerSheet({
    required this.initialSides,
    required this.initialModifier,
    required this.title,
  });

  @override
  State<_DiceRollerSheet> createState() => _DiceRollerSheetState();
}

class _DiceRollerSheetState extends State<_DiceRollerSheet> {
  final _random = Random();
  late int _sides;
  late int _modifier;
  int? _finalRoll;
  String _expression = '';
  String _historyLabel = '';
  final TextEditingController _expressionCtrl = TextEditingController();

  static const _dice = [4, 6, 8, 10, 12, 20, 100];
  static const _maxDiceCount = 100;
  static const _maxDiceSides = 1000;

  @override
  void initState() {
    super.initState();
    _sides = widget.initialSides;
    _modifier = widget.initialModifier;
    _syncExpressionFromSelection();
  }

  @override
  void dispose() {
    _expressionCtrl.dispose();
    super.dispose();
  }

  void _syncExpressionFromSelection() {
    _expression =
        '1d$_sides${_modifier == 0 ? '' : _modifier > 0 ? '+$_modifier' : '$_modifier'}';
    _expressionCtrl.text = _expression;
  }

  void _rollDefault() {
    _rollExpression(_expressionCtrl.text.trim().isEmpty
        ? _expression
        : _expressionCtrl.text.trim());
  }

  void _rollExpression(String input) {
    final parsed = _parseExpression(input);
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Use a formula like 1d20, 4d10+1d4+3, or 2d6-1.'),
        ),
      );
      return;
    }

    var total = 0;
    final pieces = <String>[];
    int? primaryRaw;

    for (final term in parsed.terms) {
      if (term.isDice) {
        final rolls = <int>[];
        for (var i = 0; i < term.count; i++) {
          rolls.add(_random.nextInt(term.sides) + 1);
        }
        if (primaryRaw == null && rolls.isNotEmpty) {
          primaryRaw = rolls.first;
        }
        final rollTotal = rolls.fold<int>(0, (sum, value) => sum + value);
        total += term.sign * rollTotal;
        pieces.add(
          '${term.signText}${term.count}d${term.sides} [${rolls.join(', ')}]',
        );
      } else {
        total += term.signedFlat;
        pieces.add('${term.signText}${term.flat.abs()}');
      }
    }

    setState(() {
      _expression = parsed.canonicalExpression;
      _expressionCtrl.text = parsed.canonicalExpression;
      _finalRoll = total;
      _historyLabel = pieces.join('  ');
      if (parsed.primarySides != null) {
        _sides = parsed.primarySides!;
      }
      _modifier = parsed.flatModifier;
    });
  }

  _ParsedRollExpression? _parseExpression(String input) {
    final compact = input.replaceAll(' ', '').toLowerCase();
    if (compact.isEmpty) return null;
    final normalized = compact.startsWith('-') ? '0$compact' : compact;
    final tokens = RegExp(r'[+-]?[^+-]+')
        .allMatches(normalized)
        .map((m) => m.group(0)!)
        .toList();
    if (tokens.isEmpty) return null;

    final terms = <_RollTerm>[];
    var flatModifier = 0;
    int? primarySides;

    for (final token in tokens) {
      final sign = token.startsWith('-') ? -1 : 1;
      final body = token.startsWith('+') || token.startsWith('-')
          ? token.substring(1)
          : token;
      if (body.isEmpty) return null;

      if (body.contains('d')) {
        final match = RegExp(r'^(\d*)d(\d+)$').firstMatch(body);
        if (match == null) return null;
        final count =
            int.tryParse(match.group(1)!.isEmpty ? '1' : match.group(1)!) ?? 1;
        final sides = int.tryParse(match.group(2)!) ?? 0;
        if (count <= 0 || sides <= 0) return null;
        if (count > _maxDiceCount || sides > _maxDiceSides) return null;
        primarySides ??= sides;
        terms.add(_RollTerm.dice(count: count, sides: sides, sign: sign));
      } else {
        final flat = int.tryParse(body);
        if (flat == null) return null;
        flatModifier += sign * flat;
        terms.add(_RollTerm.flat(flat: flat, sign: sign));
      }
    }

    final canonical = terms.map((term) => term.canonical).join();
    return _ParsedRollExpression(
      terms: terms,
      flatModifier: flatModifier,
      primarySides: primarySides,
      canonicalExpression:
          canonical.startsWith('+') ? canonical.substring(1) : canonical,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayExpression = _expressionCtrl.text.trim().isEmpty
        ? _expression
        : _expressionCtrl.text.trim();
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom + media.viewPadding.bottom;

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
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
                widget.title,
                style: AppTextStyles.cinzel(
                  color: AppTheme.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _dice
                    .map(
                      (die) => ChoiceChip(
                        label: Text('d$die'),
                        selected: _sides == die,
                        selectedColor: AppTheme.crimson,
                        onSelected: (_) => setState(() {
                          _sides = die;
                          _syncExpressionFromSelection();
                        }),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _expressionCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ex.: 4d10+1d4+3',
                  prefixIcon: Icon(Icons.functions),
                  isDense: true,
                ),
                onSubmitted: _rollExpression,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 6),
              Text(
                'Fixed bonus only. You can use notes like (STR + PB) out of the formula.',    
                style: AppTextStyles.lato(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _rollDefault,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.charcoal,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              displayExpression,
                              style: AppTextStyles.lato(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                _finalRoll?.toString() ?? '—',
                                key: ValueKey(_finalRoll),
                                style: AppTextStyles.cinzel(
                                  color: AppTheme.gold,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _historyLabel.isEmpty
                                  ? 'Tap to roll'
                                  : _historyLabel,
                              style: AppTextStyles.lato(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          _modifier++;
                          _syncExpressionFromSelection();
                        }),
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.white70),
                      ),
                      Text(
                        _modifier >= 0 ? '+$_modifier' : '$_modifier',
                        style: AppTextStyles.cinzel(
                          color: AppTheme.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          _modifier--;
                          _syncExpressionFromSelection();
                        }),
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _rollDefault,
                  icon: const Icon(Icons.casino),
                  label: Text(
                    'Roll ${displayExpression.isEmpty ? '1d$_sides' : displayExpression}',
                    style: AppTextStyles.cinzel(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParsedRollExpression {
  final List<_RollTerm> terms;
  final int flatModifier;
  final int? primarySides;
  final String canonicalExpression;

  const _ParsedRollExpression({
    required this.terms,
    required this.flatModifier,
    required this.primarySides,
    required this.canonicalExpression,
  });
}

class _RollTerm {
  final int sign;
  final int count;
  final int sides;
  final int flat;
  final bool isDice;

  const _RollTerm._({
    required this.sign,
    required this.count,
    required this.sides,
    required this.flat,
    required this.isDice,
  });

  factory _RollTerm.dice({
    required int count,
    required int sides,
    required int sign,
  }) {
    return _RollTerm._(
      sign: sign,
      count: count,
      sides: sides,
      flat: 0,
      isDice: true,
    );
  }

  factory _RollTerm.flat({
    required int flat,
    required int sign,
  }) {
    return _RollTerm._(
      sign: sign,
      count: 0,
      sides: 0,
      flat: flat,
      isDice: false,
    );
  }

  String get signText => sign < 0 ? '-' : '+';

  int get signedFlat => sign * flat;

  String get canonical =>
      isDice ? '$signText${count}d$sides' : '$signText${flat.abs()}';
}
