part of 'creation_wizard_screen.dart';

class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<IconData> stepIcons;
  final List<String> stepLabels;

  const _StepProgressBar({
    required this.currentStep,
    required this.totalSteps,
    required this.stepIcons,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isDone = i < currentStep;
          final isCurrent = i == currentStep;

          final color = isDone
              ? AppTheme.gold
              : isCurrent
                  ? AppTheme.crimson
                  : Colors.white12;

          return Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 32 : 24,
                  height: isCurrent ? 32 : 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: isCurrent
                        ? [
                            const BoxShadow(
                                color: AppTheme.crimson, blurRadius: 8)
                          ]
                        : null,
                  ),
                  child: Icon(
                    isDone ? Icons.check : stepIcons[i],
                    size: isCurrent ? 18 : 14,
                    color: Colors.white,
                  ),
                ),
                if (i < totalSteps - 1) const SizedBox(height: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavigationButtons extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool canAdvance;
  final bool isEditMode;
  final bool isLevelUpMode;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _NavigationButtons({
    required this.currentStep,
    required this.totalSteps,
    required this.canAdvance,
    required this.isEditMode,
    required this.isLevelUpMode,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == totalSteps - 1;
    final isFirstStep = currentStep == 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12)),
        color: AppTheme.charcoal,
      ),
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                label: Text('Back', style: AppTextStyles.lato()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white60,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          if (!isFirstStep) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: canAdvance ? onNext : null,
              icon: Icon(
                isLastStep ? Icons.save_outlined : Icons.arrow_forward_ios,
                size: 16,
              ),
              label: Text(
                isLastStep ? _lastStepLabel : 'Next',
                style: AppTextStyles.cinzel(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor:
                    isLastStep ? Colors.green.shade700 : AppTheme.crimson,
                disabledBackgroundColor: Colors.white10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _lastStepLabel {
    if (isLevelUpMode) return 'Apply Level Up';
    return isEditMode ? 'Save Changes' : 'Create Character';
  }
}
