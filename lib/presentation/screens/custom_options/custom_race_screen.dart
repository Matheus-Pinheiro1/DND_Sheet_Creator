import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/custom_race_model.dart';
import '../../../providers/custom_options_providers.dart';

class CustomRaceScreen extends ConsumerStatefulWidget {
  final CustomRaceModel? existing;

  const CustomRaceScreen({super.key, this.existing});

  @override
  ConsumerState<CustomRaceScreen> createState() => _CustomRaceScreenState();
}

class _CustomRaceScreenState extends ConsumerState<CustomRaceScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _bonusCtrl;
  late final TextEditingController _descCtrl;

  late int _speed;
  late String _size;
  late List<String> _traits;
  late List<String> _languages;

  final _traitCtrl = TextEditingController();
  final _langCtrl = TextEditingController();

  static const _sizes = [
    'Tiny',
    'Small',
    'Medium',
    'Large',
    'Huge',
    'Gargantuan'
  ];

  bool get _isEditMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _bonusCtrl = TextEditingController(text: e?.abilityBonuses ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _speed = e?.speed ?? 30;
    _size = e?.size ?? 'Medium';
    _traits = List.from(e?.traits ?? []);
    _languages = List.from(e?.languages ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bonusCtrl.dispose();
    _descCtrl.dispose();
    _traitCtrl.dispose();
    _langCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final race = CustomRaceModel(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      speed: _speed,
      size: _size,
      traits: List.from(_traits),
      abilityBonuses: _bonusCtrl.text.trim(),
      languages: List.from(_languages),
      description: _descCtrl.text.trim(),
    );

    await ref.read(customRacesProvider.notifier).save(race);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${race.name} saved!',
            style: AppTextStyles.lato(color: Colors.white),
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _addTrait() {
    final v = _traitCtrl.text.trim();
    if (v.isEmpty) return;
    setState(() => _traits.add(v));
    _traitCtrl.clear();
  }

  void _addLanguage() {
    final v = _langCtrl.text.trim();
    if (v.isEmpty) return;
    setState(() => _languages.add(v));
    _langCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Species' : 'Create Custom Species'),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined, color: AppTheme.gold),
            label: Text(
              'Save',
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                'Custom species are stored locally on your device.\n'
                'They appear alongside official D&D species in the wizard.',
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Species Name *'),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Half-Dragon, Fey-Touched Human...',
                  prefixIcon: Icon(Icons.edit),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Species name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Speed (ft)'),
                      Row(children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _speed > 5
                              ? () => setState(() => _speed -= 5)
                              : null,
                          color: Colors.white54,
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.gold.withValues(alpha: 0.4),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_speed ft',
                              style: AppTextStyles.cinzel(
                                color: AppTheme.gold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => _speed += 5),
                          color: Colors.white54,
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Size'),
                      DropdownButtonFormField<String>(
                        initialValue: _size,
                        dropdownColor: AppTheme.ashGray,
                        decoration: const InputDecoration(isDense: true),
                        items: _sizes
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style:
                                        AppTextStyles.lato(color: Colors.white),
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _size = v);
                        },
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              const _SectionLabel('Ability Score Bonuses'),
              TextFormField(
                controller: _bonusCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. +2 STR, +1 CON',
                  prefixIcon: Icon(Icons.add_circle_outline),
                ),
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Racial Traits'),
              _TagListEditor(
                items: _traits,
                controller: _traitCtrl,
                hintText: 'e.g. Darkvision 60ft',
                addButtonLabel: 'Add Trait',
                onAdd: _addTrait,
                onRemove: (i) => setState(() => _traits.removeAt(i)),
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Languages'),
              _TagListEditor(
                items: _languages,
                controller: _langCtrl,
                hintText: 'e.g. Common, Draconic',
                addButtonLabel: 'Add Language',
                onAdd: _addLanguage,
                onRemove: (i) => setState(() => _languages.removeAt(i)),
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Description / Lore (optional)'),
              TextFormField(
                controller: _descCtrl,
                minLines: 3,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Backstory, origin, culture...',
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    _isEditMode ? 'Save Changes' : 'Create Species',
                    style: AppTextStyles.cinzel(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppTheme.gold, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.lato(
                color: Colors.white60,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagListEditor extends StatelessWidget {
  final List<String> items;
  final TextEditingController controller;
  final String hintText;
  final String addButtonLabel;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  const _TagListEditor({
    required this.items,
    required this.controller,
    required this.hintText,
    required this.addButtonLabel,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items
                .asMap()
                .entries
                .map((e) => Chip(
                      label: Text(
                        e.value,
                        style: AppTextStyles.lato(
                            color: Colors.white, fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      deleteIconColor: Colors.white54,
                      onDeleted: () => onRemove(e.key),
                      backgroundColor: AppTheme.ashGray,
                      side: const BorderSide(color: Colors.white24),
                    ))
                .toList(),
          ),
        if (items.isNotEmpty) const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                isDense: true,
              ),
              onSubmitted: (_) => onAdd(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            child: Text(
              addButtonLabel,
              style: AppTextStyles.lato(fontSize: 12),
            ),
          ),
        ]),
      ],
    );
  }
}
