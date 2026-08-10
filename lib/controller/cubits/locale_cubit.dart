import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<String> {
  LocaleCubit({SharedPreferences? prefs}) : super('en') {
    _prefs = prefs;
    unawaited(_restore());
  }

  static const _key = 'hp_locale';
  static const supported = {'en', 'bm', 'zh'};

  SharedPreferences? _prefs;

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _restore() async {
    final prefs = await _preferences();
    final saved = prefs.getString(_key);
    if (saved != null && supported.contains(saved)) {
      emit(saved);
    }
  }

  Future<void> setLocale(String value) async {
    final normalized = supported.contains(value) ? value : 'en';
    if (normalized == state) return;
    emit(normalized);
    final prefs = await _preferences();
    await prefs.setString(_key, normalized);
  }

  void applyRemote(String? value) {
    if (value != null && supported.contains(value) && value != state) {
      unawaited(setLocale(value));
    }
  }
}
