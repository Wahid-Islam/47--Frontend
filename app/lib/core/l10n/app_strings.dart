/// Tiny hand-rolled EN/BM string table.
///
/// HealthPath supports English and Bahasa Melayu. Keys are looked up with
/// [AppStrings.t]; unknown keys fall back to English, then to the raw key.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _map = {
    'appName': {'en': 'mysihat', 'bm': 'mysihat'},
    'tagline': {'en': 'Understand today. Act for tomorrow.', 'bm': 'Fahami hari ini. Bertindak untuk esok.'},
    'getStarted': {'en': 'Get Started', 'bm': 'Mulakan'},
    'haveAccount': {'en': 'I already have an account', 'bm': 'Saya sudah ada akaun'},
    'demoLogin': {'en': 'Try demo (Lim Wei Jian)', 'bm': 'Cuba demo (Lim Wei Jian)'},
    'login': {'en': 'Log in', 'bm': 'Log masuk'},
    'register': {'en': 'Create account', 'bm': 'Cipta akaun'},
    'email': {'en': 'Email', 'bm': 'E-mel'},
    'password': {'en': 'Password', 'bm': 'Kata laluan'},
    'fullName': {'en': 'Full name', 'bm': 'Nama penuh'},
    'home': {'en': 'Overview', 'bm': 'Gambaran Keseluruhan'},
    'insights': {'en': 'Personal Insights', 'bm': 'Wawasan Peribadi'},
    'plan': {'en': 'Action Roadmap', 'bm': 'Pelan Tindakan'},
    'progress': {'en': 'Progress', 'bm': 'Kemajuan'},
    'profile': {'en': 'Profile', 'bm': 'Profil'},
    'healthAge': {'en': 'Health Age', 'bm': 'Umur Kesihatan'},
    'actualAge': {'en': 'Actual age', 'bm': 'Umur sebenar'},
    'overallRisk': {'en': 'Overall risk', 'bm': 'Risiko keseluruhan'},
    'topRisk': {'en': 'Your top risk', 'bm': 'Risiko utama anda'},
    'why': {'en': 'Why this matters', 'bm': 'Mengapa ini penting'},
    'peerComparison': {'en': 'Peer comparison', 'bm': 'Perbandingan rakan sebaya'},
    'factors': {'en': 'Contributing factors', 'bm': 'Faktor penyumbang'},
    'topActions': {'en': 'Your top 3 actions', 'bm': '3 tindakan utama anda'},
    'findClinics': {'en': 'Find clinics nearby', 'bm': 'Cari klinik berhampiran'},
    'clinics': {'en': 'Nearby clinics', 'bm': 'Klinik berhampiran'},
    'dailyHabits': {'en': "Today's habits", 'bm': 'Tabiat hari ini'},
    'editProfile': {'en': 'Edit profile', 'bm': 'Edit profil'},
    'language': {'en': 'Language', 'bm': 'Bahasa'},
    'english': {'en': 'English', 'bm': 'English'},
    'bahasaMelayu': {'en': 'Bahasa Melayu', 'bm': 'Bahasa Melayu'},
    'logout': {'en': 'Log out', 'bm': 'Log keluar'},
    'disclaimer': {'en': 'Disclaimer', 'bm': 'Penafian'},
    'saveContinue': {'en': 'Save & continue', 'bm': 'Simpan & teruskan'},
    'next': {'en': 'Next', 'bm': 'Seterusnya'},
    'back': {'en': 'Back', 'bm': 'Kembali'},
    'finish': {'en': 'See my Health Age', 'bm': 'Lihat Umur Kesihatan'},
    'demographics': {'en': 'About you', 'bm': 'Tentang anda'},
    'lifestyle': {'en': 'Lifestyle', 'bm': 'Gaya hidup'},
    'age': {'en': 'Age', 'bm': 'Umur'},
    'gender': {'en': 'Gender', 'bm': 'Jantina'},
    'state': {'en': 'State', 'bm': 'Negeri'},
    'activity': {'en': 'Activity level', 'bm': 'Tahap aktiviti'},
    'diet': {'en': 'Diet habit', 'bm': 'Tabiat pemakanan'},
    'smoking': {'en': 'Do you smoke?', 'bm': 'Adakah anda merokok?'},
    'bmi': {'en': 'BMI', 'bm': 'BMI'},
    'highBp': {'en': 'High blood pressure?', 'bm': 'Tekanan darah tinggi?'},
    'yes': {'en': 'Yes', 'bm': 'Ya'},
    'no': {'en': 'No', 'bm': 'Tidak'},
    'male': {'en': 'Male', 'bm': 'Lelaki'},
    'female': {'en': 'Female', 'bm': 'Perempuan'},
    'other': {'en': 'Other', 'bm': 'Lain-lain'},
    'low': {'en': 'Low', 'bm': 'Rendah'},
    'moderate': {'en': 'Moderate', 'bm': 'Sederhana'},
    'high': {'en': 'High', 'bm': 'Tinggi'},
    'unhealthy': {'en': 'Unhealthy', 'bm': 'Tidak sihat'},
    'average': {'en': 'Average', 'bm': 'Purata'},
    'healthy': {'en': 'Healthy', 'bm': 'Sihat'},
    'loading': {'en': 'Loading…', 'bm': 'Memuatkan…'},
    'errorGeneric': {
      'en': 'Something went wrong. Please try again.',
      'bm': 'Sesuatu tidak kena. Sila cuba lagi.',
    },
    'nationalAvg': {'en': 'National average', 'bm': 'Purata kebangsaan'},
    'yourRisk': {'en': 'Your risk', 'bm': 'Risiko anda'},
    'minutes': {'en': 'min', 'bm': 'min'},
    'impact': {'en': 'Impact', 'bm': 'Impak'},
    'welcomeBack': {'en': 'Welcome back', 'bm': 'Selamat kembali'},
    'createAccountSubtitle': {
      'en': 'Start your personalised health journey.',
      'bm': 'Mulakan perjalanan kesihatan peribadi anda.',
    },
    'onboardingSubtitle': {
      'en': 'Personalised Health Age and preventive actions for Malaysians aged 40–60.',
      'bm': 'Umur Kesihatan dan tindakan pencegahan peribadi untuk rakyat Malaysia berumur 40–60.',
    },
    'noInsights': {
      'en': 'Complete your profile to see insights.',
      'bm': 'Lengkapkan profil anda untuk melihat wawasan.',
    },
    'completedOf': {'en': 'completed', 'bm': 'selesai'},
    'refresh': {'en': 'Refresh', 'bm': 'Muat semula'},
    'save': {'en': 'Save changes', 'bm': 'Simpan perubahan'},
    'vsActual': {'en': 'vs your actual age', 'bm': 'berbanding umur sebenar'},

    // --- Epic 1.0: Personalised Health Risk Understanding ---
    'insightsSubtitle': {
      'en': 'Your estimated Health Age and the key lifestyle factors shaping it.',
      'bm': 'Anggaran Umur Kesihatan anda dan faktor gaya hidup utama yang mempengaruhinya.',
    },
    'yourHealthAgeTitle': {'en': 'Your Health Age', 'bm': 'Umur Kesihatan Anda'},
    'healthAgeYoungerMsg': {
      'en': 'Great news — your Health Age is {n} years younger than your actual age. Keep it up!',
      'bm': 'Berita baik — Umur Kesihatan anda {n} tahun lebih muda daripada umur sebenar. Teruskan!',
    },
    'healthAgeOlderMsg': {
      'en': 'Your Health Age is {n} years older than your actual age. Small changes can help lower it.',
      'bm':
          'Umur Kesihatan anda {n} tahun lebih tua daripada umur sebenar. Perubahan kecil boleh membantu menurunkannya.',
    },
    'healthAgeSameMsg': {
      'en': 'Your Health Age matches your actual age — stay consistent with healthy habits.',
      'bm': 'Umur Kesihatan anda sama dengan umur sebenar — kekalkan tabiat sihat.',
    },
    'topFactorsTitle': {'en': '3 Main Contributing Factors', 'bm': '3 Faktor Penyumbang Utama'},
    'nationalComparisonTitle': {
      'en': 'How You Compare Nationally',
      'bm': 'Bagaimana Anda Berbanding Secara Kebangsaan',
    },
    'healthAgeCompareLabel': {'en': 'Health Age comparison', 'bm': 'Perbandingan Umur Kesihatan'},
    'you': {'en': 'You', 'bm': 'Anda'},
    'nextActionRoadmap': {'en': 'Next: Action Roadmap', 'bm': 'Seterusnya: Pelan Tindakan'},
    'planSubtitle': {
      'en': 'Your personalised 3-step plan to lower your Health Age.',
      'bm': 'Pelan 3 langkah peribadi anda untuk menurunkan Umur Kesihatan.',
    },
    'healthAgeProjectionTitle': {
      'en': 'Health Age projection (12 months)',
      'bm': 'Unjuran Umur Kesihatan (12 bulan)',
    },
    'followPlan': {'en': 'Follow the plan', 'bm': 'Ikut pelan'},
    'noChange': {'en': 'No change', 'bm': 'Tiada perubahan'},
    'checklist': {'en': 'Daily habit checklist', 'bm': 'Senarai semak tabiat harian'},
    'validationRequired': {'en': 'This field is required', 'bm': 'Medan ini diperlukan'},
    'validationSelect': {'en': 'Please make a selection', 'bm': 'Sila buat pilihan'},
    'validationAgeRange': {
      'en': 'Enter a whole number age between 18 and 90',
      'bm': 'Masukkan umur (nombor bulat) antara 18 dan 90',
    },
    'validationBmiRange': {'en': 'Enter a BMI between 10 and 60', 'bm': 'Masukkan BMI antara 10 dan 60'},
  };

  static String t(String key, String locale) {
    final entry = _map[key];
    if (entry == null) return key;
    return entry[locale] ?? entry['en'] ?? key;
  }

  /// Looks up [key] like [t], then substitutes the literal token `{n}`
  /// with [n] — used for the handful of strings that need one dynamic
  /// number (e.g. "{n} years younger than your actual age").
  static String tn(String key, String locale, num n) {
    return t(key, locale).replaceAll('{n}', n.toString());
  }
}

const List<String> malaysianStates = [
  'Wilayah Persekutuan Kuala Lumpur',
  'Wilayah Persekutuan Putrajaya',
  'Wilayah Persekutuan Labuan',
  'Johor',
  'Kedah',
  'Kelantan',
  'Melaka',
  'Negeri Sembilan',
  'Pahang',
  'Perak',
  'Perlis',
  'Pulau Pinang',
  'Sabah',
  'Sarawak',
  'Selangor',
  'Terengganu',
];
