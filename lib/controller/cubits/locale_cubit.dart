import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<String> {
  LocaleCubit({SharedPreferences? prefs}) : super('en') {
    _prefs = prefs;
    unawaited(_restore());
  }

  static const _key = 'hp_locale';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _restore() async {
    final prefs = await _preferences();
    final saved = prefs.getString(_key);
    if (saved == 'en' || saved == 'bm') {
      emit(saved!);
    }
  }

  Future<void> setLocale(String value) async {
    final normalized = value == 'bm' ? 'bm' : 'en';
    if (normalized == state) return;
    emit(normalized);
    final prefs = await _preferences();
    await prefs.setString(_key, normalized);
  }

  void applyRemote(String? value) {
    if ((value == 'en' || value == 'bm') && value != state) {
      unawaited(setLocale(value!));
    }
  }
}
