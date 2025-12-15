import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelfstack/core/utils/snack_notification_helper.dart';
import 'package:shelfstack/features/map/util/location_helper.dart';
import 'package:shelfstack/features/map/util/ui_helper.dart';
import 'package:shelfstack/features/map/widgets/location_fab.dart';

class LocationPickerView extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerView({super.key, this.initialLocation});

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  LatLng? _pickedLocation;
  LatLng? _userLocation;
  final MapController _mapController = MapController();
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
    if (widget.initialLocation == null) {
      _moveToCurrentLocation();
    }
  }

  void _confirmSelection() {
    if (_pickedLocation != null) {
      Navigator.of(context).pop(_pickedLocation);
    }
  }

  Future<void> _moveToCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });

    try {
      final position = await getUserPosition();
      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _userLocation = newLocation;
        if (_pickedLocation == null || widget.initialLocation == null) {
          _pickedLocation = newLocation;
        }
      });

      _mapController.move(newLocation, 15);
    } catch (e) {
      if (mounted) {
        SnackNotificationHelper.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _pickedLocation != null ? _confirmSelection : null,
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.initialLocation ?? const LatLng(0, 0),
          initialZoom: 18,
          onTap: (_, point) => setState(() {
            _pickedLocation = point;
          }),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.shelfstack',
          ),
          MapCompass.cupertino(),
          if (_userLocation != null || _pickedLocation != null)
            MarkerLayer(
              markers: [
                if (_userLocation != null)
                  createUserLocationMarker(_userLocation!),
                if (_pickedLocation != null)
                  createPointMarker(_pickedLocation!),
              ],
            ),
        ],
      ),
      floatingActionButton: LocationFAB(
        onPressed: _moveToCurrentLocation,
        isLoading: _isLocating,
      ),
    );
  }
}
