import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysihat/core/widgets/responsive_shell.dart';

void main() {
  group('BrandedSidebar (prototype glass sidebar)', () {
    testWidgets('renders the brand wordmark and every destination label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: BrandedSidebar(
                brandName: 'MySihat',
                selectedIndex: 0,
                onSelect: (_) {},
                destinations: const [
                  ShellDestination(icon: Icons.favorite_border, selectedIcon: Icons.favorite, label: 'My Health'),
                  ShellDestination(
                    icon: Icons.checklist_outlined,
                    selectedIcon: Icons.checklist,
                    label: 'My Roadmap',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      check(find.text('MySihat').evaluate().length).equals(1);
      check(find.text('My Health').evaluate().length).equals(1);
      check(find.text('My Roadmap').evaluate().length).equals(1);
      check(tester.takeException()).isNull();
    });

    testWidgets('invokes onSelect with the tapped destination index', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: BrandedSidebar(
                brandName: 'MySihat',
                selectedIndex: 0,
                onSelect: (index) => tapped = index,
                destinations: const [
                  ShellDestination(icon: Icons.favorite_border, selectedIcon: Icons.favorite, label: 'My Health'),
                  ShellDestination(
                    icon: Icons.checklist_outlined,
                    selectedIcon: Icons.checklist,
                    label: 'My Roadmap',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('My Roadmap'));
      await tester.pumpAndSettle();

      check(tapped).equals(1);
    });
  });
}
