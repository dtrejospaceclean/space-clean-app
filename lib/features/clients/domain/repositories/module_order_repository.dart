/// The order the user set for an account's modules, kept on this device.
abstract interface class ModuleOrderRepository {
  /// Module routes in the user's order, or empty if they never reordered.
  List<String> get savedOrder;

  Future<void> saveOrder(List<String> routes);
}
