import 'api_client.dart';

/// Reads every page of a paginated list endpoint (`{ items, meta }`), 100 at a
/// time, and returns all items. Throws `ApiException`.
Future<List<Map<String, dynamic>>> fetchAllPages(
  ApiClient api,
  String path, {
  Map<String, dynamic> query = const {},
  int maxPages = 20,
}) async {
  final items = <Map<String, dynamic>>[];
  for (var page = 1; page <= maxPages; page++) {
    final data = await api.get(
      path,
      query: {...query, 'page': page, 'pageSize': 100},
    ) as Map;
    items.addAll(
      (data['items'] as List).map((e) => (e as Map).cast<String, dynamic>()),
    );
    final meta = data['meta'] as Map?;
    if (meta == null || meta['hasNextPage'] != true) break;
  }
  return items;
}
