import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
  StreamSubscription<Position>? positionStream;
  Set<Marker> markers = {};
  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _updateUserLocation();
    if (_currentLocation != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation!, zoom: 15),
      ));
    }
  }

  Future<void> _checkPermissions() async {
    if (await Permission.location.request().isGranted) {
      setState(() {
        _getCurrentLocation();
        gotLocation = true;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = newLocation;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error getting current location: $e");
      }
      // Default location if there's an error
      setState(() {
        _currentLocation = const LatLng(38.7223, -9.1393); // Default to Lisbon
      });
    }
  }

  void _updateUserLocation() {
    try {
      _getCurrentLocation();
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position position) {
            LatLng newLocation = LatLng(position.latitude, position.longitude);
            setState(() {
              _currentLocation = newLocation;
            });
          });

      setState(() {
        gotLocation = true;
      });
    }
    catch (e) {
      if (kDebugMode) {
        print("Error updating user location: $e");
      }
      // Default location if there's an error
      setState(() {
        _currentLocation = const LatLng(38.7223, -9.1393); // Default to Lisbon
      });
    }
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

    Marker startMarker = Marker(
      markerId: const MarkerId('Initial'),
      position: _currentLocation!,
      infoWindow: const InfoWindow(
        title: 'Start Location',
        snippet: 'This is the starting point',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('Destination'),
      position: _destinationLocation!,
      infoWindow: const InfoWindow(
        title: 'Destination',
        snippet: 'This is the destination',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    markers.add(startMarker);
    markers.add(destinationMarker);

    double startLatitude = _currentLocation!.latitude;
    double startLongitude =_currentLocation!.longitude;
    double destinationLatitude = _destinationLocation!.latitude;
    double destinationLongitude = _destinationLocation!.longitude;
    double miny = (startLatitude <= destinationLatitude)
        ? startLatitude
        : destinationLatitude;
    double minx = (startLongitude <= destinationLongitude)
        ? startLongitude
        : destinationLongitude;
    double maxy = (startLatitude <= destinationLatitude)
        ? destinationLatitude
        : startLatitude;
    double maxx = (startLongitude <= destinationLongitude)
        ? destinationLongitude
        : startLongitude;

    double southWestLatitude = miny;
    double southWestLongitude = minx;

    double northEastLatitude = maxy;
    double northEastLongitude = maxx;

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(northEastLatitude, northEastLongitude),
          southwest: LatLng(southWestLatitude, southWestLongitude),
        ),
        100.0,
      ),
    );

    polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyBqOT9eOL5T49H89B4539h4zbiy0OpP0sE',
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    if(result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = const PolylineId('poly');

    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;

    setState(() {});
  }

  final Map<PolylineId, Polyline> _polylines = {};

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
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomGesturesEnabled: kIsWeb ? false : true,
                  zoomControlsEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? const LatLng(38.7223, -9.1393),
                    zoom: 13.0,
                  ),
                  markers: Set<Marker>.from(markers),
                  polylines: Set<Polyline>.of(polylines.values),
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
