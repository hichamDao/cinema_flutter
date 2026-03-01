class Ville {
  final int id;
  final String name;
  final double longitude;
  final double latitude;
  final double altitude;

  Ville({
    required this.id,
    required this.name,
    this.longitude = 0,
    this.latitude = 0,
    this.altitude = 0,
  });

  factory Ville.fromJson(Map<String, dynamic> json) {
    return Ville(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      longitude: (json['longitude'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      altitude: (json['altitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'longitude': longitude,
        'latitude': latitude,
        'altitude': altitude,
      };
}
