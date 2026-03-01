import 'package:flutter/material.dart';
import '../models/film.dart';
import '../services/api_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'film_detail_screen.dart';

class FilmsScreen extends StatefulWidget {
  const FilmsScreen({super.key});

  @override
  State<FilmsScreen> createState() => _FilmsScreenState();
}

class _FilmsScreenState extends State<FilmsScreen> {
  final ApiService _api = ApiService();
  late Future<List<Film>> _filmsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filmsFuture = _api.getFilms();
  }

  void _refresh() {
    setState(() {
      _filmsFuture = _api.getFilms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.movie, color: Color(0xFFE50914), size: 28),
            SizedBox(width: 8),
            Text(
              'CinéApp',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_city, color: Colors.white),
            tooltip: 'Villes & Cinémas',
            onPressed: () {
              Navigator.pushNamed(context, '/villes');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un film...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Films à l\'affiche',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Film>>(
              future: _filmsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Chargement des films...');
                }
                if (snapshot.hasError) {
                  return AppErrorWidget(
                    message: snapshot.error.toString(),
                    onRetry: _refresh,
                  );
                }
                final films = snapshot.data ?? [];
                final filtered = _searchQuery.isEmpty
                    ? films
                    : films
                        .where((f) =>
                            f.titre.toLowerCase().contains(_searchQuery) ||
                            (f.categorie?.name.toLowerCase().contains(_searchQuery) ?? false))
                        .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun film trouvé',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _FilmCard(
                      film: filtered[index],
                      api: _api,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilmCard extends StatelessWidget {
  final Film film;
  final ApiService api;

  const _FilmCard({required this.film, required this.api});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FilmDetailScreen(film: film),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  api.getFilmImageUrl(film.id),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF2A2A2A),
                    child: const Center(
                      child: Icon(
                        Icons.movie,
                        color: Color(0xFFE50914),
                        size: 48,
                      ),
                    ),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: const Color(0xFF2A2A2A),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE50914),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    film.titre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: Colors.white38, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${film.duree}h',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      if (film.categorie != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            film.categorie!.name,
                            style: const TextStyle(
                              color: Color(0xFFE50914),
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
