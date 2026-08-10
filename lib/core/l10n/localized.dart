/// Pick a localized string with fallback: locale → en → first non-empty.
String localizedText(
  String locale, {
  required String en,
  String bm = '',
  String zh = '',
}) {
  switch (locale) {
    case 'bm':
      if (bm.isNotEmpty) return bm;
      if (en.isNotEmpty) return en;
      return zh;
    case 'zh':
      if (zh.isNotEmpty) return zh;
      if (en.isNotEmpty) return en;
      return bm;
    default:
      if (en.isNotEmpty) return en;
      if (bm.isNotEmpty) return bm;
      return zh;
  }
}
