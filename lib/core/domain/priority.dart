/// How urgent something is: a complaint, a task. New ones default to
/// [medium]. Pure Dart, so any feature's domain can use it.
enum Priority {
  high('high'),
  medium('medium'),
  low('low'),

  /// A priority this app doesn't know yet.
  unknown('');

  const Priority(this.wire);

  /// The API's name for it.
  final String wire;

  /// The ones a person can pick.
  static const choices = [high, medium, low];

  static Priority fromWire(String? value) => values.firstWhere(
    (p) => p != unknown && p.wire == value,
    orElse: () => unknown,
  );

  /// For sorting, most urgent first.
  int get rank => switch (this) {
    high => 0,
    medium => 1,
    low => 2,
    unknown => 3,
  };
}
