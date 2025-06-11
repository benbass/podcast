import 'package:equatable/equatable.dart';

// Abstrakte Basisklasse für alle Fehler/Failures in der Anwendung
abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace; // Optional: für detaillierteres Debugging

  const Failure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];

  @override
  String toString() => '$runtimeType: $message${stackTrace == null ? '' : '\n$stackTrace'}';
}

// --- Generische Fehler ---

// Fehler bei Server-Interaktionen (z.B. API-Aufrufe)
class ServerFailure extends Failure {
  final int? statusCode; // HTTP-Statuscode, falls anwendbar

  const ServerFailure({
    required String message,
    this.statusCode,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);

  @override
  List<Object?> get props => [message, statusCode, stackTrace];
}

// Fehler beim Zugriff auf den lokalen Cache (Datenbank, SharedPreferences etc.)
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

// Fehler bei der Netzwerkverbindung
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = "Keine Netzwerkverbindung. Bitte überprüfe deine Internetverbindung.",
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

// Unerwarteter Fehler, der nicht in eine spezifischere Kategorie passt
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    String message = "Ein unerwarteter Fehler ist aufgetreten.",
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}


// --- Anwendungsspezifische Fehler (Beispiele für eine Podcast-App) ---

// Fehler beim Parsen von Podcast-Feed-Daten
class FeedParsingFailure extends Failure {
  const FeedParsingFailure({
    String message = "Der Podcast-Feed konnte nicht korrekt verarbeitet werden.",
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

// Podcast oder Episode nicht gefunden
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required String message, // z.B. "Podcast nicht gefunden" oder "Episode nicht gefunden"
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

// Fehler bei der Authentifizierung oder Autorisierung
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required String message,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

// Fehler im Zusammenhang mit Downloads
class DownloadFailure extends Failure {
  const DownloadFailure({
    required String message,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

// Fehler bei der Wiedergabe
class PlaybackFailure extends Failure {
  const PlaybackFailure({
    required String message,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

// Du kannst hier weitere spezifische Fehler für deine Anwendung hinzufügen,
// z.B. InvalidInputFailure, DatabaseIntegrityFailure etc.