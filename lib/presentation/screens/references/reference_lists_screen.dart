import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/data/local/choice_lists_data.dart';
import 'package:dnd_character_sheet/presentation/screens/shared/widgets/app_navigation_drawer.dart';
import 'package:flutter/material.dart';

class ReferenceListsScreen extends StatefulWidget {
  const ReferenceListsScreen({super.key});

  @override
  State<ReferenceListsScreen> createState() => _ReferenceListsScreenState();
}

class _ReferenceListsScreenState extends State<ReferenceListsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  static final _lists = <_ReferenceListDef>[
    _ReferenceListDef(
      label: 'Metamagic',
      icon: Icons.auto_awesome_outlined,
      entries: () => ChoiceListsData.metamagicOptions,
    ),
    _ReferenceListDef(
      label: 'Maneuvers',
      icon: Icons.sports_martial_arts_outlined,
      entries: () => ChoiceListsData.battleMasterManeuvers,
    ),
    _ReferenceListDef(
      label: 'Masteries',
      icon: Icons.gavel_outlined,
      entries: () => ChoiceListsData.weaponMasteries,
    ),
    _ReferenceListDef(
      label: 'Invocations',
      icon: Icons.dark_mode_outlined,
      entries: () => ChoiceListsData.eldritchInvocations,
    ),
    _ReferenceListDef(
      label: 'Wild Magic',
      icon: Icons.flare_outlined,
      entries: () => ChoiceListsData.wildMagicSurges,
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _lists.length,
      child: Scaffold(
        drawer: const AppNavigationDrawer(selectedRoute: '/references'),
        appBar: AppBar(
          title: const Text('Rules References'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _lists
                .map(
                  (list) => Tab(
                    icon: Icon(list.icon, size: 18),
                    text: list.label,
                    iconMargin: const EdgeInsets.only(bottom: 2),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search references...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() => _query = value.trim().toLowerCase());
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: _lists
                    .map(
                      (list) => _ReferenceListView(
                        def: list,
                        query: _query,
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceListDef {
  final String label;
  final IconData icon;
  final List<ChoiceListEntry> Function() entries;

  const _ReferenceListDef({
    required this.label,
    required this.icon,
    required this.entries,
  });
}

class _ReferenceListView extends StatelessWidget {
  final _ReferenceListDef def;
  final String query;

  const _ReferenceListView({
    required this.def,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries(def.entries(), query);

    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No references found.',
          style: AppTextStyles.lato(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: entries.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
              style: AppTextStyles.lato(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          );
        }

        return _ReferenceEntryCard(entry: entries[index - 1]);
      },
    );
  }

  static List<ChoiceListEntry> _filteredEntries(
    List<ChoiceListEntry> entries,
    String query,
  ) {
    if (query.isEmpty) return entries;

    return entries.where((entry) {
      final searchable = [
        entry.id,
        entry.name,
        entry.roll,
        entry.summary,
        entry.description,
        entry.costLabel,
        entry.prerequisite,
        entry.source,
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList(growable: false);
  }
}

class _ReferenceEntryCard extends StatelessWidget {
  final ChoiceListEntry entry;

  const _ReferenceEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final metadata = [
      if (entry.roll.isNotEmpty) entry.roll,
      if (entry.costLabel.isNotEmpty) entry.costLabel,
      if (entry.prerequisite.isNotEmpty) entry.prerequisite,
      if (entry.source.isNotEmpty) entry.source,
    ];
    final hasDescription = entry.description.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(14, 4, 10, 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: AppTheme.gold,
          collapsedIconColor: Colors.white38,
          title: Text(
            entry.name,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (metadata.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: metadata.map(_ReferenceTag.new).toList(),
                  ),
                if (entry.summary.isNotEmpty) ...[
                  SizedBox(height: metadata.isEmpty ? 0 : 8),
                  Text(
                    entry.summary,
                    style: AppTextStyles.lato(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          children: [
            if (hasDescription)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  entry.description,
                  style: AppTextStyles.lato(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No description.',
                  style: AppTextStyles.lato(
                    color: Colors.white38,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceTag extends StatelessWidget {
  final String label;

  const _ReferenceTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.darkBrown.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.lato(
          color: Colors.white60,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
