# CinéApp - Flutter Mobile App

Application mobile Flutter pour la réservation de billets de cinéma, connectée au backend Spring Boot Cinema.

## 📱 Fonctionnalités

- **Liste des films** : Affichage en grille avec poster, titre, durée et catégorie
- **Recherche** : Filtrage des films par titre ou catégorie
- **Détail film** : Informations complètes + liste des séances disponibles
- **Sélection des places** : Grille interactive des sièges (disponibles/réservés/sélectionnés)
- **Paiement** : Formulaire de paiement avec confirmation
- **Villes & Cinémas** : Navigation par ville → cinéma → salles

## 🏗️ Architecture

```
lib/
├── main.dart                    # Point d'entrée + routing
├── models/                      # Modèles de données
│   ├── film.dart
│   ├── ville.dart
│   ├── cinema.dart
│   ├── salle.dart
│   ├── seance.dart
│   ├── projection.dart
│   ├── place.dart
│   ├── ticket.dart
│   └── categorie.dart
├── services/
│   └── api_service.dart         # Client HTTP vers le backend
├── screens/                     # Écrans de l'application
│   ├── films_screen.dart        # Accueil - liste des films
│   ├── film_detail_screen.dart  # Détail d'un film + séances
│   ├── seats_screen.dart        # Sélection des places
│   ├── payment_screen.dart      # Paiement + confirmation
│   ├── villes_screen.dart       # Liste des villes
│   └── cinemas_screen.dart      # Cinémas par ville
└── widgets/                     # Widgets réutilisables
    ├── loading_widget.dart
    └── error_widget.dart
```

## 🔌 Configuration Backend

Le backend Spring Boot doit tourner sur le port **8080**.

Dans [`lib/services/api_service.dart`](lib/services/api_service.dart), modifiez `baseUrl` selon votre environnement :

| Environnement | URL |
|---|---|
| Émulateur Android | `http://10.0.2.2:8080` |
| Appareil physique | `http://<IP_DE_VOTRE_PC>:8080` |
| iOS Simulator | `http://localhost:8080` |

## 🚀 Installation & Lancement

### Prérequis
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / Xcode (pour les émulateurs)
- Backend Spring Boot en cours d'exécution

### Étapes

```bash
# 1. Aller dans le dossier du projet Flutter
cd cinema_flutter

# 2. Installer les dépendances
flutter pub get

# 3. Lancer l'application
flutter run
```

## 📡 API Endpoints utilisés

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/films` | Liste tous les films |
| GET | `/films/{id}` | Détail d'un film |
| GET | `/villes` | Liste toutes les villes |
| GET | `/cinemas` | Liste tous les cinémas |
| GET | `/salles` | Liste toutes les salles |
| GET | `/projections` | Liste toutes les projections |
| GET | `/tickets` | Liste tous les tickets |
| GET | `/imageFilm/{id}` | Image d'un film |
| POST | `/payerTickets` | Réserver et payer des tickets |

## 🎨 Design

- Thème sombre inspiré de Netflix
- Couleur principale : Rouge `#E50914`
- Fond : Noir `#141414`
- Cartes : Gris foncé `#1E1E1E`

## 📦 Dépendances

```yaml
http: ^1.1.0          # Requêtes HTTP
provider: ^6.1.1      # Gestion d'état
intl: ^0.18.1         # Formatage des dates
shimmer: ^3.0.0       # Effets de chargement
```
