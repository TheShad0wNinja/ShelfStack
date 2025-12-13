import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openMap(LatLng latLng) async {
  final uri = Uri.https('www.google.com', '/maps/search/',
    {
      "api": "1",
      "query": "${latLng.latitude},${latLng.longitude}"
    }
  );

  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    throw Exception("Could not open map");
  }
}