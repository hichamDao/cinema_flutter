import 'film.dart';
import 'seance.dart';

class Projection {
  final int id;
  final DateTime? dateProjection;
  final double prix;
  final Film? film;
  final Seance? seance;

  Projection({
    required this.id,
    this.dateProjection,
    required this.prix,
    this.film,
    this.seance,
  });

  factory Projection.fromJson(Map<String, dynamic> json) {
    return Projection(
      id: json['id'] ?? 0,
      dateProjection: json['dateProjection'] != null
          ? DateTime.tryParse(json['dateProjection'].toString())
          : null,
      prix: (json['prix'] ?? 0).toDouble(),
      film: json['film'] != null ? Film.fromJson(json['film']) : null,
      seance: json['seance'] != null ? Seance.fromJson(json['seance']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateProjection': dateProjection?.toIso8601String(),
        'prix': prix,
        'film': film?.toJson(),
        'seance': seance?.toJson(),
      };
}
