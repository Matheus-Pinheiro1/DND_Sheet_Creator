// lib/app.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/character_creation/creation_wizard_screen.dart';
import 'presentation/screens/character_sheet/character_sheet_screen.dart';
import 'presentation/screens/custom_options/custom_background_screen.dart';
import 'presentation/screens/custom_options/custom_race_screen.dart';
import 'presentation/screens/custom_options/custom_class_screen.dart';
import 'presentation/screens/monsters/monsters_screen.dart';
import 'presentation/screens/monsters/monster_details_screen.dart';
import 'presentation/screens/encounter/encounter_screen.dart';
import 'presentation/screens/references/reference_lists_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (ctx, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/create',
      builder: (ctx, state) => const CreationWizardScreen(),
    ),
    GoRoute(
      path: '/create/:id',
      builder: (ctx, state) {
        final id = state.pathParameters['id']!;
        return CreationWizardScreen(editCharacterId: id);
      },
    ),
    GoRoute(
      path: '/level-up/:id',
      builder: (ctx, state) {
        final id = state.pathParameters['id']!;
        return CreationWizardScreen(
          editCharacterId: id,
          levelUpMode: true,
        );
      },
    ),
    GoRoute(
      path: '/character/:id',
      builder: (ctx, state) {
        final id = state.pathParameters['id']!;
        return CharacterSheetScreen(characterId: id);
      },
    ),
    GoRoute(
      path: '/custom/race',
      builder: (ctx, state) => const CustomRaceScreen(),
    ),
    GoRoute(
      path: '/custom/background',
      builder: (ctx, state) => const CustomBackgroundScreen(),
    ),
    GoRoute(
      path: '/custom/class',
      builder: (ctx, state) => const CustomClassScreen(),
    ),
    GoRoute(
      path: '/monsters',
      builder: (ctx, state) => const MonstersScreen(),
    ),
    GoRoute(
      path: '/monsters/:index',
      builder: (ctx, state) =>
          MonsterDetailScreen(monsterIndex: state.pathParameters['index']!),
    ),
    GoRoute(
      path: '/encounter',
      builder: (ctx, state) => const EncounterScreen(),
    ),
    GoRoute(
      path: '/references',
      builder: (ctx, state) => const ReferenceListsScreen(),
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'D&D Character Sheet',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
