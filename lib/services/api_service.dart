import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/film.dart';
import '../models/ville.dart';
import '../models/cinema.dart';
import '../models/salle.dart';
import '../models/projection.dart';
import '../models/ticket.dart';

class ApiService {
  // Change this to your backend IP/hostname when running on a real device
  static const String baseUrl = 'http://10.0.2.2:8080';

  // ─── Films ───────────────────────────────────────────────────────────────

  Future<List<Film>> getFilms() async {
    final response = await http.get(Uri.parse('$baseUrl/films'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final embedded = data['_embedded'];
      if (embedded != null && embedded['films'] != null) {
        return (embedded['films'] as List)
            .map((e) => Film.fromJson(e))
            .toList();
      }
      return [];
    }
    throw Exception('Failed to load films: ${response.statusCode}');
  }

  Future<Film> getFilm(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/films/$id'));
    if (response.statusCode == 200) {
      return Film.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load film: ${response.statusCode}');
  }

  // ─── Villes ──────────────────────────────────────────────────────────────

  Future<List<Ville>> getVilles() async {
    final response = await http.get(Uri.parse('$baseUrl/villes'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final embedded = data['_embedded'];
      if (embedded != null && embedded['villes'] != null) {
        return (embedded['villes'] as List)
            .map((e) => Ville.fromJson(e))
            .toList();
      }
      return [];
    }
    throw Exception('Failed to load villes: ${response.statusCode}');
  }

  // ─── Cinemas ─────────────────────────────────────────────────────────────

  Future<List<Cinema>> getCinemas() async {
    final response = await http.get(Uri.parse('$baseUrl/cinemas'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final embedded = data['_embedded'];
      if (embedded != null && embedded['cinemas'] != null) {
        return (embedded['cinemas'] as List)
            .map((e) => Cinema.fromJson(e))
            .toList();
      }
      return [];
    }
    throw Exception('Failed to load cinemas: ${response.statusCode}');
  }

  Future<List<Cinema>> getCinemasByVille(int villeId) async {
    final allCinemas = await getCinemas();
    return allCinemas
        .where((c) => c.ville?.id == villeId)
        .toList();
  }

  // ─── Salles ──────────────────────────────────────────────────────────────

  Future<List<Salle>> getSalles() async {
    final response = await http.get(Uri.parse('$baseUrl/salles'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final embedded = data['_embedded'];
      if (embedded != null && embedded['salles'] != null) {
        return (embedded['salles'] as List)
            .map((e) => Salle.fromJson(e))
            .toList();
      }
      return [];
    }
    throw Exception('Failed to load salles: ${response.statusCode}');
  }

  Future<List<Salle>> getSallesByCinema(int cinemaId) async {
    final allSalles = await getSalles();
    return allSalles
        .where((s) => s.cinema?.id == cinemaId)
        .toList();
  }

  // ─── Projections ─────────────────────────────────────────────────────────

  Future<List<Projection>> getProjections() async {
    final response = await http.get(Uri.parse('$baseUrl/projections'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final embedded = data['_embedded'];
      if (embedded != null && embedded['projections'] != null) {
        return (embedded['projections'] as List)
            .map((e) => Projection.fromJson(e))
            .toList();
      }
      return [];
    }
    throw Exception('Failed to load projections: ${response.statusCode}');
  }

  Future<List<Projection>> getProjectionsByFilm(int filmId) async {
    final allProjections = await getProjections();
    return allProjections
        .where((p) => p.film?.id == filmId)
        .toList();
  }

  // ─── Tickets ─────────────────────────────────────────────────────────────

  Future<List<Ticket>> getTicketsByProjection(int projectionId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/tickets?projection=$projectionId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final embedded = data['_embedded'];
      if (embedded != null && embedded['tickets'] != null) {
        return (embedded['tickets'] as List)
            .map((e) => Ticket.fromJson(e))
            .toList();
      }
      return [];
    }
    // Fallback: get all tickets and filter
    return await _getTicketsByProjectionFallback(projectionId);
  }

  Future<List<Ticket>> _getTicketsByProjectionFallback(int projectionId) async {
    final response = await http.get(Uri.parse('$baseUrl/tickets'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final embedded = data['_embedded'];
      if (embedded != null && embedded['tickets'] != null) {
        final allTickets = (embedded['tickets'] as List)
            .map((e) => Ticket.fromJson(e))
            .toList();
        return allTickets
            .where((t) => t.projection?.id == projectionId)
            .toList();
      }
      return [];
    }
    throw Exception('Failed to load tickets: ${response.statusCode}');
  }

  // ─── Pay Tickets ─────────────────────────────────────────────────────────

  Future<List<Ticket>> payerTickets({
    required String nomClient,
    required int codePayement,
    required List<int> ticketIds,
  }) async {
    final body = json.encode({
      'NomClient': nomClient,
      'codePayement': codePayement,
      'tickets': ticketIds,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/payerTickets'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => Ticket.fromJson(e)).toList();
    }
    throw Exception('Failed to pay tickets: ${response.statusCode}');
  }

  // ─── Image URL ───────────────────────────────────────────────────────────

  String getFilmImageUrl(int filmId) {
    return '$baseUrl/imageFilm/$filmId';
  }
}
