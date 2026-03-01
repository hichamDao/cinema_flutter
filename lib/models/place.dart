class Place {
  final int id;
  final int numero;
  final double longitude;
  final double latitude;
  final double altitude;

  Place({
    required this.id,
    required this.numero,
    this.longitude = 0,
    this.latitude = 0,
    this.altitude = 0,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] ?? 0,
      numero: json['numero'] ?? 0,
      longitude: (json['longitude'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      altitude: (json['altitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': numero,
        'longitude': longitude,
        'latitude': latitude,
        'altitude': altitude,
      };
}
