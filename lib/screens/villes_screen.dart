import 'package:flutter/material.dart';
import '../models/ville.dart';
import '../services/api_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'cinemas_screen.dart';

class VillesScreen extends StatefulWidget {
  const VillesScreen({super.key});

  @override
  State<VillesScreen> createState() => _VillesScreenState();
}

class _VillesScreenState extends State<VillesScreen> {
  final ApiService _api = ApiService();
  late Future<List<Ville>> _villesFuture;

  @override
  void initState() {
    super.initState();
    _villesFuture = _api.getVilles();
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
        title: const Text(
          'Choisir une ville',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Ville>>(
        future: _villesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Chargement des villes...');
          }
          if (snapshot.hasError) {
            return AppErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _villesFuture = _api.getVilles();
                });
              },
            );
          }
          final villes = snapshot.data ?? [];
          if (villes.isEmpty) {
            return const Center(
              child: Text(
                'Aucune ville disponible',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: villes.length,
            itemBuilder: (context, index) {
              final ville = villes[index];
              return _VilleCard(ville: ville);
            },
          );
        },
      ),
    );
  }
}

class _VilleCard extends StatelessWidget {
  final Ville ville;

  const _VilleCard({required this.ville});

  // Map city names to icons
  IconData _getCityIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('casablanca')) return Icons.location_city;
    if (lower.contains('marrakech')) return Icons.temple_buddhist;
    if (lower.contains('rabat')) return Icons.account_balance;
    if (lower.contains('tanger')) return Icons.anchor;
    return Icons.place;
  }

  Color _getCityColor(int index) {
    final colors = [
      const Color(0xFFE50914),
      const Color(0xFF0066CC),
      const Color(0xFF00AA44),
      const Color(0xFFFF8800),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCityColor(ville.id % 4);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CinemasScreen(ville: ville),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCityIcon(ville.name),
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ville.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Voir les cinémas',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
