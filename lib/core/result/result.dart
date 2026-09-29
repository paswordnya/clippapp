// Author: Rakka Purnama

import 'package:semarewards/core/error/failure.dart';

/// A minimal Either-like wrapper so use cases and repositories can return
/// success or failure without throwing across layer boundaries.
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    return switch (self) {
      Success<T>() => success(self.value),
      ResultFailure<T>() => failure(self.failure),
    };
  }

  /// Returns the success value, or null when this is a failure.
  T? get valueOrNull => switch (this) {
    Success<T>(value: final v) => v,
    ResultFailure<T>() => null,
  };

  /// Returns the failure, or null when this is a success.
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    ResultFailure<T>(failure: final f) => f,
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);
  final Failure failure;
}
