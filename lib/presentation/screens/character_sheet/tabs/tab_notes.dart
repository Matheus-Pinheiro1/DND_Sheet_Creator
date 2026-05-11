import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/character_model.dart';
import '../../../../providers/character_providers.dart';

class TabNotes extends ConsumerStatefulWidget {
  final CharacterModel character;
  const TabNotes({super.key, required this.character});
  @override
  ConsumerState<TabNotes> createState() => _TabNotesState();
}

class _TabNotesState extends ConsumerState<TabNotes> {
  late final TextEditingController _notesCtrl;
  late final TextEditingController _backstoryCtrl;
  late final TextEditingController _traitsCtrl;
  late final TextEditingController _idealsCtrl;
  late final TextEditingController _bondsCtrl;
  late final TextEditingController _flawsCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.character;
    _notesCtrl = TextEditingController(text: c.notes);
    _backstoryCtrl = TextEditingController(text: c.backstory);
    _traitsCtrl = TextEditingController(text: c.personalityTraits);
    _idealsCtrl = TextEditingController(text: c.ideals);
    _bondsCtrl = TextEditingController(text: c.bonds);
    _flawsCtrl = TextEditingController(text: c.flaws);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _backstoryCtrl.dispose();
    _traitsCtrl.dispose();
    _idealsCtrl.dispose();
    _bondsCtrl.dispose();
    _flawsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await ref.read(charactersProvider.notifier).updateCharacter(
            widget.character.copyWith(
              notes: _notesCtrl.text,
              backstory: _backstoryCtrl.text,
              personalityTraits: _traitsCtrl.text,
              ideals: _idealsCtrl.text,
              bonds: _bondsCtrl.text,
              flaws: _flawsCtrl.text,
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notes saved.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save notes.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _TextSection('Personality Traits', _traitsCtrl),
        _TextSection('Ideals', _idealsCtrl),
        _TextSection('Bonds', _bondsCtrl),
        _TextSection('Flaws', _flawsCtrl),
        _TextSection('Backstory', _backstoryCtrl, minLines: 5),
        _TextSection('Notes', _notesCtrl, minLines: 5),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('Save Notes'),
          style:
              ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ]),
    );
  }
}

class _TextSection extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final int minLines;
  const _TextSection(this.label, this.ctrl, {this.minLines = 3});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          minLines: minLines,
          maxLines: null,
          decoration: const InputDecoration(),
          style: AppTextStyles.lato(color: Colors.white, fontSize: 14),
        ),
      ]),
    );
  }
}
