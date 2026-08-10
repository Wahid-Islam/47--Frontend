import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/clinic_repository.dart';
import 'clinics_state.dart';

export 'clinics_state.dart';

class ClinicsCubit extends Cubit<ClinicsState> {
  ClinicsCubit({ClinicRepository? repository})
    : _repository = repository ?? ClinicRepository(),
      super(const ClinicsState());

  final ClinicRepository _repository;

  Future<void> load({double? lat, double? lng}) async {
    emit(state.copyWith(status: ClinicsStatus.loading, errorMessage: null));
    try {
      var clinics = await _repository.getClinics();
      if (lat != null && lng != null) {
        clinics = clinics.map((c) => c.copyWith(distanceKm: _distanceKm(lat, lng, c.lat, c.lng))).toList()
          ..sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
      }
      emit(state.copyWith(status: ClinicsStatus.ready, clinics: clinics));
    } catch (e) {
      emit(state.copyWith(status: ClinicsStatus.error, errorMessage: e.toString()));
    }
  }

  double _distanceKm(double aLat, double aLng, double bLat, double bLng) {
    const earthRadiusKm = 6371.0;
    double toRad(double d) => d * math.pi / 180;
    final dLat = toRad(bLat - aLat);
    final dLng = toRad(bLng - aLng);
    final x =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(toRad(aLat)) * math.cos(toRad(bLat)) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
    return ((earthRadiusKm * c) * 10).round() / 10;
  }
}
