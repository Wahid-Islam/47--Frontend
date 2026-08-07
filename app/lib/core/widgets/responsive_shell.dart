import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../responsive/breakpoints.dart';
import '../theme/app_theme.dart';

/// Describes a single destination in the app's bottom navigation /
/// navigation rail shell.
class ShellDestination {
  const ShellDestination({required this.icon, required this.selectedIcon, required this.label});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Adaptive navigation shell for [StatefulShellRoute.indexedStack]:
/// a bottom [NavigationBar] on phones, and — per the mysihat "Variation 1"
/// design — a richer branded left sidebar (extended [NavigationRail] with
/// a "mysihat" header) on tablets/desktop. Wraps the `go_router`
/// [StatefulNavigationShell] so switching branches preserves each
/// branch's own navigation stack and scroll position.
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({
    super.key,
    required this.navigationShell,
    required this.destinations,
    this.brandName = 'mysihat',
  });

  final StatefulNavigationShell navigationShell;
  final List<ShellDestination> destinations;

  /// Brand wordmark shown at the top of the wide-screen sidebar
  /// (Variation 1 layout). Not localized — it's a product name.
  final String brandName;

  void _onSelect(int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= Breakpoints.tablet;
        if (!isWide) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              height: 72,
              onDestinationSelected: _onSelect,
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              BrandedSidebar(
                brandName: brandName,
                selectedIndex: navigationShell.currentIndex,
                destinations: destinations,
                onSelect: _onSelect,
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: Breakpoints.contentMaxWidth),
                    child: navigationShell,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Variation-1 wide-screen sidebar: brand wordmark + logo mark at the top,
/// an extended [NavigationRail] below it so every destination shows both
/// icon and label at all times (not just when selected).
///
/// Public (not `_`-private) so it can be widget-tested in isolation,
/// without needing a real `go_router` [StatefulNavigationShell].
class BrandedSidebar extends StatelessWidget {
  const BrandedSidebar({
    super.key,
    required this.brandName,
    required this.selectedIndex,
    required this.destinations,
    required this.onSelect,
  });

  final String brandName;
  final int selectedIndex;
  final List<ShellDestination> destinations;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      color: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.eco_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    brandName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.lora(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          Expanded(
            child: NavigationRail(
              backgroundColor: AppTheme.surface,
              extended: true,
              minExtendedWidth: 232,
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelect,
              labelType: NavigationRailLabelType.none,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
