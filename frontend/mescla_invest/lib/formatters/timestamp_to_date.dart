/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

DateTime? parseTimestamp(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
  if (raw is Map) {
    // Firestore pode serializar o Timestamp com ou sem underscore nas chaves
    final seconds = (raw['seconds'] ?? raw['_seconds']) as int?;
    final nanoseconds = (raw['nanoseconds'] ?? raw['_nanoseconds'] ?? 0) as int;
    if (seconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanoseconds ~/ 1000000,
      );
    }
  }
  return null;
}
