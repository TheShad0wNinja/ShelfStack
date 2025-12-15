import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:shelfstack/core/constants/api_keys.dart';

Future<String> fetchAddressFromLatLng(LatLng latLng) async {
  Uri uri = Uri.https("geocode.maps.co", '/reverse', {
    "lat": latLng.latitude.toString(),
    "lon": latLng.longitude.toString(),
    "api_key": geocodeApiKey,
  });

  final res = await http.get(uri);

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    return data["display_name"];
  }

  return "Unknown Address";
}
