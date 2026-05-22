DateTime? parseTimestamp(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
  if (raw is Map && raw['seconds'] != null) {
    return DateTime.fromMillisecondsSinceEpoch((raw['seconds'] as int) * 1000);
  }
  return null;
}
