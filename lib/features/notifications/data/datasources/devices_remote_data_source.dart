import '../../../../core/network/api_client.dart';

/// Talks to `/me/devices`, the phones a user gets pushes on. Throws
/// `ApiException`.
class DevicesRemoteDataSource {
  const DevicesRemoteDataSource(this._api);

  final ApiClient _api;

  static const _path = '/me/devices';

  Future<void> register({
    required String token,
    required String platform,
    required String language,
  }) => _api.post(
    _path,
    body: {'token': token, 'platform': platform, 'language': language},
  );

  /// FCM tokens contain ':', so the token is encoded into the path.
  Future<void> unregister(String token) =>
      _api.delete('$_path/${Uri.encodeComponent(token)}');
}
