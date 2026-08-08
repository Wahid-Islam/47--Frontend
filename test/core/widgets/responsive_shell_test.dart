import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysihat/core/widgets/responsive_shell.dart';

void main() {
  group('BrandedSidebar (Variation 1 wide-screen sidebar)', () {
    testWidgets('renders the brand wordmark and every destination label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: BrandedSidebar(
                brandName: 'mysihat',
                selectedIndex: 0,
                onSelect: (_) {},
                destinations: const [
                  ShellDestination(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Overview'),
                  ShellDestination(
                    icon: Icons.insights_outlined,
                    selectedIcon: Icons.insights,
                    label: 'Personal Insights',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      check(find.text('mysihat').evaluate().length).equals(1);
      check(find.text('Overview').evaluate().length).equals(1);
      check(find.text('Personal Insights').evaluate().length).equals(1);
      // Extended NavigationRail must be constructed without triggering the
      // `!extended || labelType == none` assertion.
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
                brandName: 'mysihat',
                selectedIndex: 0,
                onSelect: (index) => tapped = index,
                destinations: const [
                  ShellDestination(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Overview'),
                  ShellDestination(
                    icon: Icons.insights_outlined,
                    selectedIcon: Icons.insights,
                    label: 'Personal Insights',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Personal Insights'));
      await tester.pumpAndSettle();

      check(tapped).equals(1);
    });
  });
}
