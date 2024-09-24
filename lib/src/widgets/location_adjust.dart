import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationAdjustWidget extends StatefulWidget {
  @override
  _LocationAdjustWidgetState createState() => _LocationAdjustWidgetState();
}

class _LocationAdjustWidgetState extends State<LocationAdjustWidget> {
  GoogleMapController? _mapController;
  Marker? _currentMarker;
  LatLng? _currentLatLng;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

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
      _addMarker(_currentLatLng!);
      _moveCameraToPosition(_currentLatLng!);
      _getAddressFromLatLng(_currentLatLng!);
    });
  }

  void _moveCameraToPosition(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  void _onMarkerDragEnd(LatLng newPosition) {
    setState(() {
      _currentLatLng = newPosition;
      _addMarker(newPosition);
      _getAddressFromLatLng(newPosition);
    });
  }

  void _addMarker(LatLng position) {
    _currentMarker = Marker(
      markerId: const MarkerId("currentLocation"),
      position: position,
      draggable: true,
      onDragEnd: _onMarkerDragEnd,
    );
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
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

  void _onMapTapped(LatLng tappedPosition) {
    setState(() {
      _currentLatLng = tappedPosition;
      _addMarker(tappedPosition);
      _getAddressFromLatLng(tappedPosition);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Your Location"),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _currentLatLng == null
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentLatLng!,
                          zoom: 15.0,
                        ),
                        markers:
                            _currentMarker != null ? {_currentMarker!} : {},
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        onTap: _onMapTapped,
                      ),
                      Positioned(
                        top: 20,
                        right: 10,
                        child: FloatingActionButton(
                          backgroundColor: Colors.teal,
                          child: const Icon(Icons.my_location),
                          onPressed: () =>
                              _moveCameraToPosition(_currentLatLng!),
                        ),
                      ),
                    ],
                  ),
                ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  _currentAddress ?? "Fetching address...",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, _currentLatLng);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text("Confirm Location"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.black, width: 2),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
