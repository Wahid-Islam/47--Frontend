import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysihat/core/widgets/buttons.dart';
import 'package:mysihat/core/widgets/chips.dart';

void main() {
  testWidgets('HpPrimaryButton renders its label and invokes onPressed when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HpPrimaryButton(label: 'Continue', onPressed: () => tapped = true),
        ),
      ),
    );

    check(find.text('Continue').evaluate().length).equals(1);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    check(tapped).isTrue();
  });

  testWidgets('HpPrimaryButton disables the tap target while loading', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HpPrimaryButton(label: 'Continue', loading: true, onPressed: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    check(tapped).isFalse();
    check(find.byType(CircularProgressIndicator).evaluate().length).equals(1);
  });

  testWidgets('ChoiceChipRow reports the selected option value on tap', (tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChoiceChipRow(
            value: 'low',
            onChanged: (v) => selected = v,
            options: const [(value: 'low', label: 'Low'), (value: 'high', label: 'High')],
          ),
        ),
      ),
    );

    await tester.tap(find.text('High'));
    await tester.pump();

    check(selected).isNotNull();
    check(selected!).equals('high');
  });

  testWidgets('RiskChip shows the level label in uppercase', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RiskChip('high'))));

    check(find.text('HIGH').evaluate().length).equals(1);
  });
}
