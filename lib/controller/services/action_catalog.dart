import '../../model/action_item.dart';

/// Static catalog of preventive actions and daily habits.
///
/// Ported from `backend/src/data/actions.js`. [RiskEngine] ranks and
/// filters these based on the user's computed risks and profile.
class ActionCatalog {
  ActionCatalog._();

  static const List<ActionItem> actions = [
    ActionItem(
      id: 'bp_screening',
      title: 'Book Blood Pressure Screening',
      titleBm: 'Tempah Saringan Tekanan Darah',
      description: 'Get a free BP check at a nearby Klinik Kesihatan this week.',
      descriptionBm: 'Dapatkan pemeriksaan tekanan darah percuma di Klinik Kesihatan berhampiran minggu ini.',
      category: 'screening',
      impact: 'high',
      timeMinutes: 15,
      targets: ['cardiovascular'],
      habitIds: ['check_bp_reminder'],
      cta: ActionCta(type: 'clinic', label: 'Find clinics nearby', labelBm: 'Cari klinik berhampiran'),
    ),
    ActionItem(
      id: 'walk_20',
      title: 'Walk 20 Minutes 3x This Week',
      titleBm: 'Berjalan 20 Minit 3x Minggu Ini',
      description: 'Brisk walking lowers cardiovascular risk without needing a gym.',
      descriptionBm: 'Berjalan pantas mengurangkan risiko kardiovaskular tanpa perlu ke gim.',
      category: 'activity',
      impact: 'high',
      timeMinutes: 20,
      targets: ['cardiovascular', 'diabetes_complications'],
      habitIds: ['walk_20'],
      cta: ActionCta(type: 'habit', label: 'Add to daily habits', labelBm: 'Tambah ke tabiat harian'),
    ),
    ActionItem(
      id: 'swap_drinks',
      title: 'Replace Sugary Drinks',
      titleBm: 'Ganti Minuman Bergula',
      description: 'Swap one sugary drink a day for water or unsweetened tea.',
      descriptionBm: 'Ganti satu minuman bergula sehari dengan air atau teh tanpa gula.',
      category: 'diet',
      impact: 'medium',
      timeMinutes: 1,
      targets: ['diabetes_complications', 'cardiovascular'],
      habitIds: ['no_sugary_drink'],
      cta: ActionCta(type: 'habit', label: 'Track this habit', labelBm: 'Jejak tabiat ini'),
    ),
    ActionItem(
      id: 'brown_rice',
      title: 'Replace White Rice with Brown Rice',
      titleBm: 'Ganti Nasi Putih dengan Nasi Perang',
      description: 'Can reduce glycemic load by roughly 24% versus white rice.',
      descriptionBm: 'Boleh mengurangkan beban glisemik kira-kira 24% berbanding nasi putih.',
      category: 'diet',
      impact: 'medium',
      timeMinutes: 5,
      targets: ['diabetes_complications'],
      habitIds: ['brown_rice_meal'],
      cta: ActionCta(type: 'habit', label: 'Add meal swap', labelBm: 'Tambah pertukaran makanan'),
    ),
    ActionItem(
      id: 'blood_sugar',
      title: 'Book Blood Sugar Checkup',
      titleBm: 'Tempah Pemeriksaan Gula Dalam Darah',
      description: 'A fasting glucose test helps catch diabetes risk early.',
      descriptionBm: 'Ujian glukosa berpuasa membantu mengesan risiko diabetes lebih awal.',
      category: 'screening',
      impact: 'high',
      timeMinutes: 20,
      targets: ['diabetes_complications'],
      habitIds: [],
      cta: ActionCta(type: 'clinic', label: 'Find Klinik Kesihatan', labelBm: 'Cari Klinik Kesihatan'),
    ),
    ActionItem(
      id: 'quit_support',
      title: 'Start a Smoke-Free Day Plan',
      titleBm: 'Mulakan Rancangan Hari Tanpa Asap',
      description: 'Set one smoke-free day this week and note triggers.',
      descriptionBm: 'Tetapkan satu hari tanpa merokok minggu ini dan catat pencetus.',
      category: 'smoking',
      impact: 'high',
      timeMinutes: 10,
      targets: ['cardiovascular', 'respiratory', 'cancer'],
      habitIds: ['smoke_free_day'],
      cta: ActionCta(type: 'habit', label: 'Track smoke-free days', labelBm: 'Jejak hari tanpa asap'),
    ),
    ActionItem(
      id: 'hydrate',
      title: 'Drink 8 Glasses of Water',
      titleBm: 'Minum 8 Gelas Air',
      description: 'Steady hydration supports energy and reduces sugary drink swaps.',
      descriptionBm: 'Penghidratan yang baik menyokong tenaga dan mengurangkan minuman bergula.',
      category: 'diet',
      impact: 'low',
      timeMinutes: 2,
      targets: ['diabetes_complications'],
      habitIds: ['drink_water'],
      cta: ActionCta(type: 'habit', label: 'Track hydration', labelBm: 'Jejak penghidratan'),
    ),
    ActionItem(
      id: 'sleep_7',
      title: 'Aim for 7 Hours of Sleep',
      titleBm: 'Sasaran 7 Jam Tidur',
      description: 'Consistent sleep helps blood pressure and metabolic health.',
      descriptionBm: 'Tidur yang konsisten membantu tekanan darah dan kesihatan metabolik.',
      category: 'recovery',
      impact: 'medium',
      timeMinutes: 0,
      targets: ['cardiovascular', 'diabetes_complications'],
      habitIds: ['sleep_7'],
      cta: ActionCta(type: 'habit', label: 'Log sleep', labelBm: 'Log tidur'),
    ),
  ];

  static const List<HabitCatalogItem> habits = [
    HabitCatalogItem(id: 'walk_20', title: 'Walk 20 minutes', titleBm: 'Berjalan 20 minit'),
    HabitCatalogItem(id: 'drink_water', title: 'Drink 8 glasses of water', titleBm: 'Minum 8 gelas air'),
    HabitCatalogItem(id: 'no_sugary_drink', title: 'Skip sugary drinks', titleBm: 'Elak minuman bergula'),
    HabitCatalogItem(
      id: 'brown_rice_meal',
      title: 'Choose brown rice once',
      titleBm: 'Pilih nasi perang sekali',
    ),
    HabitCatalogItem(
      id: 'smoke_free_day',
      title: 'Stay smoke-free today',
      titleBm: 'Kekal tanpa asap hari ini',
    ),
    HabitCatalogItem(
      id: 'sleep_7',
      title: 'Sleep at least 7 hours',
      titleBm: 'Tidur sekurang-kurangnya 7 jam',
    ),
    HabitCatalogItem(
      id: 'check_bp_reminder',
      title: 'Plan BP screening visit',
      titleBm: 'Rancang lawatan saringan BP',
    ),
  ];

  static HabitCatalogItem? habitById(String id) {
    final matches = habits.where((h) => h.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }
}
