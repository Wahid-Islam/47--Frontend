import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysihat/controller/services/recommendation_engine.dart';
import 'package:mysihat/controller/services/risk_engine.dart';
import 'package:mysihat/model/profile.dart';

void main() {
  group('RecommendationEngine', () {
    test('always returns exactly 4 daily habits', () {
      final profile = Profile.demo('u');
      final insights = RiskEngine.compute(profile);
      final recs = RecommendationEngine.recommendDailyHabits(
        profile: profile,
        risks: insights.risks,
        daySeed: 10,
      );
      check(recs.length).equals(4);
    });

    test('smoker profile ranks smoke-free habit highly', () {
      final smoker = Profile.demo('s').copyWith(smoking: true);
      final insights = RiskEngine.compute(smoker);
      final recs = RecommendationEngine.recommendDailyHabits(
        profile: smoker,
        risks: insights.risks,
        daySeed: 1,
      );
      check(recs.map((r) => r.habit.id)).contains('smoke_free_day');
    });

    test('low activity ranks walking highly', () {
      final low = Profile.demo('a').copyWith(smoking: false, activityLevel: 'low');
      final insights = RiskEngine.compute(low);
      final recs = RecommendationEngine.recommendDailyHabits(
        profile: low,
        risks: insights.risks,
        daySeed: 2,
      );
      check(recs.first.habit.id).equals('walk_20');
    });
  });
}
