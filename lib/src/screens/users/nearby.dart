// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class NearbyMosquesScreens extends StatefulWidget {
//   const NearbyMosquesScreens({super.key});

//   @override
//   State<NearbyMosquesScreens> createState() => _NearbyMosquesScreenState();
// }

// class _NearbyMosquesScreenState extends State<NearbyMosquesScreens> {
//   GoogleMapController? _mapController;
//   LocationData? _currentLocation;
//   final Location location = Location();
//   LatLng? _currentPosition;
//   List<Marker> _markers = [];
//   List<dynamic> _autocompleteResults = [];
//   final String _apiKey = 'AIzaSyB41n7uZUSAdM1H6LeaiN6QBq1cmydR_4I'; // Replace with your API key

//   TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     PermissionStatus permissionGranted;

//     serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) return;
//     }

//     permissionGranted = await location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) return;
//     }

//     _currentLocation = await location.getLocation();
//     setState(() {
//       _currentPosition = LatLng(
//         _currentLocation!.latitude!,
//         _currentLocation!.longitude!,
//       );
//       _mapController?.moveCamera(
//         CameraUpdate.newLatLng(_currentPosition!),
//       );
//       _getNearbyMosques();
//     });
//   }

//   // Fetch nearby mosques using Google Places API
//   Future<void> _getNearbyMosques() async {
//     if (_currentPosition == null) return;

//     final String url =
//         'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
//         '?location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
//         '&radius=2000'
//         '&type=mosque'
//         '&key=$_apiKey';

//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final List mosques = data['results'];

//       setState(() {
//         _markers = mosques.map((mosque) {
//           return Marker(
//             markerId: MarkerId(mosque['place_id']),
//             position: LatLng(
//               mosque['geometry']['location']['lat'],
//               mosque['geometry']['location']['lng'],
//             ),
//             infoWindow: InfoWindow(
//               title: mosque['name'],
//               snippet: mosque['vicinity'],
//             ),
//           );
//         }).toList();
//       });
//     } else {
//       throw Exception('Failed to load mosques');
//     }
//   }

//   // Fetch autocomplete suggestions for mosque names
//   Future<void> _getAutocompleteSuggestions(String query) async {
//     if (_currentPosition == null || query.isEmpty) return;

//     final String url =
//         'https://maps.googleapis.com/maps/api/place/autocomplete/json'
//         '?input=$query'
//         '&location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
//         '&radius=2000'
//         '&types=establishment'
//         '&keyword=mosque'
//         '&key=$_apiKey';

//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         _autocompleteResults = data['predictions'];
//       });
//     } else {
//       throw Exception('Failed to fetch suggestions');
//     }
//   }

//   // Move camera to the selected mosque
//   Future<void> _moveToSelectedPlace(String placeId) async {
//     final String url =
//         'https://maps.googleapis.com/maps/api/place/details/json'
//         '?place_id=$placeId'
//         '&key=$_apiKey';

//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final location = data['result']['geometry']['location'];
//       final LatLng selectedPosition = LatLng(location['lat'], location['lng']);
//       setState(() {
//         _mapController?.moveCamera(CameraUpdate.newLatLng(selectedPosition));
//       });
//     } else {
//       throw Exception('Failed to load selected place');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Nearby Mosques'),
//         backgroundColor: Colors.green,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: const InputDecoration(
//                 hintText: 'Search for mosques...',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (query) {
//                 _getAutocompleteSuggestions(query);
//               },
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _autocompleteResults.length,
//               itemBuilder: (context, index) {
//                 final suggestion = _autocompleteResults[index];
//                 return ListTile(
//                   title: Text(suggestion['description']),
//                   onTap: () {
//                     _moveToSelectedPlace(suggestion['place_id']);
//                   },
//                 );
//               },
//             ),
//           ),
//           Expanded(
//             child: _currentPosition == null
//                 ? const Center(child: CircularProgressIndicator())
//                 : GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: _currentPosition!,
//                       zoom: 14.0,
//                     ),
//                     myLocationEnabled: true,
//                     myLocationButtonEnabled: true,
//                     onMapCreated: (GoogleMapController controller) {
//                       _mapController = controller;
//                     },
//                     markers: Set<Marker>.of(_markers),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
