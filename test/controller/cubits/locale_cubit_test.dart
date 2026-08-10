import 'package:bloc_test/bloc_test.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysihat/controller/cubits/locale_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocaleCubit', () {
    test('starts in English by default', () {
      final cubit = LocaleCubit();
      check(cubit.state).equals('en');
      cubit.close();
    });

    blocTest<LocaleCubit, String>(
      'setLocale("bm") emits "bm"',
      build: LocaleCubit.new,
      act: (cubit) => cubit.setLocale('bm'),
      verify: (cubit) => check(cubit.state).equals('bm'),
    );

    blocTest<LocaleCubit, String>(
      'setLocale("zh") emits "zh"',
      build: LocaleCubit.new,
      act: (cubit) => cubit.setLocale('zh'),
      verify: (cubit) => check(cubit.state).equals('zh'),
    );

    blocTest<LocaleCubit, String>(
      'setLocale normalizes unknown values to "en"',
      build: LocaleCubit.new,
      act: (cubit) => cubit.setLocale('fr'),
      verify: (cubit) => check(cubit.state).equals('en'),
    );

    blocTest<LocaleCubit, String>(
      'setLocale persists the choice so a new cubit restores it',
      build: LocaleCubit.new,
      act: (cubit) => cubit.setLocale('bm'),
      verify: (cubit) => check(cubit.state).equals('bm'),
    );

    test('a freshly created cubit restores a previously persisted locale', () async {
      SharedPreferences.setMockInitialValues({'hp_locale': 'bm'});
      final cubit = LocaleCubit();
      await Future<void>.delayed(Duration.zero);
      check(cubit.state).equals('bm');
      await cubit.close();
    });

    test('a freshly created cubit restores zh', () async {
      SharedPreferences.setMockInitialValues({'hp_locale': 'zh'});
      final cubit = LocaleCubit();
      await Future<void>.delayed(Duration.zero);
      check(cubit.state).equals('zh');
      await cubit.close();
    });
  });
}
