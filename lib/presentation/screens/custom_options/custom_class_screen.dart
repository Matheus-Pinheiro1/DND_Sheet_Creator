import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/custom_class_model.dart';
import '../../../providers/custom_options_providers.dart';

class CustomClassScreen extends ConsumerStatefulWidget {
  final CustomClassModel? existing;
  const CustomClassScreen({super.key, this.existing});

  @override
  ConsumerState<CustomClassScreen> createState() => _CustomClassScreenState();
}

class _CustomClassScreenState extends ConsumerState<CustomClassScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late int _hitDie;
  String? _spellAbility;
  late List<String> _savingThrows;
  late List<String> _features;
  late List<String> _proficiencies;
  final _featureCtrl = TextEditingController();
  final _profCtrl = TextEditingController();

  static const _saveOptions = ['str', 'dex', 'con', 'int', 'wis', 'cha'];
  static const _spellOptions = [null, 'int', 'wis', 'cha'];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _hitDie = e?.hitDie ?? 8;
    _spellAbility = e?.spellcastingAbility;
    _savingThrows = List<String>.from(e?.savingThrows ?? const ['str', 'con']);
    _features = List<String>.from(e?.features ?? const []);
    _proficiencies = List<String>.from(e?.proficiencies ?? const []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _featureCtrl.dispose();
    _profCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final model = CustomClassModel(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      hitDie: _hitDie,
      savingThrows: List<String>.from(_savingThrows),
      spellcastingAbility: _spellAbility,
      description: _descCtrl.text.trim(),
      features: List<String>.from(_features),
      proficiencies: List<String>.from(_proficiencies),
    );
    await ref.read(customClassesProvider.notifier).save(model);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${model.name} saved!')),
    );
    Navigator.of(context).pop();
  }

  void _addFeature() {
    final value = _featureCtrl.text.trim();
    if (value.isEmpty) return;
    setState(() => _features.add(value));
    _featureCtrl.clear();
  }

  void _addProf() {
    final value = _profCtrl.text.trim();
    if (value.isEmpty) return;
    setState(() => _proficiencies.add(value));
    _profCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Homebrew Class' : 'Create Homebrew Class'),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined, color: AppTheme.gold),
            label:
                Text('Save', style: AppTextStyles.cinzel(color: AppTheme.gold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _InfoBanner(
                'Homebrew classes are stored locally and appear with official classes in the class step.',
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Class Name *'),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Blood Hunter',
                  prefixIcon: Icon(Icons.auto_fix_high),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Class name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('Hit Die'),
                        DropdownButtonFormField<int>(
                          initialValue: _hitDie,
                          dropdownColor: AppTheme.ashGray,
                          items: const [6, 8, 10, 12]
                              .map((d) => DropdownMenuItem(
                                  value: d, child: Text('d$d')))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _hitDie = value ?? 8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('Spellcasting Ability'),
                        DropdownButtonFormField<String?>(
                          initialValue: _spellAbility,
                          dropdownColor: AppTheme.ashGray,
                          items: _spellOptions
                              .map((ability) => DropdownMenuItem<String?>(
                                    value: ability,
                                    child: Text(ability == null
                                        ? 'None'
                                        : ability.toUpperCase()),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _spellAbility = value),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Saving Throws'),
              Wrap(
                spacing: 8,
                children: _saveOptions.map((ability) {
                  final selected = _savingThrows.contains(ability);
                  return FilterChip(
                    label: Text(ability.toUpperCase()),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          if (!_savingThrows.contains(ability)) {
                            _savingThrows.add(ability);
                          }
                        } else {
                          _savingThrows.remove(ability);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Class Features'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _featureCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Add feature name',
                        prefixIcon: Icon(Icons.star_outline),
                      ),
                      onSubmitted: (_) => _addFeature(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                      onPressed: _addFeature, child: const Text('Add')),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _features.asMap().entries.map((entry) {
                  return InputChip(
                    label: Text(entry.value),
                    onDeleted: () =>
                        setState(() => _features.removeAt(entry.key)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Extra Proficiencies'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _profCtrl,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Martial Weapons',
                        prefixIcon: Icon(Icons.shield_outlined),
                      ),
                      onSubmitted: (_) => _addProf(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _addProf, child: const Text('Add')),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _proficiencies.asMap().entries.map((entry) {
                  return InputChip(
                    label: Text(entry.value),
                    onDeleted: () =>
                        setState(() => _proficiencies.removeAt(entry.key)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Description'),
              TextFormField(
                controller: _descCtrl,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText:
                      'Write the class overview, core fantasy, and special rules...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.cinzel(
          color: AppTheme.gold,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.gold,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold),
      ),
      child: Text(
        text,
        style: AppTextStyles.lato(
            color: Colors.white70, fontSize: 12, height: 1.45),
      ),
    );
  }
}
