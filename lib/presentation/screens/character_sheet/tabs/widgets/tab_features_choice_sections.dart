part of '../tab_features.dart';

class _SingleChoiceSection extends StatelessWidget {
  final String title;
  final List<(String, String)> options;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const _SingleChoiceSection({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (option) => ChoiceChip(
                    label: Text(option.$2),
                    selected: selectedValue == option.$1,
                    selectedColor: AppTheme.crimson,
                    onSelected: (_) => onChanged(option.$1),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MultiChoiceSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<(String, String)> options;
  final List<String> selectedValues;
  final int maxSelections;
  final ValueChanged<List<String>> onChanged;

  const _MultiChoiceSection({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedValues,
    required this.maxSelections,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.lato(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final selected = selectedValues.contains(option.$1);
              final disabled =
                  !selected && selectedValues.length >= maxSelections;
              return FilterChip(
                label: Text(option.$2),
                selected: selected,
                selectedColor: AppTheme.crimson,
                onSelected: disabled
                    ? null
                    : (value) {
                        final updated = List<String>.from(selectedValues);
                        if (value) {
                          updated.add(option.$1);
                        } else {
                          updated.remove(option.$1);
                        }
                        onChanged(updated);
                      },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
