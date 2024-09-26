import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NearbyMosquesMap extends StatefulWidget {
  @override
  _NearbyMosquesMapState createState() => _NearbyMosquesMapState();
}

class _NearbyMosquesMapState extends State<NearbyMosquesMap> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  List<Marker> _mosqueMarkers = [];
  final String _placesApiKey = 'AIzaSyB41n7uZUSAdM1H6LeaiN6QBq1cmydR_4I'; // Add your Places API key

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get current user location
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    _fetchNearbyMosques();
  }

  // Fetch nearby mosques using Google Places API
  Future<void> _fetchNearbyMosques() async {
    if (_currentLocation == null) return;

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentLocation!.latitude},${_currentLocation!.longitude}&radius=1500&type=mosque&key=$_placesApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        setState(() {
          _mosqueMarkers = data['results'].map<Marker>((result) {
            return Marker(
              markerId: MarkerId(result['place_id']),
              position: LatLng(
                result['geometry']['location']['lat'],
                result['geometry']['location']['lng'],
              ),
              infoWindow: InfoWindow(
                title: result['name'],
                snippet: result['vicinity'],
              ),
            );
          }).toList();
        });
      }
    } else {
      print('Error fetching mosques: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Mosques'),
      ),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 14.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: Set<Marker>.of(_mosqueMarkers),
            ),
    );
  }
}
