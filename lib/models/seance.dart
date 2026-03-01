class Seance {
  final int id;
  final String heureDebut;

  Seance({
    required this.id,
    required this.heureDebut,
  });

  factory Seance.fromJson(Map<String, dynamic> json) {
    return Seance(
      id: json['id'] ?? 0,
      heureDebut: json['heureDebut'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'heureDebut': heureDebut,
      };
}
