import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigationDrawer extends StatelessWidget {
  final String selectedRoute;

  const AppNavigationDrawer({
    super.key,
    required this.selectedRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: AppTheme.darkBrown,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    color: AppTheme.gold,
                    size: 34,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'D&D Tools',
                    style: AppTextStyles.cinzel(
                      color: AppTheme.gold,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Characters and references',
                    style: AppTextStyles.lato(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerTile(
              icon: Icons.home_outlined,
              label: 'Characters',
              route: '/',
              selectedRoute: selectedRoute,
            ),
            _DrawerTile(
              icon: Icons.library_books_outlined,
              label: 'Rules References',
              route: '/references',
              selectedRoute: selectedRoute,
            ),
            _DrawerTile(
              icon: Icons.pets_outlined,
              label: 'Monster Compendium',
              route: '/monsters',
              selectedRoute: selectedRoute,
            ),
            _DrawerTile(
              icon: Icons.shield_outlined,
              label: 'Encounter',
              route: '/encounter',
              selectedRoute: selectedRoute,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String selectedRoute;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.route,
    required this.selectedRoute,
  });

  @override
  Widget build(BuildContext context) {
    final selected = route == selectedRoute;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: selected
          ? BoxDecoration(
              color: AppTheme.crimson.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.crimson.withValues(alpha: 0.5),
              ),
            )
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? AppTheme.gold : Colors.white54,
          size: 21,
        ),
        title: Text(
          label,
          style: AppTextStyles.lato(
            color: selected ? AppTheme.gold : Colors.white70,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () {
          Navigator.of(context).pop();
          if (!selected) context.go(route);
        },
      ),
    );
  }
}
