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
  LatLng? _destinationLocation;
  bool gotLocation = false;
  bool showRouteButton = false;
  final _controller = TextEditingController();
  Marker? _userMarker;
  Circle? _userCircle;
  StreamSubscription<Position>? positionStream;

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
    _getCurrentLocation();
    if (_currentLocation != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation!, zoom: 15),
      ));
    }
  }

  Future<void> _checkPermissions() async {
    if (await Permission.location.request().isGranted) {
      setState(() {
        gotLocation = true;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateUserLocation(position);

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        _updateUserLocation(position);
      });

      setState(() {
        gotLocation = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error getting current location: $e");
      }
      // Default location if there's an error
      setState(() {
        _currentLocation = const LatLng(38.7223, -9.1393); // Default to Lisbon
        gotLocation = true;
      });
    }
  }

  void _updateUserLocation(Position position) {
    LatLng newLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentLocation = newLocation;
      _userMarker = Marker(
        markerId: const MarkerId("user_marker"),
        position: newLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      _userCircle = Circle(
        circleId: const CircleId("user_circle"),
        center: newLocation,
        radius: 50,
        strokeColor: Colors.blue,
        strokeWidth: 2,
        fillColor: Colors.blue.withOpacity(0.2),
      );
    });

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: newLocation, zoom: 15),
      ),
    );
    }

  Future<void> _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isEmpty) {
        if (kDebugMode) {
          print("No locations found for the address: $address");
        }
        return;
      }
      Location location = locations.first;
      LatLng newLatLng = LatLng(location.latitude, location.longitude);
      CameraPosition newPos = CameraPosition(target: newLatLng, zoom: 13.0);
      mapController.animateCamera(CameraUpdate.newCameraPosition(newPos)); // Set the camera center to given LatLng
      setState(() {
        _destinationLocation = newLatLng;
        showRouteButton = true;
      });
      if (kDebugMode) {
        print("LATLNG: $newLatLng");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting location from address: $e");
      }
    }
  }

  Future<void> _createRoute() async {
    if (_currentLocation == null || _destinationLocation == null) return;

    // Example implementation: Just draw a line between the two points.
    // For real-world applications, you might want to use a service like Google Directions API.
    const PolylineId polylineId = PolylineId('route');
    final Polyline polyline = Polyline(
      polylineId: polylineId,
      color: Colors.blue,
      points: [_currentLocation!, _destinationLocation!],
      width: 5,
    );

    setState(() {
      _polylines[polylineId] = polyline;
    });
  }

  final Map<PolylineId, Polyline> _polylines = {};

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
    positionStream?.cancel();
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
          body: gotLocation
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
              if (showRouteButton)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _createRoute,
                    child: const Text('Create Route'),
                  ),
                ),
              Expanded(
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? const LatLng(0, 0),
                    zoom: 13.0,
                  ),
                  markers: _userMarker != null ? {_userMarker!} : {},
                  circles: _userCircle != null ? {_userCircle!} : {},
                  polylines: Set<Polyline>.of(_polylines.values),
                ),
              ),
            ],
          )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
