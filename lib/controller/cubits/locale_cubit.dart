import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's active locale ('en' | 'bm'), persisted locally.
///
/// This cubit only owns the on-device preference; syncing the choice to
/// the user's Supabase profile (so it round-trips across devices) is done
/// by the caller via [ProfileCubit.updateLocale] to keep cubits decoupled.
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

  /// Applies a locale value loaded from a remote profile without
  /// re-writing local prefs redundantly if it already matches.
  void applyRemote(String? value) {
    if ((value == 'en' || value == 'bm') && value != state) {
      unawaited(setLocale(value!));
    }
  }
}
