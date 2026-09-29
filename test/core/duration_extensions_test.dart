// Author: Rakka Purnama

import 'package:flutter_test/flutter_test.dart';
import 'package:semarewards/core/extensions/duration_extensions.dart';

void main() {
  test('toClockString formats as m:ss', () {
    expect(const Duration(seconds: 5).toClockString(), '0:05');
    expect(const Duration(minutes: 1, seconds: 5).toClockString(), '1:05');
    expect(const Duration(minutes: 2, seconds: 30).toClockString(), '2:30');
  });

  test('toSecondsString formats with one decimal', () {
    expect(const Duration(milliseconds: 12300).toSecondsString(), '12.3s');
    expect(Duration.zero.toSecondsString(), '0.0s');
  });
}
