import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/utils/dice_calculator.dart';
import 'package:dnd_character_sheet/data/models/character_model.dart';
import 'package:dnd_character_sheet/providers/character_providers.dart';
import 'tabs/tab_main.dart';
import 'tabs/tab_combat.dart';
import 'tabs/tab_spells.dart';
import 'tabs/tab_equipment.dart';
import 'tabs/tab_notes.dart';
import 'tabs/tab_features.dart';
import '../shared/dialogs/dice_roller_sheet.dart';
import '../shared/widgets/character_avatar.dart';

class _TabDef {
  final String label;
  final IconData icon;
  final int index;
  const _TabDef(this.label, this.icon, this.index);
}

class CharacterSheetScreen extends ConsumerStatefulWidget {
  final String characterId;
  const CharacterSheetScreen({super.key, required this.characterId});

  @override
  ConsumerState<CharacterSheetScreen> createState() =>
      _CharacterSheetScreenState();
}

class _CharacterSheetScreenState extends ConsumerState<CharacterSheetScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _tabs = [
    _TabDef('Main', Icons.person_outline, 0),
    _TabDef('Combat', Icons.shield_outlined, 1),
    _TabDef('Spells', Icons.auto_awesome_outlined, 2),
    _TabDef('Features', Icons.menu_book_outlined, 3),
    _TabDef('Items', Icons.backpack_outlined, 4),
    _TabDef('Notes', Icons.notes_outlined, 5),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
    );

    _tabController.addListener(_onTabChange);
  }

  void _onTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _jumpToTab(int index) {
    _tabController.animateTo(index);

    if (_scaffoldKey.currentState?.isEndDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  void _closeSidebar() {
    if (_scaffoldKey.currentState?.isEndDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final character = ref.watch(characterByIdProvider(widget.characterId));

    if (character == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Character Not Found'),
          leading: _HomeIconButton(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🐉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'Character not found.',
                style: AppTextStyles.cinzel(
                  color: Colors.white54,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(character),
      endDrawer: _CharacterSidebar(
        character: character,
        currentTabIndex: _tabController.index,
        tabs: _tabs,
        onTabSelected: _jumpToTab,
        onClose: _closeSidebar,
        onEditCharacter: () {
          if (context.mounted) context.push('/create/${character.id}');
        },
        onOpenRoute: (route) {
          if (context.mounted) context.go(route);
        },
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(
          controller: _tabController,
          children: [
            TabMain(character: character),
            TabCombat(character: character),
            TabSpells(character: character),
            TabFeatures(character: character),
            TabEquipment(character: character),
            TabNotes(character: character),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dice_roller_fab',
        backgroundColor: AppTheme.crimson,
        onPressed: () => showDiceRollerSheet(context),
        child: const Icon(Icons.casino, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(CharacterModel character) {
    return AppBar(
      leading: _HomeIconButton(),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            character.name,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${character.raceName} ${character.classDisplayName} · Lv ${character.level}',
            style: AppTextStyles.lato(
              color: Colors.white54,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit Character',
          onPressed: () => context.push('/create/${character.id}'),
        ),
        IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Navigation',
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: false,
        tabs: _tabs
            .map((t) => Tab(
                  icon: Icon(t.icon, size: 18),
                  text: t.label,
                  iconMargin: const EdgeInsets.only(bottom: 2),
                ))
            .toList(),
      ),
    );
  }
}

class _CharacterSidebar extends ConsumerWidget {
  final CharacterModel character;
  final int currentTabIndex;
  final List<_TabDef> tabs;
  final void Function(int) onTabSelected;
  final VoidCallback onClose;
  final VoidCallback onEditCharacter;
  final ValueChanged<String> onOpenRoute;

  const _CharacterSidebar({
    required this.character,
    required this.currentTabIndex,
    required this.tabs,
    required this.onTabSelected,
    required this.onClose,
    required this.onEditCharacter,
    required this.onOpenRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profBonus = DiceCalculator.getProficiencyBonus(character.level);

    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SidebarHeader(character: character, profBonus: profBonus),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'NAVIGATE TO',
                  style: AppTextStyles.lato(
                    color: Colors.white30,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...tabs.map(
                (tab) => _SidebarNavTile(
                  tab: tab,
                  isActive: currentTabIndex == tab.index,
                  onTap: () => onTabSelected(tab.index),
                ),
              ),
              const Divider(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(
                  'ACTIONS',
                  style: AppTextStyles.lato(
                    color: Colors.white30,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: AppTheme.gold,
                  size: 20,
                ),
                title: Text(
                  'Edit Character',
                  style: AppTextStyles.lato(color: Colors.white, fontSize: 14),
                ),
                onTap: () {
                  onClose();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onEditCharacter();
                  });
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.library_books_outlined,
                  color: AppTheme.gold,
                  size: 20,
                ),
                title: Text(
                  'Rules References',
                  style: AppTextStyles.lato(color: Colors.white, fontSize: 14),
                ),
                onTap: () {
                  onClose();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onOpenRoute('/references');
                  });
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.pets_outlined,
                  color: AppTheme.gold,
                  size: 20,
                ),
                title: Text(
                  'Monster Compendium',
                  style: AppTextStyles.lato(color: Colors.white, fontSize: 14),
                ),
                onTap: () {
                  onClose();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onOpenRoute('/monsters');
                  });
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.home_outlined,
                  color: Colors.white54,
                  size: 20,
                ),
                title: Text(
                  'All Characters',
                  style:
                      AppTextStyles.lato(color: Colors.white70, fontSize: 14),
                ),
                onTap: () {
                  onClose();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onOpenRoute('/');
                  });
                },
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'D&D 5e Character Sheet\nData from dnd-data and local 2024 rules',
                  style: AppTextStyles.lato(
                    color: Colors.white24,
                    fontSize: 10,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final CharacterModel character;
  final int profBonus;

  const _SidebarHeader({
    required this.character,
    required this.profBonus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.darkBrown,
      ),
      child: Column(
        children: [
          CharacterAvatar(
            name: character.name,
            avatarChoice: character.avatarChoice,
            size: 72,
          ),
          const SizedBox(height: 12),
          Text(
            character.name,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${character.raceName} ${character.classDisplayName}',
            style: AppTextStyles.lato(
              color: Colors.white60,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickStat('LV', '${character.level}', AppTheme.gold),
              _QuickStat(
                'HP',
                '${character.currentHP}/${character.maxHP}',
                _hpColor(character),
              ),
              _QuickStat(
                  'AC', '${character.armorClass}', Colors.blueGrey.shade300),
              _QuickStat('PROF', '+$profBonus', Colors.greenAccent.shade400),
            ],
          ),
        ],
      ),
    );
  }

  Color _hpColor(CharacterModel c) {
    if (c.maxHP == 0) return Colors.white;
    final ratio = c.currentHP / c.maxHP;
    if (ratio > 0.5) return Colors.greenAccent;
    if (ratio > 0.25) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _QuickStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.cinzel(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.lato(
            color: Colors.white30,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _SidebarNavTile extends StatelessWidget {
  final _TabDef tab;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarNavTile({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: isActive
          ? BoxDecoration(
              color: AppTheme.crimson.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.crimson.withValues(alpha: 0.5),
              ),
            )
          : null,
      child: ListTile(
        dense: true,
        leading: Icon(
          tab.icon,
          color: isActive ? AppTheme.gold : Colors.white38,
          size: 20,
        ),
        title: Text(
          tab.label,
          style: AppTextStyles.lato(
            color: isActive ? AppTheme.gold : Colors.white70,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        trailing: isActive
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.gold,
                ),
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _HomeIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.home_outlined),
      color: AppTheme.gold,
      tooltip: 'Back to home',
      onPressed: () => context.go('/'),
    );
  }
}
