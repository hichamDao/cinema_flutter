import 'ville.dart';

class Cinema {
  final int id;
  final String name;
  final double longitude;
  final double latitude;
  final double altitude;
  final int nombreSalles;
  final Ville? ville;

  Cinema({
    required this.id,
    required this.name,
    this.longitude = 0,
    this.latitude = 0,
    this.altitude = 0,
    this.nombreSalles = 0,
    this.ville,
  });

  factory Cinema.fromJson(Map<String, dynamic> json) {
    return Cinema(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      longitude: (json['longitude'] ?? json['Longitude'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      altitude: (json['altitude'] ?? 0).toDouble(),
      nombreSalles: json['nombreSalles'] ?? 0,
      ville: json['ville'] != null ? Ville.fromJson(json['ville']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'longitude': longitude,
        'latitude': latitude,
        'altitude': altitude,
        'nombreSalles': nombreSalles,
        'ville': ville?.toJson(),
      };
}
