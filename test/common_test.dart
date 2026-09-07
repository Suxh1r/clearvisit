import 'package:clearvisit/src/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('timeFromStorage', () {
    test('parses a valid 24-hour time', () {
      expect(timeFromStorage('09:45'), const TimeOfDay(hour: 9, minute: 45));
    });

    test('rejects malformed and out-of-range values', () {
      expect(timeFromStorage('not-a-time'), isNull);
      expect(timeFromStorage('9:45'), isNull);
      expect(timeFromStorage('24:00'), isNull);
      expect(timeFromStorage('10:60'), isNull);
      expect(timeFromStorage('-1:30'), isNull);
    });
  });
}
