// lib/src/models/mosque_model.dart
class Mosque {
  final String id;
  final String name;
  final String? urduName; // Optional for future Urdu support
  final String address;
  final double latitude;
  final double longitude;
  final String? placeId; // For Google Places API

  const Mosque({
    required this.id,
    required this.name,
    this.urduName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
  });

  factory Mosque.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    return Mosque(
      id: json['place_id'],
      name: json['name'],
      urduName: null, // Can be added later
      address: json['vicinity'] ?? 'No address available',
      latitude: geometry['lat'],
      longitude: geometry['lng'],
      placeId: json['place_id'],
    );
  }

  // Generate Google Maps URL for navigation
  String get googleMapsUrl =>
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';
}
