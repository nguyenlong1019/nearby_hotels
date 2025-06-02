import 'dart:convert';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HotelMapPage extends StatefulWidget {
  const HotelMapPage({super.key});

  @override
  State<HotelMapPage> createState() => _HotelMapPageState();
}

class _HotelMapPageState extends State<HotelMapPage> {
  static const String MAPBOX_ACCESS_TOKEN = 'sk.eyJ1IjoibGlnaHRuZW9uIiwiYSI6ImNtYmR4M2x6bzI3bzYya3M2Y2JkeW85YXIifQ.RwLEVrReBvpVGFtZOF8Z-Q';
  static Point defaultCenter = Point(coordinates: Position(109.1967, 12.2388)); // Nha Trang

  MapboxMap? _mapboxMap;
  PointAnnotationManager? _annotationManager;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _annotationManager = await mapboxMap.annotations.createPointAnnotationManager();

    _mapboxMap?.setCamera(CameraOptions(center: defaultCenter, zoom: 14));
    _addMarker(defaultCenter, 'Vị trí mặc định');


  }

  Future<void> _addMarker(Point point, String title) async {
    final annotation = PointAnnotationOptions(
      geometry: point,
      iconImage: "marker-15",
      textField: title,
      textOffset: [0, 1.5],
    );
    await _annotationManager?.create(annotation);
  }

  Future<void> _searchPlace(String query) async {
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json?access_token=$MAPBOX_ACCESS_TOKEN&limit=1',
    );
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (data['features'] != null && data['features'].isNotEmpty) {
      final feature = data['features'][0];
      final coords = feature['geometry']['coordinates'];
      final Point newLocation = Point(coordinates: Position(coords[0], coords[1]));

      _mapboxMap?.setCamera(CameraOptions(center: newLocation, zoom: 14));
      _addMarker(newLocation, feature['place_name']);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy địa điểm.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khách sạn Nha Trang (Mapbox)'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nhập địa điểm...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _searchPlace,
            ),
          ),
          Expanded(
            child: MapWidget(
              key: const ValueKey("mapWidget"),
              cameraOptions: CameraOptions(center: defaultCenter, zoom: 14),
              onMapCreated: _onMapCreated,
            ),
          ),
        ],
      ),
    );
  }
}
