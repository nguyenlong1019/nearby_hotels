import 'package:flutter/material.dart';
import 'package:nearby_hotels/src/home.dart';


void main() {
  // const String ACCESS_TOKEN = 'sk.eyJ1IjoibGlnaHRuZW9uIiwiYSI6ImNtYmR4M2x6bzI3bzYya3M2Y2JkeW85YXIifQ.RwLEVrReBvpVGFtZOF8Z-Q';
  WidgetsFlutterBinding.ensureInitialized();
  // MapboxOptions.setAccessToken(ACCESS_TOKEN);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nearby Hotels Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HotelMapPage(),
    );
  }
}
