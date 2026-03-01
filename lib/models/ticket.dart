import 'place.dart';
import 'projection.dart';

class Ticket {
  final int id;
  final String nomClient;
  final double prix;
  final int codePayement;
  final bool reserve;
  final Place? place;
  final Projection? projection;

  Ticket({
    required this.id,
    this.nomClient = '',
    required this.prix,
    this.codePayement = 0,
    this.reserve = false,
    this.place,
    this.projection,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? json['Id'] ?? 0,
      nomClient: json['nomClient'] ?? '',
      prix: (json['prix'] ?? 0).toDouble(),
      codePayement: json['codePayement'] ?? 0,
      reserve: json['reserve'] ?? false,
      place: json['place'] != null ? Place.fromJson(json['place']) : null,
      projection: json['projection'] != null
          ? Projection.fromJson(json['projection'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nomClient': nomClient,
        'prix': prix,
        'codePayement': codePayement,
        'reserve': reserve,
        'place': place?.toJson(),
        'projection': projection?.toJson(),
      };

  Ticket copyWith({
    int? id,
    String? nomClient,
    double? prix,
    int? codePayement,
    bool? reserve,
    Place? place,
    Projection? projection,
  }) {
    return Ticket(
      id: id ?? this.id,
      nomClient: nomClient ?? this.nomClient,
      prix: prix ?? this.prix,
      codePayement: codePayement ?? this.codePayement,
      reserve: reserve ?? this.reserve,
      place: place ?? this.place,
      projection: projection ?? this.projection,
    );
  }
}
