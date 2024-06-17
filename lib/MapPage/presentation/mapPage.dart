import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPage();
}

class _MapPage extends State<MapPage> {
  late GoogleMapController mapController;
  LatLng? _currentLocation;
  bool gotLocation = false;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeAndroidMapRenderer();
    }
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
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        gotLocation = true;
      });
    } catch (e) {
      print("Error getting current location: $e");
      // Default location if there's an error
      setState(() {
        _currentLocation = const LatLng(38.7223, -9.1393); // Default to Lisbon
        gotLocation = true;
      });
    }
  }

  //Function is not usable on web, will return null value
  Future<void> _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations;
      if (kIsWeb) {
        locations = [];
      } else {
        locations = await locationFromAddress(address);
      }
      if (locations.isEmpty) {
        print("No locations found for the address: $address");
        return Future.value();
      }
      Location location = locations.first;
      LatLng newLatLng = LatLng(location.latitude, location.longitude);
      CameraPosition newPos = CameraPosition(target: newLatLng, zoom: 13.0);
      mapController.animateCamera(CameraUpdate.newCameraPosition(newPos)); // Set the camera center to given LatLng
      setState(() {
        _currentLocation = newLatLng;
      });
      print("LATLNG: $newLatLng");
    } catch (e) {
      print("Error getting location from address: $e");
      return Future.error(e);
    }
  }

  Future<void> _initializeAndroidMapRenderer() async {
    final GoogleMapsFlutterPlatform platform = GoogleMapsFlutterPlatform.instance;
    (platform as GoogleMapsFlutterAndroid).useAndroidViewSurface = true;
    await _initializeMapRenderer();
  }

  Future<AndroidMapRenderer?> _initializeMapRenderer() async {
    Completer<AndroidMapRenderer?> completer = Completer<AndroidMapRenderer?>();
    WidgetsFlutterBinding.ensureInitialized();
    final GoogleMapsFlutterPlatform platform = GoogleMapsFlutterPlatform.instance;
    unawaited((platform as GoogleMapsFlutterAndroid)
        .initializeWithRenderer(AndroidMapRenderer.latest)
        .then((AndroidMapRenderer initializedRenderer) =>
        completer.complete(initializedRenderer)));
    return completer.future;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                height: 70,
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
            child: gotLocation
                ? Column(
              children: [
                if (!kIsWeb)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Procurar',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) {
                        _getLatLngFromAddress(value);
                      },
                    ),
                  ),
                Expanded(
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation ?? const LatLng(0, 0),
                      zoom: 13.0,
                    ),
                  ),
                ),
              ],
            )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
