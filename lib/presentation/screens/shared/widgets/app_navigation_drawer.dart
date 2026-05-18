import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppNavigationDrawer extends StatefulWidget {
  final String selectedRoute;
  final ValueChanged<String> onNavigate;

  const AppNavigationDrawer({
    super.key,
    required this.selectedRoute,
    required this.onNavigate,
  });

  @override
  State<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
  late NavigatorState _navigator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigator = Navigator.of(context);
  }

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
              selectedRoute: widget.selectedRoute,
              onClose: _navigator.pop,
              onNavigate: widget.onNavigate,
            ),
            _DrawerTile(
              icon: Icons.library_books_outlined,
              label: 'Rules References',
              route: '/references',
              selectedRoute: widget.selectedRoute,
              onClose: _navigator.pop,
              onNavigate: widget.onNavigate,
            ),
            _DrawerTile(
              icon: Icons.pets_outlined,
              label: 'Monster Compendium',
              route: '/monsters',
              selectedRoute: widget.selectedRoute,
              onClose: _navigator.pop,
              onNavigate: widget.onNavigate,
            ),
            _DrawerTile(
              icon: Icons.shield_outlined,
              label: 'Encounter',
              route: '/encounter',
              selectedRoute: widget.selectedRoute,
              onClose: _navigator.pop,
              onNavigate: widget.onNavigate,
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
  final VoidCallback onClose;
  final ValueChanged<String> onNavigate;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.route,
    required this.selectedRoute,
    required this.onClose,
    required this.onNavigate,
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
          onClose();
          if (selected) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onNavigate(route);
          });
        },
      ),
    );
  }
}
