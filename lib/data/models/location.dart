import 'package:latlong2/latlong.dart';

class Location {
  final double latitude;
  final double longitude;
  final String label;
  final String address;

  const Location({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.address,
  });

  Location copyWith({
    double? latitude,
    double? longitude,
    String? label,
    String? address,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      label: label ?? this.label,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'Location{latitude: $latitude, longitude: $longitude, label: $label, address: $address}';
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'label': label,
      'address': address,
    };
  }

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      label: json['label'] as String,
      address: json['address'] as String,
    );
  }
}
