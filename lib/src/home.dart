import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';


class HotelMapPage extends StatefulWidget {
  const HotelMapPage({super.key});

  @override
  State<HotelMapPage> createState() => _HotelMapPageState();
}

class _HotelMapPageState extends State<HotelMapPage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(12.2388, 109.1967);
  LatLng? _currentPosition;
  List<LatLng> _polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  final TextEditingController _searchController = TextEditingController();

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // _fetchNearbyHotels();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(position.latitude, position.longitude);

    setState(() {
      _fetchNearbyHotels();
    });
  }

  void _fetchNearbyHotels() async {
    const apiKey = 'AIzaSyDa_LOsiEAcWTHaOzLyBU9hw7BkV9iCBMc';
    final origin = _currentPosition ?? _center;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${origin.latitude},${origin.longitude}&radius=2000&type=lodging&key=$apiKey',
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);
    final results = data['results'] as List;

    setState(() {
      _markers = results.map((place) {
        final lat = place['geometry']['location']['lat'];
        final lng = place['geometry']['location']['lng'];
        final name = place['name'];
        return Marker(
          markerId: MarkerId(name),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name),
          onTap: () => _getDirections(LatLng(lat, lng)), // khi bấm vào marker
        );
      }).toSet();

      // đánh dấu vị trí người dùng
      _markers.add(
        Marker(
          markerId: const MarkerId("me"),
          position: origin,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: "Vị trí của bạn"),
        ),
      );
    });
  }

  void _getDirections(LatLng destination) async {
    const apiKey = 'AIzaSyDa_LOsiEAcWTHaOzLyBU9hw7BkV9iCBMc';
    final origin = _currentPosition ?? _center;

    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      apiKey,
      PointLatLng(origin.latitude, origin.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      _polylineCoordinates.clear();
      for (var point in result.points) {
        _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: _polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        };
      });
    }
  }

  // void _fetchNearbyHotelsOld() async {
  //   const apiKey = 'AIzaSyDa_LOsiEAcWTHaOzLyBU9hw7BkV9iCBMc';
  //   final url = Uri.parse(
  //     'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_center.latitude},${_center.longitude}&radius=2000&type=lodging&key=$apiKey',
  //   );

  //   final response = await http.get(url);
  //   final data = jsonDecode(response.body);

  //   final results = data['results'] as List;

  //   setState(() {
  //     _markers = results.map((place) {
  //       final lat = place['geometry']['location']['lat'];
  //       final lng = place['geometry']['location']['lng'];
  //       final name = place['name'];
  //       return Marker(
  //         markerId: MarkerId(name),
  //         position: LatLng(lat, lng),
  //         infoWindow: InfoWindow(title: name),
  //       );
  //     }).toSet();
  //   });
  // }

  Future<void> _searchPlace(String query) async {
    const apiKey = 'AIzaSyDa_LOsiEAcWTHaOzLyBU9hw7BkV9iCBMc';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey',
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      final place = data['results'][0];
      final lat = place['geometry']['location']['lat'];
      final lng = place['geometry']['location']['lng'];
      final name = place['name'];

      final LatLng newPosition = LatLng(lat, lng);

      setState(() {
        mapController.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 16));
        _markers.add(Marker(
          markerId: MarkerId(name),
          position: newPosition,
          infoWindow: InfoWindow(title: name),
        ));
      });
    } else {
      print("Tìm kiếm thất bại: ${data['status']} - ${data['error_message']}");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khách sạn Nha Trang'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nhập tên khách sạn hoặc địa điểm...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) => _searchPlace(value),
            ),
          ),
        ),
      ),
      body: GoogleMap(
        onMapCreated: (controller) => mapController = controller,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 14.0,
        ),
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }
}
