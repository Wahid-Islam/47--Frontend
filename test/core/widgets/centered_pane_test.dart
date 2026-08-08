import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysihat/core/widgets/centered_pane.dart';

void main() {
  const childKey = Key('pane-child');

  /// Pumps a [CenteredPane] filling a [width]-wide window and returns the
  /// size the child was actually given.
  Future<Size> pumpAtWidth(WidgetTester tester, double width, {double? maxWidth}) async {
    await tester.binding.setSurfaceSize(Size(width, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CenteredPane(
            maxWidth: maxWidth ?? CenteredPane.formWidth,
            child: const SizedBox.expand(key: childKey),
          ),
        ),
      ),
    );
    return tester.getSize(find.byKey(childKey));
  }

  group('CenteredPane', () {
    testWidgets('caps the child at the form measure on a desktop-width window', (tester) async {
      final size = await pumpAtWidth(tester, 1600);

      check(size.width).equals(CenteredPane.formWidth);
    });

    testWidgets('centres the capped child rather than pinning it left', (tester) async {
      await pumpAtWidth(tester, 1600);

      final childCentre = tester.getCenter(find.byKey(childKey));
      final paneCentre = tester.getCenter(find.byType(CenteredPane));
      check(childCentre.dx).equals(paneCentre.dx);
    });

    testWidgets('lets the child fill the width on a phone-width window', (tester) async {
      final size = await pumpAtWidth(tester, 320);

      check(size.width).equals(320);
    });

    testWidgets('honours a wider explicit maxWidth', (tester) async {
      final size = await pumpAtWidth(tester, 1600, maxWidth: CenteredPane.wideWidth);

      check(size.width).equals(CenteredPane.wideWidth);
    });
  });
}
