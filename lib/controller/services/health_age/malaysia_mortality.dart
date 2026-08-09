import 'dart:math' as math;

/// Malaysian sex-specific central mortality rates (`nmx`) for Health Age.
///
/// Source values are the abridged `nmx` column from:
/// Department of Statistics Malaysia, *Abridged Life Tables, Malaysia, 2023*
/// (Table 2.1), as published in the DOSM 2023–2025 life-table release.
///
/// Single-year rates for ages 18–90 are produced by log-linear interpolation
/// between abridged band midpoints. Open-ended 80+ uses the published `nmx`.
///
/// Life expectancy anchors from the same DOSM release cycle (2025 estimates):
/// male 73.1 / female 77.9 at birth.
class MalaysiaMortality {
  MalaysiaMortality._();

  static const Map<String, dynamic> metadata = {
    'source': 'Department of Statistics Malaysia',
    'dataset': 'Abridged Life Tables Malaysia 2023',
    'releaseYear': 2025,
    'tableYear': 2023,
    'variable': 'nmx (central mortality rate)',
    'version': 'DOSM-2023-nmx',
    'lifeExpectancyAtBirth2025': {'male': 73.1, 'female': 77.9},
  };

  /// Abridged band starts and corresponding male/female `nmx`.
  static const List<int> _bandStarts = [0, 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80];

  static const List<double> _maleNmx = [
    0.00707,
    0.00038,
    0.00020,
    0.00029,
    0.00079,
    0.00096,
    0.00110,
    0.00149,
    0.00228,
    0.00353,
    0.00605,
    0.00936,
    0.01448,
    0.02050,
    0.02939,
    0.04276,
    0.06957,
    0.16770,
  ];

  static const List<double> _femaleNmx = [
    0.00581,
    0.00033,
    0.00015,
    0.00019,
    0.00028,
    0.00038,
    0.00060,
    0.00083,
    0.00125,
    0.00206,
    0.00338,
    0.00537,
    0.00824,
    0.01249,
    0.01866,
    0.02933,
    0.04998,
    0.14476,
  ];

  static List<double> _curveFor(String sex) => sex == 'female' ? _femaleNmx : _maleNmx;

  static double _bandMidpoint(int index) {
    if (index >= _bandStarts.length - 1) return 85;
    final start = _bandStarts[index];
    final end = _bandStarts[index + 1];
    return start + (end - start) / 2;
  }

  /// Central mortality rate (`nmx`) at integer [age] for [sex] (`male`/`female`).
  static double mortality(int age, String sex) {
    final clamped = age.clamp(0, 100);
    final curve = _curveFor(sex == 'female' ? 'female' : 'male');

    // Locate surrounding band midpoints and interpolate in log space.
    var lower = 0;
    for (var i = 0; i < _bandStarts.length; i++) {
      if (_bandMidpoint(i) <= clamped) lower = i;
    }
    final upper = math.min(lower + 1, _bandStarts.length - 1);
    if (lower == upper) return curve[lower];

    final x0 = _bandMidpoint(lower);
    final x1 = _bandMidpoint(upper);
    final y0 = math.max(curve[lower], 1e-9);
    final y1 = math.max(curve[upper], 1e-9);
    final t = ((clamped - x0) / (x1 - x0)).clamp(0.0, 1.0);
    return math.exp(math.log(y0) + (math.log(y1) - math.log(y0)) * t);
  }

  /// Find the age whose baseline mortality ≈ [targetMortality], with
  /// linear interpolation between adjacent ages (PDF §§26–27).
  static double findEquivalentAge({
    required double targetMortality,
    required String sex,
    int searchMin = 18,
    int searchMax = 90,
  }) {
    final gender = sex == 'female' ? 'female' : 'male';
    var bestAge = searchMin.toDouble();
    var bestDiff = double.infinity;

    for (var age = searchMin; age <= searchMax; age++) {
      final m = mortality(age, gender);
      final diff = (m - targetMortality).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestAge = age.toDouble();
      }
    }

    // Refine with neighbours when the curve is locally increasing.
    final floorAge = bestAge.floor().clamp(searchMin, searchMax - 1);
    final m0 = mortality(floorAge, gender);
    final m1 = mortality(floorAge + 1, gender);
    if ((m1 - m0).abs() < 1e-12) return bestAge;

    // Only interpolate when target lies between the two points.
    final lo = math.min(m0, m1);
    final hi = math.max(m0, m1);
    if (targetMortality < lo || targetMortality > hi) return bestAge;

    final t = ((targetMortality - m0) / (m1 - m0)).clamp(0.0, 1.0);
    return floorAge + t;
  }
}
