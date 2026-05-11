import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/subclasses_2024_data_expanded.dart';
import '../../../data/services/artificer_choice_service.dart';
import '../../../data/services/barbarian_choice_service.dart';
import '../../../data/services/bard_choice_service.dart';
import '../../../data/services/cleric_choice_service.dart';
import '../../../data/services/druid_choice_service.dart';
import '../../../data/services/fighter_choice_service.dart';
import '../../../data/services/level_advancement_service.dart';
import '../../../data/services/monk_choice_service.dart';
import '../../../data/services/paladin_choice_service.dart';
import '../../../data/services/progression_service.dart';
import '../../../data/services/ranger_choice_service.dart';
import '../../../data/services/rogue_choice_service.dart';
import '../../../data/services/sorcerer_choice_service.dart';
import '../../../data/services/starting_equipment_service.dart';
import '../../../data/services/warlock_choice_service.dart';
import '../../../data/services/wizard_choice_service.dart';
import '../../../providers/character_providers.dart';
import '../../../providers/character_creation_provider.dart';
import 'steps/step_basic_info.dart';
import 'steps/step_race.dart';
import 'steps/step_class.dart';
import 'steps/step_background.dart';
import 'steps/step_equipment.dart';
import 'steps/step_ability_scores.dart';
import 'steps/step_skills.dart';
import 'steps/step_spells.dart';
import 'steps/step_advancements.dart';
import 'package:dnd_character_sheet/presentation/screens/shared/widgets/loading_dragon.dart';

part 'creation_wizard_validators.dart';
part 'creation_wizard_class_validators.dart';
part 'creation_wizard_spell_validators.dart';
part 'creation_wizard_widgets.dart';

class CreationWizardScreen extends ConsumerStatefulWidget {
  final String? editCharacterId;
  final bool levelUpMode;

  const CreationWizardScreen({
    super.key,
    this.editCharacterId,
    this.levelUpMode = false,
  });

  @override
  ConsumerState<CreationWizardScreen> createState() =>
      _CreationWizardScreenState();
}

class _CreationWizardScreenState extends ConsumerState<CreationWizardScreen> {
  bool _isEditMode = false;
  bool _isSaving = false;
  bool _hasLoadedEditCharacter = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.editCharacterId != null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);

    if (_isEditMode &&
        widget.editCharacterId != null &&
        (!_hasLoadedEditCharacter ||
            state.editingId != widget.editCharacterId)) {
      final existing =
          ref.watch(characterByIdProvider(widget.editCharacterId!));
      if (existing == null) {
        return Scaffold(
          backgroundColor: AppTheme.charcoal,
          appBar: AppBar(title: Text(_screenTitle)),
          body: Center(
            child: Text(
              'Character not found.',
              style: AppTextStyles.cinzel(color: Colors.white54),
            ),
          ),
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final current = ref.read(creationProvider);
        if (!_hasLoadedEditCharacter ||
            current.editingId != widget.editCharacterId) {
          final notifier = ref.read(creationProvider.notifier);
          if (widget.levelUpMode) {
            notifier.loadForLevelUp(existing);
          } else {
            notifier.loadFromCharacter(existing);
          }
          setState(() => _hasLoadedEditCharacter = true);
        }
      });

      return Scaffold(
        backgroundColor: AppTheme.charcoal,
        appBar: AppBar(title: Text(_screenTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LoadingDragon(label: 'Loading existing character...'),
              const SizedBox(height: 12),
              Text(
                'Loading existing character data...',
                style: AppTextStyles.lato(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    final currentStep = state.currentStep;
    final stepLabels = _stepLabels(state);
    final stepIcons = _stepIcons(state);
    final totalSteps = stepLabels.length;

    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      appBar: AppBar(
        title: Text(_screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: () {
            _confirmDiscard(context, notifier);
          },
        ),
      ),
      body: Column(
        children: [
          _StepProgressBar(
            currentStep: currentStep,
            totalSteps: totalSteps,
            stepIcons: stepIcons,
            stepLabels: stepLabels,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              stepLabels[currentStep],
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(currentStep, state),
            ),
          ),
          _NavigationButtons(
            currentStep: currentStep,
            totalSteps: totalSteps,
            canAdvance: !_isSaving && _canAdvance(currentStep, state),
            isEditMode: _isEditMode,
            isLevelUpMode: widget.levelUpMode,
            onBack: notifier.prevStep,
            onNext: () =>
                _handleNext(context, currentStep, totalSteps, notifier),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext(
    BuildContext context,
    int currentStep,
    int totalSteps,
    CreationNotifier notifier,
  ) async {
    final isLastStep = currentStep == totalSteps - 1;

    if (isLastStep) {
      await _saveCharacter(context);
    } else {
      notifier.nextStep();
    }
  }

  Future<void> _saveCharacter(BuildContext context) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final state = ref.read(creationProvider);
    final character = state.toCharacterModel();
    final notifier = ref.read(charactersProvider.notifier);

    try {
      if (_isEditMode) {
        await notifier.updateCharacter(character);

        if (!mounted || !context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.levelUpMode
                  ? '${character.name} reached level ${character.level}!'
                  : '${character.name} updated successfully!',
              style: AppTextStyles.lato(),
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        await notifier.addCharacter(character);
      }

      if (!mounted || !context.mounted) return;
      ref.read(creationProvider.notifier).reset();
      context.go('/character/${character.id}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _confirmDiscard(BuildContext context, CreationNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.ashGray,
        title: Text(
          'Discard changes?',
          style: AppTextStyles.cinzel(color: AppTheme.gold),
        ),
        content: Text(
          widget.levelUpMode
              ? 'This level-up progress will be lost.'
              : 'Your progress will be lost.',
          style: AppTextStyles.lato(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep editing',
              style: AppTextStyles.lato(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              notifier.reset();
              context.pop();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
            child: Text('Discard', style: AppTextStyles.lato()),
          ),
        ],
      ),
    );
  }
}
