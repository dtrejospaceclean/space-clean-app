/// A single application action. Use cases throw a `Failure` on error.
abstract interface class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// For use cases that take no input.
final class NoParams {
  const NoParams();
}
