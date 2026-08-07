import 'package:equatable/equatable.dart';

import '../../model/profile.dart';

enum ProfileStatus { initial, loading, ready, saving, error }

const Object _unset = Object();

class ProfileState extends Equatable {
  const ProfileState({this.status = ProfileStatus.initial, this.profile, this.errorMessage});

  final ProfileStatus status;
  final Profile? profile;
  final String? errorMessage;

  bool get isBusy => status == ProfileStatus.loading || status == ProfileStatus.saving;

  ProfileState copyWith({ProfileStatus? status, Object? profile = _unset, Object? errorMessage = _unset}) {
    return ProfileState(
      status: status ?? this.status,
      profile: identical(profile, _unset) ? this.profile : profile as Profile?,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
