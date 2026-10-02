import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/module_order_repository.dart';

class ModuleOrderRepositoryImpl implements ModuleOrderRepository {
  const ModuleOrderRepositoryImpl(this._preferences);

  final SharedPreferences _preferences;

  static const _key = 'accounts.module_order';

  @override
  List<String> get savedOrder => _preferences.getStringList(_key) ?? const [];

  @override
  Future<void> saveOrder(List<String> routes) =>
      _preferences.setStringList(_key, routes);
}
