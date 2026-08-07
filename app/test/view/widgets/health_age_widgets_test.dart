import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysihat/view/widgets/health_age_dual_gauge.dart';
import 'package:mysihat/view/widgets/health_age_projection_chart.dart';

void main() {
  group('HealthAgeDualGauge', () {
    testWidgets('renders both the Health Age and Actual Age numbers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HealthAgeDualGauge(healthAge: 54, actualAge: 48, locale: 'en')),
        ),
      );

      check(find.text('54').evaluate().length).equals(1);
      check(find.text('48').evaluate().length).equals(1);
      check(find.text('Health Age').evaluate().length).equals(1);
      check(find.text('Actual age').evaluate().length).equals(1);
      check(tester.takeException()).isNull();
    });
  });

  group('HealthAgeProjectionChart', () {
    testWidgets('renders the follow-plan/no-change legend without overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthAgeProjectionChart(
              healthAge: 54,
              projectedFollowPlan: 48,
              projectedNoChange: 62,
              locale: 'en',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      check(find.text('Follow the plan').evaluate().length).equals(1);
      check(find.text('No change').evaluate().length).equals(1);
      check(tester.takeException()).isNull();
    });
  });
}
