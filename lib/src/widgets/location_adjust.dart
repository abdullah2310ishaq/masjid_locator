import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import 'package:geocoding/geocoding.dart'; // Import Geocoding for reverse geocoding

class LocationAdjustWidget extends StatefulWidget {
  @override
  _LocationAdjustWidgetState createState() => _LocationAdjustWidgetState();
}

class _LocationAdjustWidgetState extends State<LocationAdjustWidget> {
  GoogleMapController? _mapController;
  Marker? _currentMarker; // Marker for the current location
  LatLng? _currentLatLng; // Store the current LatLng
  String? _currentAddress; // Address based on marker position

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch user's current location on load
  }

  // Fetch the current location using Geolocator
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
      _addMarker(_currentLatLng!); // Add marker after getting location
      _moveCameraToPosition(_currentLatLng!); // Move camera to the current position
      _getAddressFromLatLng(_currentLatLng!); // Fetch the address for this position
    });
  }

  // Move the Google Maps camera to a specific position
  void _moveCameraToPosition(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  // Handle marker drag end to update the current position and address
  void _onMarkerDragEnd(LatLng newPosition) {
    setState(() {
      _currentLatLng = newPosition;
      _addMarker(newPosition); // Update the marker position
      _getAddressFromLatLng(newPosition); // Fetch address after drag
    });
  }

  // Add marker and ensure it is draggable
  void _addMarker(LatLng position) {
    _currentMarker = Marker(
      markerId: const MarkerId("currentLocation"),
      position: position,
      draggable: true, // Ensure the marker is draggable
      onDragEnd: _onMarkerDragEnd, // Handle marker drag
    );

    // Set the marker on the map
    setState(() {
      // Force UI update with new marker
    });
  }

  // Fetch address from latitude and longitude using Geocoding
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Address not available";
      });
    }
  }

  // Handle tapping on the map to move the marker to a new location
  void _onMapTapped(LatLng tappedPosition) {
    setState(() {
      _currentLatLng = tappedPosition; // Update current position
      _addMarker(tappedPosition); // Move marker to tapped position
      _getAddressFromLatLng(tappedPosition); // Fetch address for new location
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adjust Location"),
      ),
      body: Column(
        children: [
          _currentLatLng == null
              ? const CircularProgressIndicator() // Show a loading indicator while fetching location
              : Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLatLng!,
                      zoom: 15.0,
                    ),
                    markers: _currentMarker != null
                        ? {_currentMarker!} // Add marker to the map
                        : {},
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    onTap: _onMapTapped, // Handle tap on the map to move the marker
                  ),
                ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _currentAddress ?? "Fetching address...",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Return the selected location to the previous screen
              Navigator.pop(context, _currentLatLng);
            },
            child: const Text("Confirm Location"),
          ),
        ],
      ),
    );
  }
}
