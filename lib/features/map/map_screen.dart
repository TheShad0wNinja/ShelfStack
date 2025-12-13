import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';

import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/features/inventory/widgets/container_row.dart';

import 'map_viewmodel.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) =>
          MapViewModel(context.read<ContainerRepository>()),
      child: _MapScreenContent(),
    );
  }
}

class _MapScreenContent extends StatefulWidget {
  @override
  State<_MapScreenContent> createState() => _MapScreenContentState();
}

class _MapScreenContentState extends State<_MapScreenContent> {
  final MapController _mapController = MapController();
  bool _isNavigatingToLocation = false;

  @override
  void initState() {
    super.initState();
  }

  void _navigateToLocation() async {
    final vm = context.read<MapViewModel>();
    setState(() {
      _isNavigatingToLocation = true;
    });

    await vm.getCurrentLocation();

    setState(() {
      _isNavigatingToLocation = false;
    });

    if (vm.userLocation != null) {
      _mapController.move(vm.userLocation!, 13);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${vm.error}'),
                ElevatedButton(
                  onPressed: () => vm.init(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final markerMap = <Marker, models.Container>{};
        final markers = vm.containers.map((c) {
          final marker = Marker(
            point: c.location.toLatLng(),
            width: 48,
            height: 48,
            child: Icon(
              Icons.location_on_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          );
          markerMap[marker] = c;
          return marker;
        }).toList();

        if (vm.userLocation != null) {
          markers.add(
            Marker(
              point: vm.userLocation!,
              width: 48,
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(70),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
            ),
          );
        }

        final LatLng initialCenter;
        if (vm.userLocation != null) {
          initialCenter = vm.userLocation!;
        } else if (vm.containers.isNotEmpty) {
          initialCenter = vm.containers.first.location.toLatLng();
        } else {
          initialCenter = const LatLng(0, 0);
        }

        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.shelfstack',
                  ),
                  MapCompass.cupertino(),
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 45,
                      size: const Size(40, 40),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(50),
                      maxZoom: 15,
                      markers: markers,
                      zoomToBoundsOnClick: false,
                      spiderfyCluster: false,
                      showPolygon: false,
                      builder: (context, markers) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          child: Center(
                            child: Text(
                              markers.length.toString(),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: Theme.of(context).colorScheme.onTertiary),
                            ),
                          ),
                        );
                      },
                      onMarkerTap: (marker) {
                        final container = markerMap[marker];
                        if (container != null) {
                          _showContainerList(context, [container]);
                        }
                      },
                      onClusterTap: (cluster) {
                        final containers = cluster.mapMarkers
                            .map((m) => markerMap[m])
                            .whereType<models.Container>()
                            .toList();
                        _showContainerList(context, containers);
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 120,
                right: 16,
                child: FloatingActionButton(
                  onPressed: _navigateToLocation,
                  child: _isNavigatingToLocation
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary),
                        )
                      : const Icon(Icons.my_location),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showContainerList(
    BuildContext context,
    List<models.Container> containers,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Containers (${containers.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: containers.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        return ContainerRow(container: containers[index]);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
