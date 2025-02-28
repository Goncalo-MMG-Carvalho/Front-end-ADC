import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart' as g_place;
import 'package:url_launcher/url_launcher.dart';
import '../../Utils/constants.dart' as constants;
import '../../Utils/userUtils.dart';
import '../../exceptions/invalid_token.dart';
import '../application/auth.dart';


const API_KEY = constants.MAPS_API_KEY_WEB;

const POI_DISTANCE = 15; //distance in the map at which it'll try to find a point of interest when tapped (in meters)
const TRANSIT_DISTANCE = 2000; //same as above but for transit terminals around user

class WebMapPage extends StatefulWidget {
  const WebMapPage({super.key});

  @override
  State<WebMapPage> createState() => _WebMapPage();
}

class _WebMapPage extends State<WebMapPage> {
  late GoogleMapController mapController;
  LatLng? currentLocation;
  LatLng? destinationLocation;
  LatLng? lastDestination;
  bool gotLocation = false;
  bool showRouteButton = false;
  bool hasRoute = false;
  final _controller = TextEditingController();
  StreamSubscription<Position>? positionStream;
  Set<Marker> markers = {};
  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  late g_place.GooglePlace googlePlace;
  String selectedTransportationMode = 'transit';
  final Dio dio = Dio();
  bool isSeccioned = false;
  AuthenticationMap auth = AuthenticationMap();
  int totalStops = 0;
  Set<Marker> persistentMarkers = {};
  bool routeChanged = false;  //checks if route has been modified to not send duped routes to server


  double routeEmissions = 0;
  double routeDistance = 0;

  double totalDuration = 0;
  double totalDistance = 0;
  double drivingDistance = 0;
  double walkingDistance = 0;
  double transitDistance = 0;
  double bicyclingDistance = 0;
  LatLng? finalDestination;

  @override
  void initState() {
    super.initState();
    checkPermissions();

    googlePlace = g_place.GooglePlace(API_KEY);
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    updateUserLocation();
    drawTransports();
    if (currentLocation != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLocation!, zoom: 15),
      ));
    }
  }

  Future<void> checkPermissions() async {
    if (await Permission.location.request().isGranted) {
      await getCurrentLocation();
      setState(() {
        if(mounted) {
          gotLocation = true;
        }
      });
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        currentLocation = newLocation;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error getting current location: $e");
      }
      // Default location if there's an error
      setState(() {
        if(mounted) {
          currentLocation = const LatLng(38.7223, -9.1393);
        }// Default to Lisbon
      });
    }
  }

  void updateUserLocation()  {
    try {
      getCurrentLocation();
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) async {
            LatLng newLocation = LatLng(position.latitude, position.longitude);
            setState(() {
              currentLocation = newLocation;
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
        currentLocation = const LatLng(38.7223, -9.1393); // Default to Lisbon
      });
    }
  }

  Future<void> getLatLngFromAddress(String address) async {
    try {
      var result = await googlePlace.search.getTextSearch(address);
      if (result != null && result.results != null) {
        setState(() {
          markers.clear();
          for (var place in result.results!) {
            LatLng newLatLng = LatLng(
                place.geometry!.location!.lat!, place.geometry!.location!.lng!);
            markers.add(Marker(
                markerId: MarkerId(place.placeId!),
                position: newLatLng,
                infoWindow: InfoWindow(
                  title: place.name,
                  snippet: place.formattedAddress,
                ),
                onTap: () {
                  setState(() {
                    destinationLocation = newLatLng;
                    showRouteButton = true;
                  });
                }
            ));
          }
        });

        if (result.results!.isNotEmpty) {
          var firstPlace = result.results!.first;
          LatLng firstLatLng = LatLng(firstPlace.geometry!.location!.lat!,
              firstPlace.geometry!.location!.lng!);
          setState(() {
            mapController.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: firstLatLng, zoom: 13.0)));
            destinationLocation = firstLatLng;
            showRouteButton = true;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting location from address: $e");
      }
    }
  }

  void markerFromTap(LatLng latlng) async {
    var result = await googlePlace.search.getNearBySearch(g_place.Location(lat: latlng.latitude, lng: latlng.longitude), POI_DISTANCE, type: 'point_of_interest');
    Marker resultMarker;
    if (result == null || result.results == null || result.results!.isEmpty) {
      resultMarker = Marker(
          markerId: const MarkerId('tapMarker'),
          position: latlng,
          infoWindow: InfoWindow(
            title: 'Custom marker',
            snippet: '${latlng.latitude}, ${latlng.longitude}',
          ),
          onTap: () {
            setState(() {
              destinationLocation = latlng;
              showRouteButton = true;
            });
          }
      );
      setState(() {
        destinationLocation = latlng;
        markers.add(resultMarker);
        showRouteButton = true;
      });
    }
    else {
      var place = result.results!.first;
      LatLng placeLocation = LatLng(
          place.geometry!.location!.lat!, place.geometry!.location!.lng!);
      resultMarker = Marker(
          markerId: const MarkerId('tapMarker'),
          position: placeLocation,
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.formattedAddress,
          ),
          onTap: () {
            setState(() {
              destinationLocation = placeLocation;
              showRouteButton = true;
            });
          }
      );
      setState(() {
        destinationLocation = placeLocation;
        markers.add(resultMarker);
        showRouteButton = true;
      });
    }
  }

  Future<void> createRoute() async {
    if (currentLocation == null || destinationLocation == null) return;

    LatLng startLocation; //saves currentLocation if it's the first route search
    Marker startMarker;
    if (lastDestination != null){
      startLocation = lastDestination!;
      isSeccioned = true;

      startMarker = Marker(
          markerId: MarkerId('Stop #${++totalStops}'),
          position: startLocation,
          infoWindow: InfoWindow(
              title: '#$totalStops stop',
              snippet: 'This is the #$totalStops stop'
          ),
        onTap: () {
          setState(() {
            destinationLocation = startLocation;
            showRouteButton = true;
          });
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      );
    }
    else {
      startLocation = currentLocation!;
      startMarker = Marker(
        markerId: const MarkerId('Initial'),
        position: startLocation,
        infoWindow: const InfoWindow(
          title: 'Start Location',
          snippet: 'This is the starting point',
        ),
          onTap: () {
            setState(() {
              destinationLocation = startLocation;
              showRouteButton = true;
            });
          },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }

    Marker destinationMarker = Marker(
      markerId: const MarkerId('Destination'),
      position: destinationLocation!,
      infoWindow: const InfoWindow(
        title: 'Destination',
        snippet: 'This is the destination',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      persistentMarkers.add(startMarker);
      persistentMarkers.add(destinationMarker);
    });

    double startLatitude = startLocation.latitude;
    double startLongitude = startLocation.longitude;
    double destinationLatitude = destinationLocation!.latitude;
    double destinationLongitude = destinationLocation!.longitude;

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(
              startLatitude > destinationLatitude
                  ? startLatitude
                  : destinationLatitude,
              startLongitude > destinationLongitude
                  ? startLongitude
                  : destinationLongitude),
          southwest: LatLng(
              startLatitude < destinationLatitude
                  ? startLatitude
                  : destinationLatitude,
              startLongitude < destinationLongitude
                  ? startLongitude
                  : destinationLongitude),
        ),
        100.0,
      ),
    );

    try {
      print('Trying to send a dio request with this info:\n'
          'origin: $startLatitude,$startLongitude\n'
          'destination: $destinationLatitude,$destinationLongitude\n'
          'mode: $selectedTransportationMode\n'
          'key: $API_KEY');

      // Fetch just normal route data
      dio.options.headers['content-type'] = 'application/json';
      dio.options.headers['x-goog-api-key'] = API_KEY;
      dio.options.headers['x-goog-fieldmask'] =
      'routes.legs.steps.*, routes.legs.distanceMeters';
      var response = await dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '$startLatitude,$startLongitude',
          'destination': '$destinationLatitude,$destinationLongitude',
          'mode': selectedTransportationMode,
          'key': API_KEY,
        },
      );
      if (response.statusCode == 200) {
        var data = response.data;
        if (kDebugMode) {
          print('Printing route data:\n$data');
        }
        if (data['status'] == 'OK') {
          var route = data['routes'][0];
          var steps = route['legs'][0]['steps'] as List<dynamic>;

          if (kDebugMode) {
            print('Printing route:\n$route');
            print('Printing steps:\n$steps');
          }


          for (var step in steps) {
            double polylineStartLat = step['start_location']['lat'];
            double polylineStartLng = step['start_location']['lng'];
            double polylineEndLat = step['end_location']['lat'];
            double polylineEndLng = step['end_location']['lng'];
            String travelMode = step['travel_mode'];
            PolylineId id = PolylineId(travelMode + step.hashCode.toString());

            Polyline polylineStep = Polyline(
              polylineId: id,
              color: Colors.red,
              points: [LatLng(polylineStartLat, polylineStartLng), LatLng(polylineEndLat, polylineEndLng)],
              width: 3,
              patterns: travelMode == 'WALKING' || travelMode == 'BICYCLING'
                  ? [PatternItem.dot, PatternItem.gap(10)]
                  : <PatternItem>[],
            );

            totalDuration += step['duration']['value'];

            switch (travelMode) {
              case 'WALKING':
                walkingDistance += step['distance']['value'];
                break;
              case 'DRIVING':
                drivingDistance += step['distance']['value'];
                break;
              case 'TRANSIT':
                transitDistance += step['distance']['value'];
                break;
              case 'BICYCLING':
                bicyclingDistance += step['distance']['value'];
                break;
              default:
                if (kDebugMode) {
                  print('Unknown travel mode found: $travelMode');
                }
            }

            setState(() {
              polylines[id] = polylineStep;
              routeChanged = true;
            });
          }
          totalDistance += route['legs'][0]['distance']['value'];
        } else {
          if (kDebugMode) {
            print('Data received: ${response.toString()}');
          }
          throw Exception('Failed to load normal route');
        }
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
    } catch (e) {
      print('Error: $e');
    }
    if (selectedTransportationMode == 'driving') { //Fetch eco-routes

      String? userFuelType = await getUserFuelType();
      if (kDebugMode) {
        print('User fuel type: $userFuelType');
      }
      if (userFuelType == null || userFuelType == '' || userFuelType == '0.0') {
        userFuelType = constants.MAPS_FUEL_TYPE_GASOLINE;
      }
      try {
        dio.options.headers['content-type'] = 'application/json';
        dio.options.headers['x-goog-api-key'] = API_KEY;
        dio.options.headers['x-goog-fieldmask'] = 'routes.distanceMeters,routes.routeLabels,routes.travelAdvisory.fuelConsumptionMicroliters';
        var ecoResponse = await dio.post(
            'https://routes.googleapis.com/directions/v2:computeRoutes',
            data: {
              "origin": {
                "location": {
                  "latLng": {
                    "latitude": startLatitude,
                    "longitude": startLongitude
                  }
                }
              },
              "destination": {
                "location": {
                  "latLng": {
                    "latitude": destinationLatitude,
                    "longitude": destinationLongitude
                  }
                }
              },
              "routeModifiers": {
                "vehicleInfo": {
                  "emissionType": userFuelType
                }
              },
              "travelMode": "DRIVE",
              "routingPreference": "TRAFFIC_AWARE_OPTIMAL",
              "extraComputations": ["FUEL_CONSUMPTION"],
              "requestedReferenceRoutes": ["FUEL_EFFICIENT"]
            }
        );

        if (ecoResponse.statusCode == 200) {
          Map<String, dynamic> ecoData = ecoResponse.data;
          if (kDebugMode) {
            print('EcoData:\n$ecoData');
          }
          if (ecoData['routes'] != null) {
            Map<String, dynamic>? defaultRoute;
            for (var route in ecoData['routes']) {
              List<dynamic> labels = route['routeLabels'];
              if (labels.contains('DEFAULT_ROUTE')) {
                defaultRoute = route;
                break;
              }
            }

            if (defaultRoute != null) {
              setState(() {
                routeEmissions += double.parse(
                    defaultRoute!['travelAdvisory']['fuelConsumptionMicroliters']) /
                    1000000; //in liters
                hasRoute = true;
              });
            }
          } else {
            if (kDebugMode) {
              print('No route token found in eco route response');
              print(ecoData.toString());
            }
            throw Exception('Failed to load eco route');
          }
        } else {
          if (kDebugMode) {
            print('Eco route response: ${ecoResponse.data.toString()}');
          }
          throw Exception('Failed to load eco route');
        }
      } on DioException catch (e) {
        print('Dio error: ${e.message}');
      } catch (e) {
        print('Error: $e');
      }
    }

    setState(() {
      lastDestination = destinationLocation;
      finalDestination = destinationLocation;
    });
  }

  void launchGoogleMapsNavigation(LatLng destination) async {
    final Uri googleMapsUrl = Uri.parse('google.navigation:q=${destination.latitude},${destination.longitude}&mode=d');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  Future<String?> getUserFuelType() async {
    var fuelType = await auth.getUserFuelType();
    return fuelType;
  }

  void sendRouteInfo() {
    try{
    if (kDebugMode) {
      print('Information at this time (some of them is unused for now):\n'
          'routeEmissions = $routeEmissions\n'
          'routeDistance = $routeDistance\n'
          'totalDistance = $totalDistance\n'
          'drivingDistance = $drivingDistance\n'
          'walkingDistance = $walkingDistance\n'
          'transitDistance = $transitDistance\n'
          'bicyclingDistance = $bicyclingDistance\n'
          'finalDestination = ${finalDestination.toString()}');
    }
     auth.sendRouteInfo(routeEmissions, transitDistance / 1000);//in liters and km, respectively
    } on TokenInvalidoException catch (e) {
      print('Erro ao carregar grupos: $e');
      userUtils().invalidSessionDialog(context);
    }
  }

  Future<void> drawTransports() async {
    if (currentLocation != null) {
      var result = await googlePlace.search.getNearBySearch(
          g_place.Location(lat: currentLocation!.latitude, lng: currentLocation!.longitude),
          TRANSIT_DISTANCE, type: 'transit_station');
      if (result != null && result.results != null) {

        final ImageConfiguration imageConfig = createLocalImageConfiguration(context);
        BitmapDescriptor customIcon = await BitmapDescriptor.asset(
            imageConfig,
            'assets/transport_icon.png',
            width: 28,
            height: 20
        );

        setState(() {
          for (var place in result.results!) {
            LatLng newLatLng = LatLng(
                place.geometry!.location!.lat!, place.geometry!.location!.lng!);
            persistentMarkers.add(Marker(
              markerId: MarkerId(place.placeId!),
              position: newLatLng,
              infoWindow: InfoWindow(
                title: place.name,
                snippet: place.formattedAddress,
              ),
              onTap: () {
                setState(() {
                  destinationLocation = newLatLng;
                  showRouteButton = true;
                });
              },
              icon: customIcon,
            ));
          }
        });
      }
    }
  }

  /* // Used when showing the route for the user
  IconData getIconForTravelMode(String travelMode) {
    switch (travelMode) {
      case 'DRIVING':
        return Icons.directions_car;
      case 'WALKING':
        return Icons.directions_walk;
      case 'BICYCLING':
        return Icons.directions_bike;
      case 'TRANSIT':
        return Icons.directions_transit;
      default:
        return Icons.help;
    }
  }
  */

  void resetData(){
    setState(() {
      markers.clear();
      persistentMarkers.clear();
      polylines.clear();
      routeEmissions = 0;
      routeDistance = 0;
      totalDistance = 0;
      drivingDistance = 0;
      walkingDistance = 0;
      bicyclingDistance = 0;
      transitDistance = 0;
      totalDuration = 0;
      hasRoute = false;
      isSeccioned = false;
      lastDestination = null;
      totalStops = 0;
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation!, zoom: 15)));
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
    child: Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(82, 130, 103, 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 620,
      child: gotLocation
            ? Column(
          children: [
                DropdownButton<String>(
                  value: selectedTransportationMode,
                  dropdownColor:const Color.fromRGBO(82, 130, 103, 1.0),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTransportationMode = newValue!;
                    });
                  },
                  items: <String>[
                    'driving',
                    'transit',
                    'walking',
                    'bicycling'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'driving'
                            ? 'Driving'
                            : value == 'transit'
                            ? 'Public Transportation'
                            : value == 'walking'
                            ? 'Walking'
                            : 'Cycling',
                          style: GoogleFonts.getFont(
                          'Inter',
                          textStyle: const TextStyle(
                          color: Color.fromRGBO(248, 237, 227, 1),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    ),
                    );
                  }).toList(),
                ),
                Container(
                  height: 400,
                  child: GoogleMap(
                    onMapCreated: onMapCreated,
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    buildingsEnabled: true,
                    mapToolbarEnabled: false,
                    mapType: MapType.normal,
                    onTap: (LatLng latlng) {
                      markerFromTap(latlng);
                    },
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                      ),
                    },
                    initialCameraPosition: CameraPosition(
                      target: currentLocation ?? const LatLng(38.7223, -9.1393),
                      zoom: 13.0,
                    ),
                    markers: Set<Marker>.from({...markers, ...persistentMarkers}),
                    polylines: Set<Polyline>.of(polylines.values),
                  ),
                ),
                Center(
                  child: Row(
                    children: [
                      Card(
                        color: const Color.fromRGBO(248, 237, 227, 1),
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text('Distance: ${(totalDistance/1000).toStringAsFixed(2)} kms',
                                style: GoogleFonts.getFont(
                                  'Inter',
                                  textStyle: const TextStyle(
                                    color: Color.fromRGBO(
                                        123, 175, 146, 1.0),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(
                                      123, 175, 146, 1.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Adjust the radius as needed
                                  ),
                                ),
                                onPressed: () {
                                  if (routeChanged) {
                                    sendRouteInfo();
                                    routeChanged = false;
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: const Color.fromRGBO(
                                              248, 237, 227, 1),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Values submitted successfully!',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.getFont(
                                                  'Inter',
                                                  textStyle: const TextStyle(
                                                    color: Color.fromRGBO(
                                                        82, 130, 103, 1.0),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                              RichText(
                                                textAlign: TextAlign.center,
                                                text: TextSpan(
                                                  style: GoogleFonts.getFont(
                                                    'Inter',
                                                    textStyle: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          82, 130, 103, 1.0),
                                                      fontSize: 16,
                                                      // Smaller font size
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: 'Total time = ${formatSeconds(totalDuration.toInt())}\n',
                                                    ),
                                                    if (drivingDistance != 0)TextSpan(
                                                        text:
                                                        'Total fuel used driving = ${routeEmissions.toStringAsFixed(2)}L\n'
                                                            'Driving distance = ${(drivingDistance/1000).toStringAsFixed(2)}km\n'),
                                                    if (walkingDistance != 0) TextSpan(
                                                        text: 'Walking distance = ${(walkingDistance/1000).toStringAsFixed(2)}km\n'),
                                                    if (transitDistance != 0) TextSpan(
                                                        text: 'Transports distance = ${(transitDistance/1000).toStringAsFixed(2)}km\n'),
                                                    if (bicyclingDistance != 0) TextSpan(
                                                        text: 'Bicycling distance = ${(bicyclingDistance/1000).toStringAsFixed(2)}km\n'),
                                                    TextSpan(
                                                        text: 'Total distance = ${(totalDistance/1000).toStringAsFixed(2)}km\n'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('OK',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.getFont(
                                                  'Inter',
                                                  textStyle: const TextStyle(
                                                    color: Color.fromRGBO(
                                                        82, 130, 103, 1.0),
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {
                                                if (hasRoute && !isSeccioned) {
                                                  launchGoogleMapsNavigation(
                                                      destinationLocation!);
                                                }
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }else{
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: const Color.fromRGBO(
                                              248, 237, 227, 1),
                                          content:
                                          Text('Please pass new information with the "Create Route" button',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.getFont(
                                              'Inter',
                                              textStyle: const TextStyle(
                                                color: Color.fromRGBO(
                                                    82, 130, 103, 1.0),
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Text('Send new route',
                                  style: GoogleFonts.getFont(
                                    'Inter',
                                    textStyle: const TextStyle(
                                      color: Color.fromRGBO(
                                          248, 237, 227, 1),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          if (showRouteButton)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(123, 175, 146, 1.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Adjust the radius as needed
                                  ),
                                  minimumSize: const Size(150, 40), // Set the desired width and height
                                ),
                                onPressed: createRoute,
                                child:  Text('Create route',
                                  style: GoogleFonts.getFont(
                                    'Inter',
                                    textStyle: const TextStyle(
                                      color: Color.fromRGBO(248, 237, 227, 1),
                                    fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (lastDestination != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(
                                      123, 175, 146, 1.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Adjust the radius as needed
                                  ),
                                  minimumSize: const Size(150, 40), // Set the desired width and height
                                ),
                                onPressed: resetData,
                                child:  Text('Clean',
                                  style: GoogleFonts.getFont(
                                    'Inter',
                                    textStyle: const TextStyle(
                                      color: Color.fromRGBO(
                                          248, 237, 227, 1),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                )

          ],
        )
            : const Center(
          child: CircularProgressIndicator(
            semanticsLabel:
            "Centering map\n(if this does not resolve, please make sure you've enabled location services)",
          ),
        ),
      ),
    );
  }


  //helper function to transform seconds into hh:mm
  String formatSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);

    String formattedHours = hours.toString().padLeft(2, '0');
    String formattedMinutes = minutes.toString().padLeft(2, '0');

    return '$formattedHours:$formattedMinutes';
  }
}