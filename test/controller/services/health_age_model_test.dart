import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysihat/controller/services/health_age/health_age_model.dart';
import 'package:mysihat/controller/services/health_age/malaysia_mortality.dart';
import 'package:mysihat/model/profile.dart';

Profile _base({
  int age = 35,
  String gender = 'male',
  bool smoking = false,
  String activityLevel = 'high',
  String dietHabit = 'healthy',
  String alcohol = 'none',
  double sleepHours = 7.5,
  double bmi = 22,
  bool highBloodPressure = false,
}) {
  return Profile(
    id: 'test',
    age: age,
    gender: gender,
    activityLevel: activityLevel,
    dietHabit: dietHabit,
    smoking: smoking,
    bmi: bmi,
    heightCm: 170,
    weightKg: bmi * 1.7 * 1.7,
    alcohol: alcohol,
    sleepHours: sleepHours,
    highBloodPressure: highBloodPressure,
    onboardingComplete: true,
  );
}

void main() {
  group('MalaysiaMortality', () {
    test('uses distinct male and female baselines', () {
      final male = MalaysiaMortality.mortality(40, 'male');
      final female = MalaysiaMortality.mortality(40, 'female');
      check(male).isGreaterThan(female);
      check(MalaysiaMortality.metadata['variable']).equals('nmx (central mortality rate)');
    });

    test('mortality generally rises with age in mid-life', () {
      final m30 = MalaysiaMortality.mortality(30, 'male');
      final m50 = MalaysiaMortality.mortality(50, 'male');
      final m70 = MalaysiaMortality.mortality(70, 'male');
      check(m50).isGreaterThan(m30);
      check(m70).isGreaterThan(m50);
    });
  });

  group('HealthAgeModel', () {
    test('healthy reference user stays near chronological age', () {
      final result = HealthAgeModel.calculate(
        _base(activityLevel: 'moderate', dietHabit: 'healthy', alcohol: 'none', sleepHours: 7.5, bmi: 22),
      );
      check(result.healthAgeDifference.abs()).isLessOrEqual(6);
      check(result.riskIndex).isLessOrEqual(1.10);
      check(result.lifestyleScore).isGreaterOrEqual(70);
    });

    test('current smoking raises Health Age vs never smoking', () {
      final never = HealthAgeModel.calculate(_base(smoking: false, activityLevel: 'moderate'));
      final current = HealthAgeModel.calculate(_base(smoking: true, activityLevel: 'moderate'));
      check(current.riskIndex).isGreaterThan(never.riskIndex);
      check(current.healthAge).isGreaterThan(never.healthAge);
    });

    test('higher activity lowers risk index', () {
      final rare = HealthAgeModel.calculate(_base(activityLevel: 'low', dietHabit: 'average'));
      final active = HealthAgeModel.calculate(_base(activityLevel: 'high', dietHabit: 'average'));
      check(active.riskIndex).isLessThan(rare.riskIndex);
    });

    // Mid-risk base (RR above clamp floor) so single-factor deltas are visible.
    Profile midRisk({
      bool highBloodPressure = false,
      bool diabetes = false,
      double sleepHours = 7.5,
    }) {
      return _base(
        activityLevel: 'low',
        dietHabit: 'average',
        alcohol: 'occasional',
        bmi: 27,
        sleepHours: sleepHours,
        highBloodPressure: highBloodPressure,
      ).copyWith(diabetes: diabetes);
    }

    test('hypertension raises risk index', () {
      final no = HealthAgeModel.calculate(midRisk());
      final yes = HealthAgeModel.calculate(midRisk(highBloodPressure: true));
      check(no.riskIndex).isGreaterThan(0.70);
      check(yes.riskIndex).isGreaterThan(no.riskIndex);
    });

    test('diabetes raises risk index', () {
      final no = HealthAgeModel.calculate(midRisk());
      final yes = HealthAgeModel.calculate(midRisk(diabetes: true));
      check(yes.riskIndex).isGreaterThan(no.riskIndex);
    });

    test('short sleep raises risk index vs 7–8 hours', () {
      final good = HealthAgeModel.calculate(midRisk(sleepHours: 7.5));
      final short = HealthAgeModel.calculate(midRisk(sleepHours: 5));
      check(short.riskIndex).isGreaterThan(good.riskIndex);
    });

    test('bounds Health Age to age−10 … age+15', () {
      final harsh = HealthAgeModel.calculate(
        _base(
          age: 30,
          smoking: true,
          activityLevel: 'low',
          dietHabit: 'unhealthy',
          alcohol: 'regular',
          sleepHours: 5,
          bmi: 36,
          highBloodPressure: true,
        ),
      );
      check(harsh.healthAge).isLessOrEqual(45);
      check(harsh.healthAge).isGreaterOrEqual(20);
    });

    test('male and female retrieve different baselines for same lifestyle', () {
      final male = HealthAgeModel.calculate(_base(gender: 'male'));
      final female = HealthAgeModel.calculate(_base(gender: 'female'));
      check(male.baselineMortality == female.baselineMortality).isFalse();
    });

    test('factors are ranked for explainability', () {
      final result = HealthAgeModel.calculate(_base(smoking: true, activityLevel: 'low'));
      check(result.factorContributions.first.id).equals('smoking');
      check(result.modelVersion).equals('1.0');
    });
  });
}
