import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysihat/controller/services/risk_engine.dart';
import 'package:mysihat/model/insights.dart';
import 'package:mysihat/model/profile.dart';

void main() {
  group('RiskEngine.compute', () {
    test('produces one risk per DOSM cause, sorted by personal risk descending', () {
      final insights = RiskEngine.compute(Profile.demo('demo-user'));

      check(insights.risks.length).equals(4);
      for (var i = 1; i < insights.risks.length; i++) {
        check(insights.risks[i - 1].personalRisk).isGreaterOrEqual(insights.risks[i].personalRisk);
      }
      check(insights.topRisk).equals(insights.risks.first);
    });

    test('demo (Lim Wei Jian) profile yields a health age above actual age', () {
      final demo = Profile.demo('demo-user');
      final insights = RiskEngine.compute(demo);

      check(insights.actualAge).equals(48);
      check(insights.healthAge).isGreaterThan(demo.age);
      check(insights.overallRiskScore).isGreaterOrEqual(0);
      check(insights.topActions.length).isLessOrEqual(3);
      check(insights.topActions).isNotEmpty();
      check(insights.habits).isNotEmpty();
    });

    test('computes US 1.3 national/peer comparison and roadmap projection fields', () {
      final demo = Profile.demo('demo-user');
      final insights = RiskEngine.compute(demo);

      // MVP demographic baseline: peer average Health Age is the actual age.
      check(insights.peerAverageHealthAge).equals(insights.actualAge);
      check(insights.healthAgeDelta).equals(insights.healthAge - insights.actualAge);

      check(
        insights.projectedHealthAgeFollowPlan,
      ).equals([insights.healthAge - 6, insights.actualAge - 12].reduce((a, b) => a > b ? a : b));
      check(
        insights.projectedHealthAgeNoChange,
      ).equals([insights.healthAge + 8, insights.actualAge + 15].reduce((a, b) => a < b ? a : b));
      check(insights.projectedHealthAgeFollowPlan).isLessThan(insights.projectedHealthAgeNoChange);

      check(insights.nationalComparisonHeadline).isNotEmpty();
      check(insights.nationalComparisonHeadlineBm).isNotEmpty();
      check(insights.localizedNationalComparisonHeadline('bm')).equals(insights.nationalComparisonHeadlineBm);
      check(insights.localizedNationalComparisonHeadline('en')).equals(insights.nationalComparisonHeadline);
    });

    test('healthier lifestyle lowers the computed health age vs. the demo profile', () {
      final demo = Profile.demo('demo-user');
      final healthy = demo.copyWith(
        activityLevel: 'high',
        dietHabit: 'healthy',
        smoking: false,
        bmi: 22,
        highBloodPressure: false,
      );

      final demoInsights = RiskEngine.compute(demo);
      final healthyInsights = RiskEngine.compute(healthy);

      check(healthyInsights.healthAge).isLessThan(demoInsights.healthAge);
      check(healthyInsights.overallRiskScore).isLessThan(demoInsights.overallRiskScore);
    });

    test('smoking always ranks the smoke-free action plan highly for smokers', () {
      final smoker = Profile.demo('demo-user');
      final insights = RiskEngine.compute(smoker);

      check(insights.topActions.map((a) => a.id)).contains('quit_support');
    });

    test('round trips through JSON without losing data', () {
      final insights = RiskEngine.compute(Profile.demo('demo-user'));
      final restored = insights.toJson();

      check(restored['actualAge']).equals(insights.actualAge);
      check(restored['healthAge']).equals(insights.healthAge);
      check((restored['risks'] as List).length).equals(insights.risks.length);
      check(restored['peerAverageHealthAge']).equals(insights.peerAverageHealthAge);
      check(restored['healthAgeDelta']).equals(insights.healthAgeDelta);
      check(restored['projectedHealthAgeFollowPlan']).equals(insights.projectedHealthAgeFollowPlan);
      check(restored['projectedHealthAgeNoChange']).equals(insights.projectedHealthAgeNoChange);
    });

    test('Insights.fromJson fills MVP defaults for legacy payloads missing US 1.3 fields', () {
      final insights = RiskEngine.compute(Profile.demo('demo-user'));
      final legacyJson = insights.toJson()
        ..remove('peerAverageHealthAge')
        ..remove('healthAgeDelta')
        ..remove('projectedHealthAgeFollowPlan')
        ..remove('projectedHealthAgeNoChange')
        ..remove('nationalComparisonHeadline')
        ..remove('nationalComparisonHeadlineBm');

      final restored = Insights.fromJson(legacyJson);

      check(restored.peerAverageHealthAge).equals(insights.actualAge);
      check(restored.healthAgeDelta).equals(insights.healthAge - insights.actualAge);
      check(restored.nationalComparisonHeadline).equals('');
    });
  });
}
