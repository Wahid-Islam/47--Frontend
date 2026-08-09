import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../view/widgets/design_accents.dart';
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
/// bottom [NavigationBar] on phones; branded glass sidebar on tablet+.
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({
    super.key,
    required this.navigationShell,
    required this.destinations,
    this.brandName = 'MySihat',
    this.tagline = 'Small changes today, healthier tomorrow.',
  });

  final StatefulNavigationShell navigationShell;
  final List<ShellDestination> destinations;
  final String brandName;
  final String tagline;

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
            backgroundColor: AppTheme.background,
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
          backgroundColor: AppTheme.background,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF7FAF8), Color(0xFFEAF3EE), Color(0xFFF6F3EF)],
              ),
            ),
            child: Row(
              children: [
                BrandedSidebar(
                  brandName: brandName,
                  tagline: tagline,
                  selectedIndex: navigationShell.currentIndex,
                  destinations: destinations,
                  onSelect: _onSelect,
                ),
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
          ),
        );
      },
    );
  }
}

/// Prototype-style glass sidebar: brand mark, nav items, footer tagline.
class BrandedSidebar extends StatelessWidget {
  const BrandedSidebar({
    super.key,
    required this.brandName,
    required this.selectedIndex,
    required this.destinations,
    required this.onSelect,
    this.tagline = 'Small changes today, healthier tomorrow.',
  });

  final String brandName;
  final String tagline;
  final int selectedIndex;
  final List<ShellDestination> destinations;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 215,
      margin: const EdgeInsets.fromLTRB(14, 14, 0, 14),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        boxShadow: const [BoxShadow(color: Color(0x14223948), blurRadius: 30, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2F9B67), Color(0xFF17683F)],
                  ),
                  boxShadow: const [BoxShadow(color: Color(0x332F9B67), blurRadius: 16, offset: Offset(0, 6))],
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  brandName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    height: 1.1,
                    color: AppTheme.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Expanded(
            child: ListView.separated(
              itemCount: destinations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final d = destinations[index];
                final selected = index == selectedIndex;
                return Material(
                  color: selected ? AppTheme.navActive : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onSelect(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? const Color(0xFFD7EBDD) : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected ? d.selectedIcon : d.icon,
                            size: 18,
                            color: selected ? AppTheme.primaryDark : const Color(0xFF344256),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              d.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: selected ? AppTheme.primaryDark : const Color(0xFF344256),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SidebarPromoCard(message: tagline),
        ],
      ),
    );
  }
}
