import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysihat/controller/services/mortality_insights.dart';
import 'package:mysihat/controller/services/risk_engine.dart';
import 'package:mysihat/model/profile.dart';

void main() {
  group('MortalityInsights', () {
    test('age group label follows actual age bands', () {
      check(MortalityInsights.ageGroupLabel(30)).equals('15–40');
      check(MortalityInsights.ageGroupLabel(48)).equals('41–59');
      check(MortalityInsights.ageGroupLabel(65)).equals('60+');
    });

    test('cards follow personal risk ranking from the user profile', () {
      final demo = Profile.demo('u');
      final insights = RiskEngine.compute(demo);
      final killers = MortalityInsights.fromInsights(insights);

      check(killers.length).equals(3);
      check(killers.map((k) => k.id).toList()).deepEquals(insights.risks.take(3).map((r) => r.id).toList());
      check(killers.first.sharePercent).equals(insights.risks.first.personalRisk);
    });

    test('different lifestyle inputs change the displayed personal risk', () {
      final risky = Profile.demo('a');
      final healthy = Profile.demo('b').copyWith(
        smoking: false,
        activityLevel: 'high',
        dietHabit: 'healthy',
        alcohol: 'none',
        sleepHours: 8,
        bmi: 22,
        heightCm: 170,
        weightKg: 64,
      );

      final riskyCards = MortalityInsights.fromInsights(RiskEngine.compute(risky));
      final healthyCards = MortalityInsights.fromInsights(RiskEngine.compute(healthy));

      check(riskyCards.first.sharePercent).isGreaterThan(healthyCards.first.sharePercent);
    });

    test('learn cards include the user age group and health age', () {
      final insights = RiskEngine.compute(Profile.demo('u').copyWith(age: 35));
      final cards = MortalityInsights.learnCards(insights, 'en');

      check(cards.first.eyebrow).contains('15–40');
      check(cards[1].body).contains('${insights.healthAge}');
      check(cards[1].body).contains('${insights.actualAge}');
    });
  });
}
