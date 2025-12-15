import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Marker createPointMarker(LatLng point) {
  return Marker(
    point: point,
    rotate: true,
    width: 48,
    height: 48,
    child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 48),
  );
}

Marker createUserLocationMarker(LatLng point) {
  return Marker(
    point: point,
    width: 48,
    height: 48,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(70),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.my_location, color: Colors.blue, size: 24),
    ),
  );
}
