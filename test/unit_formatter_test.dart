import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/core/utils/unit_formatter.dart';

void main() {
  group('UnitFormatter', () {
    test('unitLabel returns short labels', () {
      expect(UnitFormatter.unitLabel(DistanceUnit.miles), 'mi');
      expect(UnitFormatter.unitLabel(DistanceUnit.kilometers), 'km');
    });

    test('unitFullLabel returns full titles', () {
      expect(UnitFormatter.unitFullLabel(DistanceUnit.miles), 'Miles');
      expect(UnitFormatter.unitFullLabel(DistanceUnit.kilometers), 'Kilometers');
    });

    test('unitPerLabel returns rate suffixes', () {
      expect(UnitFormatter.unitPerLabel(DistanceUnit.miles), '/mi');
      expect(UnitFormatter.unitPerLabel(DistanceUnit.kilometers), '/km');
    });

    test('toDisplayDistance converts miles to km and preserves miles', () {
      expect(UnitFormatter.toDisplayDistance(10.0, DistanceUnit.miles), 10.0);
      expect(
        UnitFormatter.toDisplayDistance(10.0, DistanceUnit.kilometers),
        closeTo(16.09344, 0.0001),
      );
    });

    test('toCanonicalMiles converts km input back to canonical miles', () {
      expect(UnitFormatter.toCanonicalMiles(10.0, DistanceUnit.miles), 10.0);
      final kmInput = 16.09344;
      expect(
        UnitFormatter.toCanonicalMiles(kmInput, DistanceUnit.kilometers),
        closeTo(10.0, 0.0001),
      );
    });

    test('formatDistance formats correctly with decimals and unit', () {
      expect(
        UnitFormatter.formatDistance(5.0, DistanceUnit.miles, decimals: 2),
        '5.00 mi',
      );
      expect(
        UnitFormatter.formatDistance(5.0, DistanceUnit.kilometers, decimals: 2),
        '8.05 km',
      );
      expect(
        UnitFormatter.formatDistance(12.34, DistanceUnit.miles, decimals: 1, includeUnit: false),
        '12.3',
      );
    });

    test('formatTarget rounds target correctly', () {
      expect(UnitFormatter.formatTarget(400.0, DistanceUnit.miles), '400 mi');
      // 400 * 1.609344 = 643.7376 -> rounds to 644
      expect(UnitFormatter.formatTarget(400.0, DistanceUnit.kilometers), '644 km');
    });

    test('formatPace calculates pace string in mi and km', () {
      // 5 miles in 2400 seconds (40 mins) -> 8:00 /mi
      expect(
        UnitFormatter.formatPace(5.0, 2400.0, DistanceUnit.miles),
        '8:00 /mi',
      );
      // In km: 5 miles = 8.04672 km. 2400 / 8.04672 = 298.258 sec/km = 4 min 58 sec
      expect(
        UnitFormatter.formatPace(5.0, 2400.0, DistanceUnit.kilometers),
        '4:58 /km',
      );
      // Zero distance or seconds
      expect(
        UnitFormatter.formatPace(0.0, 100.0, DistanceUnit.miles),
        '--:-- /mi',
      );
    });

    test('formatCostPerUnit formats correctly', () {
      expect(
        UnitFormatter.formatCostPerUnit(null, 100.0, DistanceUnit.miles),
        'Unpriced',
      );
      expect(
        UnitFormatter.formatCostPerUnit(150.0, 0.0, DistanceUnit.miles),
        r'$150.00 /mi',
      );
      // $160 for 100 miles = $1.60 /mi
      expect(
        UnitFormatter.formatCostPerUnit(160.0, 100.0, DistanceUnit.miles),
        r'$1.60 /mi',
      );
      // $160 for 100 miles (160.9344 km) = $0.99 /km
      expect(
        UnitFormatter.formatCostPerUnit(160.0, 100.0, DistanceUnit.kilometers),
        r'$0.99 /km',
      );
    });

    test('parseUnit and serializeUnit roundtrip', () {
      expect(UnitFormatter.parseUnit('mi'), DistanceUnit.miles);
      expect(UnitFormatter.parseUnit('km'), DistanceUnit.kilometers);
      expect(UnitFormatter.parseUnit('kilometers'), DistanceUnit.kilometers);
      expect(UnitFormatter.parseUnit(null), DistanceUnit.miles);
      expect(UnitFormatter.parseUnit('invalid'), DistanceUnit.miles);

      expect(UnitFormatter.serializeUnit(DistanceUnit.miles), 'mi');
      expect(UnitFormatter.serializeUnit(DistanceUnit.kilometers), 'km');
    });
  });
}
