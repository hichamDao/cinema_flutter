class Categorie {
  final int id;
  final String name;

  Categorie({required this.id, required this.name});

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
