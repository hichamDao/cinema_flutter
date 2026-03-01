import 'categorie.dart';

class Film {
  final int id;
  final String titre;
  final String description;
  final String realisateurs;
  final DateTime? dateSortie;
  final double duree;
  final String photo;
  final Categorie? categorie;

  Film({
    required this.id,
    required this.titre,
    this.description = '',
    this.realisateurs = '',
    this.dateSortie,
    required this.duree,
    required this.photo,
    this.categorie,
  });

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      realisateurs: json['realisateurs'] ?? '',
      dateSortie: json['dateSortie'] != null
          ? DateTime.tryParse(json['dateSortie'].toString())
          : null,
      duree: (json['duree'] ?? 0).toDouble(),
      photo: json['photo'] ?? '',
      categorie: json['categorie'] != null
          ? Categorie.fromJson(json['categorie'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titre': titre,
        'description': description,
        'realisateurs': realisateurs,
        'dateSortie': dateSortie?.toIso8601String(),
        'duree': duree,
        'photo': photo,
        'categorie': categorie?.toJson(),
      };
}
