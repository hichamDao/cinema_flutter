import 'cinema.dart';

class Salle {
  final int id;
  final String name;
  final int nombrePlace;
  final Cinema? cinema;

  Salle({
    required this.id,
    required this.name,
    this.nombrePlace = 0,
    this.cinema,
  });

  factory Salle.fromJson(Map<String, dynamic> json) {
    return Salle(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nombrePlace: json['nombrePlace'] ?? 0,
      cinema: json['cinema'] != null ? Cinema.fromJson(json['cinema']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nombrePlace': nombrePlace,
        'cinema': cinema?.toJson(),
      };
}
