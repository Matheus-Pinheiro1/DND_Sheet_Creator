part of '../tab_features.dart';

class _HeaderCard extends StatelessWidget {
  final int level;
  const _HeaderCard({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features unlocked up to level $level',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap any feature to read the full effect, action type, uses, and combat summary. Subclass features appear only when they are unlocked for this character.',
            style: AppTextStyles.lato(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ClassFeatureModel> features;

  const _LevelFeatureCard({
    required this.title,
    required this.subtitle,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppTheme.ashGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.lato(
                color: Colors.white38,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => showFeatureDetailDialog(context, feature),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.crimson,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.gold),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.menu_book_outlined,
                              size: 14,
                              color: AppTheme.gold,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                feature.name,
                                style: AppTextStyles.lato(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: Colors.white30),
                          ],
                        ),
                        if (feature.summary != null &&
                            feature.summary!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            feature.summary!,
                            style: AppTextStyles.lato(
                              color: Colors.white60,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFeaturesState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyFeaturesState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📚', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.cinzel(
                color: Colors.white54,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.lato(
                color: Colors.white38,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
