import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dice_calculator.dart';
import '../../../data/models/character_model.dart';
import '../../../data/models/encounter_model.dart';
import '../../../data/remote/spell_dto.dart';
import '../../../providers/character_providers.dart';
import '../../../providers/dnd_api_providers.dart';
import '../../../providers/encounter_providers.dart';
import '../shared/widgets/app_navigation_drawer.dart';
import '../shared/widgets/character_avatar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _prefetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefetched) return;
    _prefetched = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final classIndex in const [
        'bard',
        'cleric',
        'druid',
        'paladin',
        'ranger',
        'sorcerer',
        'warlock',
        'wizard',
      ]) {
        ref.read(classSpellsProvider(classIndex).future).catchError(
              (_) => <SpellDto>[],
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final characters = ref.watch(charactersProvider);
    final encounter = ref.watch(encounterProvider);
    final encounterNotifier = ref.read(encounterProvider.notifier);
    final bannerEncounter = _bannerEncounter(
      encounter,
      encounterNotifier.encounters,
    );
    final encounterBanner = bannerEncounter == null
        ? null
        : _ActiveEncounterBanner(
            encounterName: bannerEncounter.name,
            participantCount: bannerEncounter.participants.length,
            currentRound: bannerEncounter.currentRound,
            currentName: bannerEncounter.currentParticipant?.name ?? '',
            onTap: () {
              if (encounterNotifier.activeEncounterId != bannerEncounter.id) {
                encounterNotifier.selectEncounter(bannerEncounter.id);
              }
              context.push('/encounter');
            },
          );

    return Scaffold(
      drawer: const AppNavigationDrawer(selectedRoute: '/'),
      appBar: AppBar(
        title: const Text('⚔️ D&D Character Sheet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books_outlined),
            tooltip: 'Rules References',
            onPressed: () => context.push('/references'),
          ),
          IconButton(
            icon: const Icon(Icons.pets_outlined),
            tooltip: 'Monster Compendium',
            onPressed: () => context.push('/monsters'),
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Encounter',
            onPressed: () => context.push('/encounter'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: characters.isEmpty
          ? Column(
              children: [
                if (encounterBanner != null) encounterBanner,
                Expanded(child: _buildEmptyState(context)),
              ],
            )
          : _buildCharacterList(
              context,
              characters,
              encounterBanner: encounterBanner,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create'),
        backgroundColor: AppTheme.crimson,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Character',
          style: AppTextStyles.cinzel(color: Colors.white),
        ),
      ),
    );
  }

  EncounterModel? _bannerEncounter(
    EncounterModel activeEncounter,
    List<EncounterModel> encounters,
  ) {
    if (!activeEncounter.isEmpty) return activeEncounter;
    for (final encounter in encounters) {
      if (!encounter.isEmpty) return encounter;
    }
    return null;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🐉', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          Text(
            'No adventurers yet',
            style: AppTextStyles.cinzel(
              fontSize: 24,
              color: AppTheme.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to forge your first character',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterList(
    BuildContext context,
    List<CharacterModel> characters, {
    required Widget? encounterBanner,
  }) {
    final offset = encounterBanner == null ? 0 : 1;
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: characters.length + offset,
      itemBuilder: (ctx, i) {
        if (encounterBanner != null && i == 0) {
          return encounterBanner;
        }
        return _CharacterCard(character: characters[i - offset]);
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'D&D Character Sheet',
      applicationVersion: '1.5.0',
      applicationLegalese: 'D&D Character Sheet fan-made app by Pinhas',
    );
  }
}

class _ActiveEncounterBanner extends StatelessWidget {
  final String encounterName;
  final int participantCount;
  final int currentRound;
  final String currentName;
  final VoidCallback onTap;

  const _ActiveEncounterBanner({
    required this.encounterName,
    required this.participantCount,
    required this.currentRound,
    required this.currentName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final participantLabel =
        '$participantCount participant${participantCount == 1 ? '' : 's'}';
    final subtitle = currentName.isEmpty
        ? participantLabel
        : '$participantLabel - $currentName\'s turn';
    final title =
        encounterName.trim().isEmpty ? 'Active Encounter' : encounterName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: AppTheme.darkBrown,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.45)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.crimson.withValues(alpha: 0.28),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.65),
                    ),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppTheme.gold,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
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
                      const SizedBox(height: 3),
                      Text(
                        'Round $currentRound - $subtitle',
                        style: AppTextStyles.lato(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterCard extends ConsumerWidget {
  final CharacterModel character;
  const _CharacterCard({required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/character/${character.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CharacterAvatar(
                  name: character.name,
                  avatarChoice: character.avatarChoice,
                  size: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: AppTextStyles.cinzel(
                        fontSize: 18,
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${character.raceName} ${character.classDisplayName} • Level ${character.level}',
                      style: AppTextStyles.lato(
                          color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _MiniStat(
                            label: 'HP',
                            value: '${character.currentHP}/${character.maxHP}'),
                        const SizedBox(width: 16),
                        _MiniStat(
                            label: 'AC', value: '${character.armorClass}'),
                        const SizedBox(width: 16),
                        _MiniStat(
                          label: 'PROF',
                          value:
                              '+${DiceCalculator.getProficiencyBonus(character.level)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                onSelected: (val) {
                  if (val == 'level_up') {
                    context.push('/level-up/${character.id}');
                  }
                  if (val == 'edit') context.push('/create/${character.id}');
                  if (val == 'delete') _confirmDelete(context, ref);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'level_up',
                    enabled: character.level < 20,
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          character.level < 20 ? 'Level Up' : 'Level Up (max)',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${character.name}?', style: AppTextStyles.cinzel()),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(charactersProvider.notifier)
                    .deleteCharacter(character.id);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not delete character.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.lato(color: Colors.white38, fontSize: 10),
        ),
        Text(
          value,
          style: AppTextStyles.cinzel(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
