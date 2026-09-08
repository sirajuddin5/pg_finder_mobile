import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;
  TokenStorage._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'pgfinder_access_token';
  static const String _refreshTokenKey = 'pgfinder_refresh_token';
  static const String _userRoleKey = 'pgfinder_user_role';
  static const String _userIdKey = 'pgfinder_user_id';

  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  String? _cachedUserRole;
  int? _cachedUserId;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userRole,
    int? userId,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    _cachedUserRole = userRole;
    _cachedUserId = userId;

    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    if (userRole != null) {
      await _secureStorage.write(key: _userRoleKey, value: userRole);
    }
    if (userId != null) {
      await _secureStorage.write(key: _userIdKey, value: userId.toString());
    }
  }

  Future<String?> getAccessToken() async {
    _cachedAccessToken ??= await _secureStorage.read(key: _accessTokenKey);
    return _cachedAccessToken;
  }

  Future<String?> getRefreshToken() async {
    _cachedRefreshToken ??= await _secureStorage.read(key: _refreshTokenKey);
    return _cachedRefreshToken;
  }

  Future<String?> getUserRole() async {
    _cachedUserRole ??= await _secureStorage.read(key: _userRoleKey);
    return _cachedUserRole;
  }

  Future<int?> getUserId() async {
    if (_cachedUserId != null) return _cachedUserId;
    final idStr = await _secureStorage.read(key: _userIdKey);
    if (idStr != null) {
      _cachedUserId = int.tryParse(idStr);
    }
    return _cachedUserId;
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedUserRole = null;
    _cachedUserId = null;

    await _secureStorage.deleteAll();
  }
}
