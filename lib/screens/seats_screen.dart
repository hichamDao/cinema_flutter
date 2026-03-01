import 'package:flutter/material.dart';
import '../models/film.dart';
import '../models/projection.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'payment_screen.dart';

class SeatsScreen extends StatefulWidget {
  final Projection projection;
  final Film film;

  const SeatsScreen({
    super.key,
    required this.projection,
    required this.film,
  });

  @override
  State<SeatsScreen> createState() => _SeatsScreenState();
}

class _SeatsScreenState extends State<SeatsScreen> {
  final ApiService _api = ApiService();
  late Future<List<Ticket>> _ticketsFuture;
  final Set<int> _selectedTicketIds = {};

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _api.getTicketsByProjection(widget.projection.id);
  }

  double get _totalPrice =>
      _selectedTicketIds.length * widget.projection.prix;

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
              widget.film.titre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.projection.seance?.heureDebut ?? '',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Screen indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.transparent, Colors.white38, Colors.transparent],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ÉCRAN',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: const Color(0xFF2A2A2A), label: 'Disponible'),
                const SizedBox(width: 20),
                _LegendItem(color: const Color(0xFFE50914), label: 'Sélectionné'),
                const SizedBox(width: 20),
                _LegendItem(color: Colors.white24, label: 'Réservé'),
              ],
            ),
          ),

          // Seats grid
          Expanded(
            child: FutureBuilder<List<Ticket>>(
              future: _ticketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Chargement des places...');
                }
                if (snapshot.hasError) {
                  return AppErrorWidget(
                    message: snapshot.error.toString(),
                    onRetry: () {
                      setState(() {
                        _ticketsFuture = _api.getTicketsByProjection(
                            widget.projection.id);
                        _selectedTicketIds.clear();
                      });
                    },
                  );
                }
                final tickets = snapshot.data ?? [];
                if (tickets.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune place disponible',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                // Sort by place number
                tickets.sort((a, b) =>
                    (a.place?.numero ?? 0).compareTo(b.place?.numero ?? 0));

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    final isReserved = ticket.reserve;
                    final isSelected =
                        _selectedTicketIds.contains(ticket.id);

                    return GestureDetector(
                      onTap: isReserved
                          ? null
                          : () {
                              setState(() {
                                if (isSelected) {
                                  _selectedTicketIds.remove(ticket.id);
                                } else {
                                  _selectedTicketIds.add(ticket.id);
                                }
                              });
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isReserved
                              ? Colors.white12
                              : isSelected
                                  ? const Color(0xFFE50914)
                                  : const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE50914)
                                : Colors.white12,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${ticket.place?.numero ?? index + 1}',
                            style: TextStyle(
                              color: isReserved
                                  ? Colors.white24
                                  : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom bar
          if (_selectedTicketIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                border: Border(
                  top: BorderSide(color: Colors.white12),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_selectedTicketIds.length} place(s)',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${_totalPrice.toStringAsFixed(0)} MAD',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            ticketIds: _selectedTicketIds.toList(),
                            totalPrice: _totalPrice,
                            film: widget.film,
                            projection: widget.projection,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Continuer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.white24),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}
