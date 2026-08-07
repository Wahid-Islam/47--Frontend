/// Illustrative DOSM-inspired cause-of-death baselines for Malaysia.
///
/// Ported from `backend/src/data/dosm.js`. Values are educational
/// approximations used to seed the on-device risk engine — not clinical
/// data. Source framing: Department of Statistics Malaysia (DOSM)
/// mortality themes.
class AgeBand {
  const AgeBand({required this.minAge, required this.maxAge, required this.rate});

  final int minAge;
  final int maxAge;
  final double rate;
}

class CauseOfDeath {
  const CauseOfDeath({
    required this.id,
    required this.name,
    required this.nameBm,
    required this.nationalShare,
    required this.maleCurve,
    required this.femaleCurve,
  });

  final String id;
  final String name;
  final String nameBm;
  final double nationalShare;
  final List<AgeBand> maleCurve;
  final List<AgeBand> femaleCurve;

  List<AgeBand> curveFor(String gender) => gender == 'female' ? femaleCurve : maleCurve;
}

class DosmData {
  DosmData._();

  static const List<CauseOfDeath> causes = [
    CauseOfDeath(
      id: 'cardiovascular',
      name: 'Cardiovascular Disease',
      nameBm: 'Penyakit Kardiovaskular',
      nationalShare: 0.22,
      maleCurve: [
        AgeBand(minAge: 40, maxAge: 49, rate: 0.18),
        AgeBand(minAge: 50, maxAge: 59, rate: 0.28),
        AgeBand(minAge: 60, maxAge: 69, rate: 0.36),
      ],
      femaleCurve: [
        AgeBand(minAge: 40, maxAge: 49, rate: 0.12),
        AgeBand(minAge: 50, maxAge: 59, rate: 0.2),
        AgeBand(minAge: 60, maxAge: 69, rate: 0.29),
      ],
    ),
    CauseOfDeath(
      id: 'diabetes_complications',
      name: 'Diabetes-related Complications',
      nameBm: 'Komplikasi Berkaitan Diabetes',
      nationalShare: 0.09,
      maleCurve: [
        AgeBand(minAge: 40, maxAge: 49, rate: 0.08),
        AgeBand(minAge: 50, maxAge: 59, rate: 0.14),
        AgeBand(minAge: 60, maxAge: 69, rate: 0.19),
      ],
      femaleCurve: [
        AgeBand(minAge: 40, maxAge: 49, rate: 0.09),
        AgeBand(minAge: 50, maxAge: 59, rate: 0.15),
        AgeBand(minAge: 60, maxAge: 69, rate: 0.2),
      ],
    ),
    CauseOfDeath(
      id: 'respiratory',
      name: 'Chronic Respiratory Disease',
      nameBm: 'Penyakit Pernafasan Kronik',
      nationalShare: 0.07,
      maleCurve: [
        AgeBand(minAge: 40, maxAge: 49, rate: 0.06),
        AgeBand(minAge: 50, maxAge: 59, rate: 0.1),
        AgeBand(minAge: 60, maxAge: 69, rate: 0.15),
      ],
      femaleCurve: [
        AgeBand(minAge: 40, maxAge: 49, rate: 0.04),
        AgeBand(minAge: 50, maxAge: 59, rate: 0.07),
        AgeBand(minAge: 60, maxAge: 69, rate: 0.11),
      ],
    ),
    CauseOfDeath(
      id: 'cancer',
      name: 'Cancer (all sites)',
      nameBm: 'Kanser (semua jenis)',
      nationalShare: 0.14,
      maleCurve: [
        AgeBand(minAge: 40, maxAge: 49, rate: 0.1),
        AgeBand(minAge: 50, maxAge: 59, rate: 0.17),
        AgeBand(minAge: 60, maxAge: 69, rate: 0.24),
      ],
      femaleCurve: [
        AgeBand(minAge: 40, maxAge: 49, rate: 0.11),
        AgeBand(minAge: 50, maxAge: 59, rate: 0.16),
        AgeBand(minAge: 60, maxAge: 69, rate: 0.22),
      ],
    ),
  ];

  static double baselineRate(String causeId, String gender, int age) {
    final cause = causes.where((c) => c.id == causeId).isEmpty
        ? causes.first
        : causes.firstWhere((c) => c.id == causeId);
    final bands = cause.curveFor(gender);
    final band = bands.where((b) => age >= b.minAge && age <= b.maxAge);
    return band.isNotEmpty ? band.first.rate : bands.last.rate;
  }

  static const Map<String, double> nationalLifeExpectancy = {'male': 72.5, 'female': 77.2};
}
