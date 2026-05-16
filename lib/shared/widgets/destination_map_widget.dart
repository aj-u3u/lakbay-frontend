import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DestinationMapWidget extends StatelessWidget {
  final String destinationName;
  final LatLng coordinates;

  const DestinationMapWidget({
    super.key,
    required this.destinationName,
    required this.coordinates,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.coordinates(
          coordinates: [coordinates],
          padding: const EdgeInsets.all(60),
        ),
        maxZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.lakbay_plus',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: coordinates,
              width: 80,
              height: 80,
              child: const Icon(Icons.location_on, size: 60, color: Colors.red),
            ),
          ],
        ),
        RichAttributionWidget(
          // Include a stylish prebuilt attribution widget that meets all requirments
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors', // (external)
            ),
            // Also add images...
          ],
        ),
      ],
    );
  }
}
