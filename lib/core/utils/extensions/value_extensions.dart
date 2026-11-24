const List<String> _englishDigits = <String>['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

const List<String> _arabicDigits = <String>['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

const String _dash = '-';

String _convertDigits({required String value, required List<String> sourceDigits, required List<String> targetDigits}) {
  var result = value;

  for (var index = 0; index < sourceDigits.length; index++) {
    result = result.replaceAll(sourceDigits[index], targetDigits[index]);
  }

  return result;
}

String? _trimmedOrNull(String? value) {
  final trimmedValue = value?.trim();

  if (trimmedValue == null || trimmedValue.isEmpty) {
    return null;
  }

  return trimmedValue;
}

String _normalizeComparableString(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
}

/// Converts Arabic numerals to English numerals.
extension ArabicNumberConverter on String {
  String get arabicNumberToEnglish {
    return _convertDigits(value: this, sourceDigits: _arabicDigits, targetDigits: _englishDigits);
  }
}

/// Converts English numerals to Arabic numerals.
extension EnglishNumberConverter on String {
  String get englishNumberToArabic {
    return _convertDigits(value: this, sourceDigits: _englishDigits, targetDigits: _arabicDigits);
  }
}

/// Provides fallback values for nullable strings.
extension NullableStringExtension on String? {
  /// Returns an empty string when the value is null.
  ///
  /// This intentionally does not trim the original value.
  String orEmpty() {
    return this ?? '';
  }

  /// Returns the trimmed value or the localized "not specified" text.
  String get orNotSpecified {
    return _trimmedOrNull(this) ?? 'Not Specified';
  }

  /// Returns the trimmed value or a dash.
  String get orDash {
    return _trimmedOrNull(this) ?? _dash;
  }
}

/// Provides utilities for collections of nullable strings.
extension NormalizedStringValues on Iterable<String?> {
  String resolveName({required String fallback}) {
    for (final value in this) {
      final normalizedValue = _trimmedOrNull(value);

      if (normalizedValue != null) {
        return normalizedValue;
      }
    }

    return fallback;
  }

  bool hasNormalizedValue(String expected) {
    final normalizedExpected = _normalizeComparableString(expected);

    return any((value) {
      if (value == null) {
        return false;
      }

      return _normalizeComparableString(value) == normalizedExpected;
    });
  }
}

/// Provides fallback values for nullable integers.
extension NullableInt on int? {
  int orZero() {
    return this ?? 0;
  }
}

/// Formats numeric values with a currency symbol and fixed decimal places.
extension CurrencyFormatting on num {
  String formatCurrency({required String currencySymbol, int decimalDigits = 2}) {
    return '$currencySymbol${toStringAsFixed(decimalDigits)}';
  }
}
