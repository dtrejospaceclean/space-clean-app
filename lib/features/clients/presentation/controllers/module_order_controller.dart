import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/clients_providers.dart';
import '../account_modules.dart';

/// The user's order for the account screen's modules (routes), the same in
/// every account. Empty until they reorder; see [fullOrder].
final moduleOrderProvider =
    NotifierProvider<ModuleOrderController, List<String>>(
      ModuleOrderController.new,
    );

class ModuleOrderController extends Notifier<List<String>> {
  @override
  List<String> build() => ref.watch(moduleOrderRepositoryProvider).savedOrder;

  /// Saves the modules the user can see, rearranged into [visible].
  Future<void> reorder(List<String> visible) async {
    state = reorderVisible(state, visible);
    await ref.read(moduleOrderRepositoryProvider).saveOrder(state);
  }
}
