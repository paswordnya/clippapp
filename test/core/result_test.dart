// Author: Rakka Purnama

import 'package:flutter_test/flutter_test.dart';
import 'package:semarewards/core/error/failure.dart';
import 'package:semarewards/core/result/result.dart';

void main() {
  test('success exposes its value and no failure', () {
    const result = Result<int>.success(42);
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull, 42);
    expect(result.failureOrNull, isNull);
  });

  test('failure exposes its failure and no value', () {
    const result = Result<int>.failure(UnknownFailure('boom'));
    expect(result.isFailure, isTrue);
    expect(result.valueOrNull, isNull);
    expect(result.failureOrNull?.message, 'boom');
  });

  test('when dispatches to the matching branch', () {
    const success = Result<int>.success(1);
    const failure = Result<int>.failure(UnknownFailure('x'));

    expect(success.when(success: (v) => v * 2, failure: (_) => -1), 2);
    expect(failure.when(success: (v) => v * 2, failure: (_) => -1), -1);
  });
}
