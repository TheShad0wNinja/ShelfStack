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
}
