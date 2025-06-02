// // import 'dart:convert';
// // import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;

// // class HotelMapPage extends StatefulWidget {
// //   const HotelMapPage({super.key});

// //   @override
// //   State<HotelMapPage> createState() => _HotelMapPageState();
// // }

// // class _HotelMapPageState extends State<HotelMapPage> {
// //   static const String MAPBOX_ACCESS_TOKEN = 'sk.eyJ1IjoibGlnaHRuZW9uIiwiYSI6ImNtYmR4M2x6bzI3bzYya3M2Y2JkeW85YXIifQ.RwLEVrReBvpVGFtZOF8Z-Q';
// //   static Point defaultCenter = Point(coordinates: Position(109.1967, 12.2388)); // Nha Trang

// //   MapboxMap? _mapboxMap;
// //   PointAnnotationManager? _annotationManager;
// //   final TextEditingController _searchController = TextEditingController();

// //   @override
// //   void initState() {
// //     super.initState();
// //   }

// //   void _onMapCreated(MapboxMap mapboxMap) async {
// //     _mapboxMap = mapboxMap;
// //     _annotationManager = await mapboxMap.annotations.createPointAnnotationManager();

// //     _mapboxMap?.setCamera(CameraOptions(center: defaultCenter, zoom: 14));
// //     _addMarker(defaultCenter, 'Vị trí mặc định');


// //   }

// //   Future<void> _addMarker(Point point, String title) async {
// //     final annotation = PointAnnotationOptions(
// //       geometry: point,
// //       iconImage: "marker-15",
// //       textField: title,
// //       textOffset: [0, 1.5],
// //     );
// //     await _annotationManager?.create(annotation);
// //   }

// //   Future<void> _searchPlace(String query) async {
// //     final url = Uri.parse(
// //       'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json?access_token=$MAPBOX_ACCESS_TOKEN&limit=1',
// //     );
// //     final response = await http.get(url);
// //     final data = jsonDecode(response.body);

// //     if (data['features'] != null && data['features'].isNotEmpty) {
// //       final feature = data['features'][0];
// //       final coords = feature['geometry']['coordinates'];
// //       final Point newLocation = Point(coordinates: Position(coords[0], coords[1]));

// //       _mapboxMap?.setCamera(CameraOptions(center: newLocation, zoom: 14));
// //       _addMarker(newLocation, feature['place_name']);

// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Không tìm thấy địa điểm.')),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Khách sạn Nha Trang (Mapbox)'),
// //       ),
// //       body: Column(
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.all(8.0),
// //             child: TextField(
// //               controller: _searchController,
// //               decoration: InputDecoration(
// //                 hintText: 'Nhập địa điểm...',
// //                 filled: true,
// //                 fillColor: Colors.white,
// //                 prefixIcon: const Icon(Icons.search),
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                   borderSide: BorderSide.none,
// //                 ),
// //               ),
// //               onSubmitted: _searchPlace,
// //             ),
// //           ),
// //           Expanded(
// //             child: MapWidget(
// //               key: const ValueKey("mapWidget"),
// //               cameraOptions: CameraOptions(center: defaultCenter, zoom: 14),
// //               onMapCreated: _onMapCreated,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// class HotelMapPage extends StatefulWidget {
//   const HotelMapPage({super.key});

//   @override
//   State<HotelMapPage> createState() => _HotelMapPageState();
// }

// class _HotelMapPageState extends State<HotelMapPage> {
//   static const String MAPBOX_ACCESS_TOKEN = 'YOUR_ACCESS_TOKEN';
//   static Point defaultCenter = Point(coordinates: Position(109.1967, 12.2388)); // Khách sạn Hoàng Long

//   late MapboxMap _mapboxMap;
//   PointAnnotationManager? _pointAnnotationManager;
//   PolylineAnnotationManager? _polylineAnnotationManager;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Bản đồ du lịch')),
//       body: MapWidget(
//         key: const ValueKey("mapWidget"),
//         // resourceOptions: ResourceOptions(accessToken: MAPBOX_ACCESS_TOKEN),
//         cameraOptions: CameraOptions(center: defaultCenter, zoom: 14.0),
//         onMapCreated: (controller) async {
//           _mapboxMap = controller;
//           _pointAnnotationManager = await _mapboxMap.annotations.createPointAnnotationManager();
//           _polylineAnnotationManager = await _mapboxMap.annotations.createPolylineAnnotationManager();
//           _fetchPOIs();
//         },
//       ),
//     );
//   }

//   Future<void> _fetchPOIs() async {
//     final categories = ['cafe', 'restaurant', 'supermarket'];
//     for (String category in categories) {
//       final url =
//           'https://api.mapbox.com/geocoding/v5/mapbox.places/$category.json?proximity=109.1967,12.2388&language=vi&limit=5&access_token=$MAPBOX_ACCESS_TOKEN';

//       final res = await http.get(Uri.parse(url));
//       final data = jsonDecode(res.body);

//       if (data['features'] != null) {
//         for (var feature in data['features']) {
//           final lon = feature['geometry']['coordinates'][0];
//           final lat = feature['geometry']['coordinates'][1];
//           final placeName = feature['text'];

//           final annotation = PointAnnotationOptions(
//             geometry: Point(coordinates: Position(lon, lat)),
//             iconImage: "restaurant-15",
//             iconSize: 1.5,
//           );

//           final created = await _pointAnnotationManager!.create(annotation);
//           _pointAnnotationManager!.addTapListener((annotation) {
//             _drawRouteToDestination(annotation.geometry as Point);
//           });
//         }
//       }
//     }
//   }

//   Future<void> _drawRouteToDestination(Point destination) async {
//     _polylineAnnotationManager?.deleteAll();

//     final origin = defaultCenter;
//     final url =
//         'https://api.mapbox.com/directions/v5/mapbox/driving/${origin.coordinates.lng},${origin.coordinates.lat};${destination.coordinates.lng},${destination.coordinates.lat}?geometries=geojson&overview=full&access_token=$MAPBOX_ACCESS_TOKEN';

//     final res = await http.get(Uri.parse(url));
//     final data = jsonDecode(res.body);

//     final coordinates = data['routes'][0]['geometry']['coordinates'] as List;

//     final List<Position> positions = coordinates.map((coord) {
//       return Position(coord[0], coord[1]);
//     }).toList();

//     await _polylineAnnotationManager!.create(PolylineAnnotationOptions(
//       geometry: LineString(coordinates: positions),
//       lineColor: Colors.blue.value,
//       lineWidth: 5.0,
//     ));

//     _mapboxMap.flyTo(CameraOptions(center: destination, zoom: 15.0));
//   }
// }
