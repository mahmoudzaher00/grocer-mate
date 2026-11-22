class ParseUtils {
  static int ensureInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;

    if (value is String) return int.tryParse(value) ?? defaultValue;

    if (value is double) return value.toInt();

    return defaultValue;
  }

  static double ensureDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;

    return defaultValue;
  }

  static bool ensureBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;

    if (value is int) return value != 0;

    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }

    return defaultValue;
  }

  static List<String> ensureStringList(
    dynamic value, {
    List<String> defaultValue = const <String>[],
  }) {
    if (value is! List) return defaultValue;

    return value
        .map((element) => element?.toString().trim() ?? '')
        .where((element) => element.isNotEmpty)
        .toList(growable: false);
  }

  static DateTime ensureDateTime(dynamic value, {DateTime? defaultValue}) {
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return defaultValue ?? DateTime.now();
      }
    }

    return defaultValue ?? DateTime.now();
  }

  static String ensureFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';

    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';

    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }
}
