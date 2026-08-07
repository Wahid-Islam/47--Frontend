import 'package:equatable/equatable.dart';

import '../../model/clinic.dart';

enum ClinicsStatus { initial, loading, ready, error }

class ClinicsState extends Equatable {
  const ClinicsState({this.status = ClinicsStatus.initial, this.clinics = const [], this.errorMessage});

  final ClinicsStatus status;
  final List<Clinic> clinics;
  final String? errorMessage;

  ClinicsState copyWith({ClinicsStatus? status, List<Clinic>? clinics, String? errorMessage}) {
    return ClinicsState(
      status: status ?? this.status,
      clinics: clinics ?? this.clinics,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, clinics, errorMessage];
}
