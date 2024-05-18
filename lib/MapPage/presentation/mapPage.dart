import 'package:adc_handson_session/AppPage/presentation/appPage_screen.dart';
import 'package:flutter/material.dart';
import 'package:adc_handson_session/login/application/auth.dart';
import 'package:adc_handson_session/login/presentation/main_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../register/presentation/regist_screen.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPage();
}

class _MapPage extends State<MapPage> {

  late GoogleMapController mapController;
  late LatLng _currentLocation;


  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _checkPermissions() async {
    if (await Permission.location.request().isGranted) {
      _getCurrentLocation();
    } else {
      // Handle the case if permissions are not granted
      // You can show a dialog explaining why the app needs location permissions
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Green Life',
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
                  title: Center(
                    child: Image.asset(
                      'assets/logo.png', // Replace with your image path
                      height: 70, // Adjust the height as needed
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: const Color.fromRGBO(121, 135, 119, 1),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
                body: Container(
                  child: _currentLocation != null
                      ? GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation,
                      zoom: 11.0,
                    ),
                  )
                      : Center(child: CircularProgressIndicator()),
                ),
            )
        )
    );
  }
}