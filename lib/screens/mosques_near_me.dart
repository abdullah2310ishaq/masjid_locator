// lib/screens/mosques_near_me_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:masjid_locator/models/mosque_model.dart';
import 'package:masjid_locator/services/location_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MosquesNearMePage extends StatefulWidget {
  const MosquesNearMePage({super.key});

  @override
  State<MosquesNearMePage> createState() => _MosquesNearMePageState();
}

class _MosquesNearMePageState extends State<MosquesNearMePage> {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Mosque> _mosques = [];
  Mosque? _selectedMosque;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _mosques = [];
      _markers = {};
      _selectedMosque = null;
    });
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
        final mosques =
            await _fetchNearbyMosques(position.latitude, position.longitude);
        setState(() {
          _mosques = mosques;
          _markers = _createMarkers(mosques);
          // Add user location marker
          _markers.add(
            Marker(
              markerId: const MarkerId('user_location'),
              position: LatLng(position.latitude, position.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
              infoWindow: const InfoWindow(title: 'Your Location'),
            ),
          );
          _isLoading = false;
          _errorMessage = mosques.isEmpty ? 'No mosques found nearby.' : null;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            13,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not get your location.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
      print('Error initializing map: $e');
    }
  }

  Future<List<Mosque>> _fetchNearbyMosques(double lat, double lng) async {
    final shift = 0.05; // ~5km
    final url =
        'https://overpass-api.de/api/interpreter?data=[out:json];node[amenity=place_of_worship][religion=muslim](${lat - shift},${lng - shift},${lat + shift},${lng + shift});out;';
    final response = await http.get(Uri.parse(url));
    print('Overpass API response: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final elements = data['elements'] as List<dynamic>;
      // Remove duplicates by id
      final seen = <String>{};
      final mosques = elements
          .map((e) => Mosque(
                id: e['id'].toString(),
                name: e['tags']?['name'] ?? 'Unknown Mosque',
                urduName: null,
                address: e['tags']?['addr:full'] ??
                    e['tags']?['addr:street'] ??
                    'No address available',
                latitude: e['lat'],
                longitude: e['lon'],
                placeId: null,
              ))
          .where((m) => seen.add(m.id))
          .toList();
      return mosques;
    } else {
      throw Exception('Failed to fetch mosques');
    }
  }

  Set<Marker> _createMarkers(List<Mosque> mosques) {
    return mosques.map((mosque) {
      return Marker(
        markerId: MarkerId(mosque.id),
        position: LatLng(mosque.latitude, mosque.longitude),
        infoWindow: InfoWindow(
          title: mosque.name,
          snippet: mosque.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () {
          setState(() {
            _selectedMosque = mosque;
          });
        },
      );
    }).toSet();
  }

  double _calculateDistance(Mosque mosque) {
    if (_currentPosition == null) return 0.0;
    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          mosque.latitude,
          mosque.longitude,
        ) /
        1000; // Convert to kilometers
  }

  void _onMosqueListTap(Mosque mosque) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(mosque.latitude, mosque.longitude),
        16,
      ),
    );
    setState(() {
      _selectedMosque = mosque;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mosques Near Me',
            style: GoogleFonts.almarai(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeMap,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.almarai(
                        fontSize: 18, color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                _currentPosition?.latitude ?? 33.6844,
                                _currentPosition?.longitude ?? 73.0479,
                              ),
                              zoom: 13,
                            ),
                            markers: _markers,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            onMapCreated: (controller) {
                              _mapController = controller;
                            },
                          ),
                          if (_selectedMosque != null)
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Card(
                                elevation: 12,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white.withOpacity(0.95),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedMosque!.name,
                                        style: GoogleFonts.almarai(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1B5E20),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _selectedMosque!.address,
                                        style: GoogleFonts.almarai(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Distance: ${_calculateDistance(_selectedMosque!).toStringAsFixed(2)} km',
                                        style: GoogleFonts.almarai(
                                          fontSize: 16,
                                          color: const Color(0xFFD4A017),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => _launchGoogleMaps(
                                                _selectedMosque!),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFD4A017),
                                              foregroundColor:
                                                  const Color(0xFF1B5E20),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              'View in Google Maps',
                                              style: GoogleFonts.almarai(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => _navigateToMosque(
                                                _selectedMosque!),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF1B5E20),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              'Navigate',
                                              style: GoogleFonts.almarai(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _mosques.isEmpty
                          ? Center(
                              child: Text(
                                'No mosques found nearby.',
                                style: GoogleFonts.almarai(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _mosques.length,
                              itemBuilder: (context, index) {
                                final mosque = _mosques[index];
                                return ListTile(
                                  leading: const Icon(Icons.location_on,
                                      color: Color(0xFFD4A017)),
                                  title: Text(
                                    mosque.name,
                                    style: GoogleFonts.almarai(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    mosque.address,
                                    style: GoogleFonts.almarai(fontSize: 13),
                                  ),
                                  trailing: Text(
                                    '${_calculateDistance(mosque).toStringAsFixed(2)} km',
                                    style: GoogleFonts.almarai(
                                        fontSize: 13, color: Colors.green[900]),
                                  ),
                                  onTap: () => _onMosqueListTap(mosque),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Future<void> _launchGoogleMaps(Mosque mosque) async {
    final url = mosque.googleMapsUrl;
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  Future<void> _navigateToMosque(Mosque mosque) async {
    final url = mosque.googleMapsUrl;
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }
}
