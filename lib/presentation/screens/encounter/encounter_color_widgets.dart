part of 'encounter_screen.dart';

class _EncounterColorIndicator extends StatelessWidget {
  final int colorTag;
  final bool isActive;

  const _EncounterColorIndicator({
    required this.colorTag,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = encounterColorForTag(colorTag);

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isActive ? 0.24 : 0.10),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? color : color.withValues(alpha: 0.75),
          width: isActive ? 2 : 1.5,
        ),
      ),
      child: isActive ? Icon(Icons.check, color: color, size: 13) : null,
    );
  }
}

class _EncounterRenameTile extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _EncounterRenameTile({
    required this.controller,
    required this.focusNode,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkBrown.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Encounter name',
                isDense: true,
              ),
              onSubmitted: (_) => onSave(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Cancel',
            onPressed: onCancel,
            icon: const Icon(Icons.close),
            color: Colors.white54,
          ),
          IconButton(
            tooltip: 'Save',
            onPressed: onSave,
            icon: const Icon(Icons.check),
            color: AppTheme.gold,
          ),
        ],
      ),
    );
  }
}

class _EncounterColorSheet extends StatelessWidget {
  final EncounterModel encounter;
  final void Function(int colorTag) onSelected;

  const _EncounterColorSheet({
    required this.encounter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Encounter Color',
                style: AppTextStyles.cinzel(
                  color: AppTheme.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                encounter.name,
                style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              _ColorTagPicker(
                selectedColor: encounter.colorTag,
                onSelected: (colorTag) {
                  onSelected(colorTag);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
