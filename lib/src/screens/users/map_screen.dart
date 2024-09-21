import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http; 

class NearbyMosquesScreen extends StatefulWidget {
  const NearbyMosquesScreen({super.key});

  @override
  State<NearbyMosquesScreen> createState() => _NearbyMosquesScreenState();
}

class _NearbyMosquesScreenState extends State<NearbyMosquesScreen> {
  GoogleMapController? _mapController;
  LocationData? _currentLocation;
  final Location location = Location();
  LatLng? _currentPosition;
  final String _placesApiKey = "AIzaSyDoO04B1OC_SxJfDMdwFgStxipPloCLGU8"; // Replace with your Google Places API key
  List<Marker> _mosqueMarkers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    // Check for location permissions
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Get the current location
    _currentLocation = await location.getLocation();

    setState(() {
      _currentPosition = LatLng(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      );
      _mapController?.moveCamera(
        CameraUpdate.newLatLng(_currentPosition!),
      );

      // After getting the location, fetch nearby mosques
      _fetchNearbyMosques();
    });
  }

  Future<void> _fetchNearbyMosques() async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=1500&type=mosque&key=$_placesApiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _mosqueMarkers = (data['results'] as List).map((place) {
            final location = place['geometry']['location'];
            return Marker(
              markerId: MarkerId(place['place_id']),
              position: LatLng(location['lat'], location['lng']),
              infoWindow: InfoWindow(
                title: place['name'],
                snippet: place['vicinity'],
              ),
            );
          }).toList();
        });
      } else {
        print("Failed to fetch nearby mosques: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching mosques: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Mosques'),
        backgroundColor: Colors.green,
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: Set<Marker>.of(_mosqueMarkers),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
    );
  }
}
