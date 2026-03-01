import 'package:flutter/material.dart';
import '../models/film.dart';
import '../models/projection.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final List<int> ticketIds;
  final double totalPrice;
  final Film film;
  final Projection projection;

  const PaymentScreen({
    super.key,
    required this.ticketIds,
    required this.totalPrice,
    required this.film,
    required this.projection,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _paymentSuccess = false;
  List<Ticket> _confirmedTickets = [];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final tickets = await _api.payerTickets(
        nomClient: _nameController.text.trim(),
        codePayement: int.parse(_codeController.text.trim()),
        ticketIds: widget.ticketIds,
      );
      setState(() {
        _isLoading = false;
        _paymentSuccess = true;
        _confirmedTickets = tickets;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: const Color(0xFFE50914),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_paymentSuccess) {
      return _SuccessScreen(
        tickets: _confirmedTickets,
        film: widget.film,
        projection: widget.projection,
        nomClient: _nameController.text,
      );
    }

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
          'Paiement',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Récapitulatif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    _SummaryRow(
                      label: 'Film',
                      value: widget.film.titre,
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Séance',
                      value: widget.projection.seance?.heureDebut ?? '-',
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Places',
                      value: '${widget.ticketIds.length} place(s)',
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Prix unitaire',
                      value: '${widget.projection.prix.toStringAsFixed(0)} MAD',
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.totalPrice.toStringAsFixed(0)} MAD',
                          style: const TextStyle(
                            color: Color(0xFFE50914),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Payment form
              const Text(
                'Informations de paiement',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Name field
              const Text(
                'Nom complet',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  hint: 'Votre nom complet',
                  icon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Payment code field
              const Text(
                'Code de paiement',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codeController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  hint: 'Code à 4-6 chiffres',
                  icon: Icons.lock_outline,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un code de paiement';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Le code doit être numérique';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Pay button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.red.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Payer ${widget.totalPrice.toStringAsFixed(0)} MAD',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE50914)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orange),
      ),
      errorStyle: const TextStyle(color: Colors.orange),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ─── Success Screen ───────────────────────────────────────────────────────────

class _SuccessScreen extends StatelessWidget {
  final List<Ticket> tickets;
  final Film film;
  final Projection projection;
  final String nomClient;

  const _SuccessScreen({
    required this.tickets,
    required this.film,
    required this.projection,
    required this.nomClient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Réservation confirmée !',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Merci, $nomClient',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Ticket details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.movie, color: Color(0xFFE50914)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            film.titre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    _TicketRow(
                      icon: Icons.access_time,
                      label: 'Séance',
                      value: projection.seance?.heureDebut ?? '-',
                    ),
                    const SizedBox(height: 8),
                    _TicketRow(
                      icon: Icons.event_seat,
                      label: 'Places',
                      value: tickets
                          .map((t) => 'N°${t.place?.numero ?? t.id}')
                          .join(', '),
                    ),
                    const SizedBox(height: 8),
                    _TicketRow(
                      icon: Icons.payments,
                      label: 'Total payé',
                      value:
                          '${(tickets.length * projection.prix).toStringAsFixed(0)} MAD',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Back to home button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Retour à l\'accueil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TicketRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 18),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white54)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
