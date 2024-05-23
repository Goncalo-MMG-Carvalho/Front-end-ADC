import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPage();
}

class _MapPage extends State<MapPage> {

  late GoogleMapController mapController;
  late LatLng _currentLocation;
  bool gotLocation = false;
  final _controller = TextEditingController();

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
      gotLocation = true;
    });
  }

  Future<Location> getLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      return locations.first;
    } catch (e) {
      throw Exception('Failed to get location');
    }
  }

  /*
  void printLocationFromAddress() async {
    Location location = await getLocationFromAddress("1600 Amphitheatre Parkway, Mountain View, CA");
    print("Latitude: ${location.latitude}, Longitude: ${location.longitude}");
  }
   */

  void _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      Location location = locations.first;
      LatLng newLatLng = LatLng(location.latitude, location.longitude);
      
      mapController.animateCamera(CameraUpdate.newLatLng(newLatLng)); //set the camera center to given latlng
      print("New location = $newLatLng");

      setState(() {
        _currentLocation = newLatLng;
      });
    } catch (e) {
      print(e);
    }
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
                  child: gotLocation ?
                  Column(
                    children: [Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter location',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value){
                      _getLatLngFromAddress(value);
                    },
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation,
                      zoom: 13.0,
                    ),
                  ),
                )
                    ])
                      : const Center(child: CircularProgressIndicator())
                )
            )
        )
    );
  }
}