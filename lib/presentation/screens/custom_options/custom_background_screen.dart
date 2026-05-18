import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/custom_background_model.dart';
import '../../../providers/custom_options_providers.dart';

class CustomBackgroundScreen extends ConsumerStatefulWidget {
  final CustomBackgroundModel? existing;

  const CustomBackgroundScreen({super.key, this.existing});

  @override
  ConsumerState<CustomBackgroundScreen> createState() =>
      _CustomBackgroundScreenState();
}

class _CustomBackgroundScreenState
    extends ConsumerState<CustomBackgroundScreen> {
  static const _allSkills = {
    'acrobatics': 'Acrobatics',
    'animal-handling': 'Animal Handling',
    'arcana': 'Arcana',
    'athletics': 'Athletics',
    'deception': 'Deception',
    'history': 'History',
    'insight': 'Insight',
    'intimidation': 'Intimidation',
    'investigation': 'Investigation',
    'medicine': 'Medicine',
    'nature': 'Nature',
    'perception': 'Perception',
    'performance': 'Performance',
    'persuasion': 'Persuasion',
    'religion': 'Religion',
    'sleight-of-hand': 'Sleight of Hand',
    'stealth': 'Stealth',
    'survival': 'Survival',
  };

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _featureNameCtrl;
  late final TextEditingController _featureDescCtrl;
  late final TextEditingController _descCtrl;
  late List<String> _selectedSkills;

  bool get _isEditMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final background = widget.existing;
    _nameCtrl = TextEditingController(text: background?.name ?? '');
    _featureNameCtrl =
        TextEditingController(text: background?.featureName ?? '');
    _featureDescCtrl =
        TextEditingController(text: background?.featureDescription ?? '');
    _descCtrl = TextEditingController(text: background?.description ?? '');
    _selectedSkills =
        List<String>.from(background?.skillProficiencyIndices ?? const []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _featureNameCtrl.dispose();
    _featureDescCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final background = CustomBackgroundModel(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      skillProficiencyIndices: List<String>.from(_selectedSkills),
      featureName: _featureNameCtrl.text.trim(),
      featureDescription: _featureDescCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );

    await ref.read(customBackgroundsProvider.notifier).save(background);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${background.name} saved!'),
        backgroundColor: Colors.green.shade700,
      ),
    );
    Navigator.of(context).pop();
  }

  void _toggleSkill(String skillIndex) {
    setState(() {
      if (_selectedSkills.contains(skillIndex)) {
        _selectedSkills.remove(skillIndex);
      } else if (_selectedSkills.length < 2) {
        _selectedSkills.add(skillIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Background' : 'Create Background'),
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
                'Custom backgrounds appear alongside official ones.\n'
                'Select the exact D&D 5e skill names for compatibility.',
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Background Name *'),
              TextFormField(
                controller: _nameCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Guild Spy, Ship Captain...',
                  prefixIcon: Icon(Icons.history_edu_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Name is required'
                    : null,
                onChanged: (_) => _formKey.currentState?.validate(),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Skill Proficiencies (choose up to 2)'),
              Text(
                'Tap skills to toggle. Max 2 for balance.',
                style: AppTextStyles.lato(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allSkills.entries.map((entry) {
                  final isSelected = _selectedSkills.contains(entry.key);
                  return FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    selectedColor: AppTheme.crimson,
                    checkmarkColor: Colors.white,
                    onSelected: (_) => _toggleSkill(entry.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Feature Name'),
              TextFormField(
                controller: _featureNameCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Criminal Contact',
                ),
              ),
              const SizedBox(height: 12),
              const _SectionLabel('Feature Description'),
              TextFormField(
                controller: _featureDescCtrl,
                minLines: 3,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'What does this feature allow the character to do?',
                ),
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Description (optional)'),
              TextFormField(
                controller: _descCtrl,
                minLines: 3,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Background lore, personality suggestions...',
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    _isEditMode ? 'Save Changes' : 'Create Background',
                    style: AppTextStyles.cinzel(fontWeight: FontWeight.bold),
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
