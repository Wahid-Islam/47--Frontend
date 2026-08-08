import 'package:equatable/equatable.dart';

/// Immutable domain model mirroring the `public.clinics` Supabase table.
/// [distanceKm] is not stored in the database; it is computed on-device
/// once a reference location is known and attached via [copyWith].
class Clinic extends Equatable {
  const Clinic({
    required this.id,
    required this.name,
    required this.state,
    required this.city,
    required this.lat,
    required this.lng,
    this.services = const [],
    this.distanceKm,
  });

  final String id;
  final String name;
  final String state;
  final String city;
  final double lat;
  final double lng;
  final List<String> services;
  final double? distanceKm;

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      services: (json['services'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'city': city,
      'lat': lat,
      'lng': lng,
      'services': services,
    };
  }

  Clinic copyWith({double? distanceKm}) {
    return Clinic(
      id: id,
      name: name,
      state: state,
      city: city,
      lat: lat,
      lng: lng,
      services: services,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  @override
  List<Object?> get props => [id, name, state, city, lat, lng, services, distanceKm];
}
