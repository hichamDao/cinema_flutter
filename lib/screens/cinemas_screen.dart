import 'package:flutter/material.dart';
import '../models/ville.dart';
import '../models/cinema.dart';
import '../models/salle.dart';
import '../services/api_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class CinemasScreen extends StatefulWidget {
  final Ville ville;

  const CinemasScreen({super.key, required this.ville});

  @override
  State<CinemasScreen> createState() => _CinemasScreenState();
}

class _CinemasScreenState extends State<CinemasScreen> {
  final ApiService _api = ApiService();
  late Future<List<Cinema>> _cinemasFuture;

  @override
  void initState() {
    super.initState();
    _cinemasFuture = _api.getCinemasByVille(widget.ville.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.ville.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Text(
              'Cinémas disponibles',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Cinema>>(
        future: _cinemasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Chargement des cinémas...');
          }
          if (snapshot.hasError) {
            return AppErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _cinemasFuture = _api.getCinemasByVille(widget.ville.id);
                });
              },
            );
          }
          final cinemas = snapshot.data ?? [];
          if (cinemas.isEmpty) {
            return const Center(
              child: Text(
                'Aucun cinéma dans cette ville',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cinemas.length,
            itemBuilder: (context, index) {
              return _CinemaCard(cinema: cinemas[index]);
            },
          );
        },
      ),
    );
  }
}

class _CinemaCard extends StatefulWidget {
  final Cinema cinema;

  const _CinemaCard({required this.cinema});

  @override
  State<_CinemaCard> createState() => _CinemaCardState();
}

class _CinemaCardState extends State<_CinemaCard> {
  final ApiService _api = ApiService();
  bool _expanded = false;
  List<Salle>? _salles;
  bool _loadingSalles = false;

  Future<void> _loadSalles() async {
    if (_salles != null) return;
    setState(() => _loadingSalles = true);
    try {
      final salles = await _api.getSallesByCinema(widget.cinema.id);
      setState(() {
        _salles = salles;
        _loadingSalles = false;
      });
    } catch (e) {
      setState(() => _loadingSalles = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          // Cinema header
          InkWell(
            onTap: () {
              setState(() => _expanded = !_expanded);
              if (!_expanded) _loadSalles();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.theaters,
                      color: Color(0xFFE50914),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.cinema.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.meeting_room,
                                color: Colors.white38, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.cinema.nombreSalles} salle(s)',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white38,
                  ),
                ],
              ),
            ),
          ),

          // Salles list (expanded)
          if (_expanded) ...[
            const Divider(color: Colors.white12, height: 1),
            if (_loadingSalles)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFE50914),
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (_salles != null && _salles!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Salles',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _salles!.map((salle) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.event_seat,
                                  color: Color(0xFFE50914), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                salle.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(${salle.nombrePlace} places)',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Aucune salle disponible',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
