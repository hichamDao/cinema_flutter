import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/film.dart';
import '../models/projection.dart';
import '../services/api_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'seats_screen.dart';

class FilmDetailScreen extends StatefulWidget {
  final Film film;

  const FilmDetailScreen({super.key, required this.film});

  @override
  State<FilmDetailScreen> createState() => _FilmDetailScreenState();
}

class _FilmDetailScreenState extends State<FilmDetailScreen> {
  final ApiService _api = ApiService();
  late Future<List<Projection>> _projectionsFuture;

  @override
  void initState() {
    super.initState();
    _projectionsFuture = _api.getProjectionsByFilm(widget.film.id);
  }

  @override
  Widget build(BuildContext context) {
    final film = widget.film;

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: CustomScrollView(
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF141414),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _api.getFilmImageUrl(film.id),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF2A2A2A),
                      child: const Center(
                        child: Icon(
                          Icons.movie,
                          color: Color(0xFFE50914),
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xFF141414),
                        ],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Film info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    film.titre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Meta info row
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.access_time,
                        label: '${film.duree}h',
                      ),
                      if (film.categorie != null)
                        _InfoChip(
                          icon: Icons.category,
                          label: film.categorie!.name,
                          color: const Color(0xFFE50914),
                        ),
                      if (film.dateSortie != null)
                        _InfoChip(
                          icon: Icons.calendar_today,
                          label: DateFormat('dd/MM/yyyy')
                              .format(film.dateSortie!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Realisateurs
                  if (film.realisateurs.isNotEmpty) ...[
                    const Text(
                      'Réalisateur(s)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      film.realisateurs,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  if (film.description.isNotEmpty) ...[
                    const Text(
                      'Synopsis',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      film.description,
                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Projections section
                  const Text(
                    'Séances disponibles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Projections list
          SliverFillRemaining(
            child: FutureBuilder<List<Projection>>(
              future: _projectionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(
                      message: 'Chargement des séances...');
                }
                if (snapshot.hasError) {
                  return AppErrorWidget(
                    message: snapshot.error.toString(),
                    onRetry: () {
                      setState(() {
                        _projectionsFuture =
                            _api.getProjectionsByFilm(widget.film.id);
                      });
                    },
                  );
                }
                final projections = snapshot.data ?? [];
                if (projections.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune séance disponible',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: projections.length,
                  itemBuilder: (context, index) {
                    return _ProjectionCard(
                      projection: projections[index],
                      film: film,
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Colors.white38;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: chipColor, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: chipColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ProjectionCard extends StatelessWidget {
  final Projection projection;
  final Film film;

  const _ProjectionCard({required this.projection, required this.film});

  @override
  Widget build(BuildContext context) {
    final dateStr = projection.dateProjection != null
        ? DateFormat('EEE dd MMM', 'fr_FR')
            .format(projection.dateProjection!)
        : 'Date inconnue';
    final heureStr = projection.seance?.heureDebut ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE50914).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.play_circle_outline,
            color: Color(0xFFE50914),
          ),
        ),
        title: Text(
          dateStr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (heureStr.isNotEmpty)
              Text(
                '🕐 $heureStr',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            Text(
              '💰 ${projection.prix.toStringAsFixed(0)} MAD',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SeatsScreen(
                  projection: projection,
                  film: film,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE50914),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Réserver', style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
