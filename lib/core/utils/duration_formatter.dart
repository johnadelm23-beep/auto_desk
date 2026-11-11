class DurationFormatter {
  DurationFormatter._();

  /// Formats the difference between two timestamps into a human-readable duration.
  /// E.g. "2d 5h", "4h 30m", or "45m".
  static String format(DateTime start, DateTime end) {
    if (end.isBefore(start)) {
      return '0m';
    }

    final diff = end.difference(start);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    if (days > 0) {
      if (hours > 0) {
        return '${days}d ${hours}h';
      }
      return '${days}d';
    }

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    }

    return '${minutes > 0 ? minutes : 1}m';
  }
}

