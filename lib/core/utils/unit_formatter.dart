enum DistanceUnit {
  miles,
  kilometers,
}

class UnitFormatter {
  static const double milesToKmMultiplier = 1.609344;
  static const double kmToMilesMultiplier = 1.0 / 1.609344;

  /// Returns the short unit string: 'mi' or 'km'
  static String unitLabel(DistanceUnit unit) {
    switch (unit) {
      case DistanceUnit.kilometers:
        return 'km';
      case DistanceUnit.miles:
        return 'mi';
    }
  }

  /// Returns the capitalized full name: 'Miles' or 'Kilometers'
  static String unitFullLabel(DistanceUnit unit) {
    switch (unit) {
      case DistanceUnit.kilometers:
        return 'Kilometers';
      case DistanceUnit.miles:
        return 'Miles';
    }
  }

  /// Returns the rate suffix: '/mi' or '/km'
  static String unitPerLabel(DistanceUnit unit) {
    return '/${unitLabel(unit)}';
  }

  /// Converts canonical miles into display value for the given unit.
  static double toDisplayDistance(double miles, DistanceUnit unit) {
    if (unit == DistanceUnit.kilometers) {
      return miles * milesToKmMultiplier;
    }
    return miles;
  }

  /// Converts a user-inputted distance in the given unit into canonical miles.
  static double toCanonicalMiles(double displayDistance, DistanceUnit unit) {
    if (unit == DistanceUnit.kilometers) {
      return displayDistance * kmToMilesMultiplier;
    }
    return displayDistance;
  }

  /// Formats a distance in miles into a string in the user's unit.
  static String formatDistance(
    double miles,
    DistanceUnit unit, {
    int decimals = 1,
    bool includeUnit = true,
  }) {
    final display = toDisplayDistance(miles, unit);
    final formatted = display.toStringAsFixed(decimals);
    return includeUnit ? '$formatted ${unitLabel(unit)}' : formatted;
  }

  /// Formats a target lifespan distance in miles into a rounded string in the user's unit.
  static String formatTarget(
    double targetMiles,
    DistanceUnit unit, {
    bool includeUnit = true,
  }) {
    final display = toDisplayDistance(targetMiles, unit);
    final formatted = display.round().toString();
    return includeUnit ? '$formatted ${unitLabel(unit)}' : formatted;
  }

  /// Formats average pace given canonical distance in miles and duration in seconds.
  static String formatPace(double miles, double durationSeconds, DistanceUnit unit) {
    final displayDist = toDisplayDistance(miles, unit);
    if (displayDist <= 0 || durationSeconds <= 0) {
      return '--:-- ${unitPerLabel(unit)}';
    }

    final secondsPerUnit = durationSeconds / displayDist;
    final minutes = (secondsPerUnit / 60).floor();
    final remainingSeconds = (secondsPerUnit % 60).round();

    // Cap display for unreasonably slow paces (e.g. > 99 min)
    if (minutes >= 99) {
      return '99:59 ${unitPerLabel(unit)}';
    }

    final formattedMin = minutes.toString();
    final formattedSec = remainingSeconds.toString().padLeft(2, '0');
    return '$formattedMin:$formattedSec ${unitPerLabel(unit)}';
  }

  /// Calculates cost-per-distance formatted string.
  static String formatCostPerUnit(double? price, double currentMiles, DistanceUnit unit) {
    if (price == null) {
      return 'Unpriced';
    }

    final displayDist = toDisplayDistance(currentMiles, unit);
    if (displayDist <= 0) {
      return '\$${price.toStringAsFixed(2)} ${unitPerLabel(unit)}';
    }

    final cost = price / displayDist;
    return '\$${cost.toStringAsFixed(2)} ${unitPerLabel(unit)}';
  }

  /// Parses a string setting ('mi', 'km', etc.) into a DistanceUnit.
  static DistanceUnit parseUnit(String? value) {
    if (value == 'km' || value == 'kilometers') {
      return DistanceUnit.kilometers;
    }
    return DistanceUnit.miles;
  }

  /// Serializes a DistanceUnit into its settings key string ('mi' or 'km').
  static String serializeUnit(DistanceUnit unit) {
    switch (unit) {
      case DistanceUnit.kilometers:
        return 'km';
      case DistanceUnit.miles:
        return 'mi';
    }
  }
}
