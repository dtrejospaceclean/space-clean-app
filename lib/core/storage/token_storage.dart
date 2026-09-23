import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
  );

  final String accessToken;
  final String refreshToken;
}

/// Persists the token pair in secure storage and keeps an in-memory copy so the
/// interceptor doesn't hit the keychain on every request.
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'auth.accessToken';
  static const _refreshKey = 'auth.refreshToken';

  AuthTokens? _cached;
  bool _loaded = false;

  final _sessionExpired = StreamController<void>.broadcast();

  /// Emits when [expireSession] ends the session. A plain [clear] (logout) doesn't.
  Stream<void> get sessionExpired => _sessionExpired.stream;

  Future<AuthTokens?> read() async {
    if (_loaded) return _cached;
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    _cached = access != null && refresh != null
        ? AuthTokens(accessToken: access, refreshToken: refresh)
        : null;
    _loaded = true;
    return _cached;
  }

  Future<void> save(AuthTokens tokens) async {
    _cached = tokens;
    _loaded = true;
    await _storage.write(key: _accessKey, value: tokens.accessToken);
    await _storage.write(key: _refreshKey, value: tokens.refreshToken);
  }

  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  /// Clears the tokens because the server rejected them, and notifies listeners.
  Future<void> expireSession() async {
    await clear();
    _sessionExpired.add(null);
  }

  Future<void> dispose() => _sessionExpired.close();
}
