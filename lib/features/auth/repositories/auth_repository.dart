import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/token_storage.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthRepository({Dio? dio, TokenStorage? tokenStorage})
      : _dio = dio ?? DioClient().dio,
        _tokenStorage = tokenStorage ?? TokenStorage();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print("request body: ${{
        'identifier': email,
        'password': password,
      }}");
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'identifier': email,
          'password': password,
        },
      );

      print("response data: ${response.data}");

      final data = response.data['data'];
      final tokens = AuthTokensModel.fromJson(data);
      final user = UserModel.fromJson(data['user']);

      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        userRole: user.role,
        userId: user.id,
      );

      return {'user': user, 'tokens': tokens};
    } on DioException catch (e) {
      print("DioException: ${e}");
      print("DioException response: ${e.response?.data}");
      final message = e.response?.data?['message'] ?? 'Login failed. Please check your credentials.';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
          'role': role,
        },
      );

      final data = response.data['data'];
      final tokens = AuthTokensModel.fromJson(data);
      final user = UserModel.fromJson(data['user']);

      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        userRole: user.role,
        userId: user.id,
      );

      return {'user': user, 'tokens': tokens};
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Registration failed. Please try again.';
      throw Exception(message);
    }
  }

  Future<UserModel> getMyProfile() async {
    try {
      final response = await _dio.get(ApiConstants.myProfile);
      final data = response.data['data'];
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to load user profile';
      throw Exception(message);
    }
  }

  Future<void> uploadKyc({
    required String documentType,
    required String documentNumber,
    required String documentUrl,
  }) async {
    try {
      await _dio.post(
        ApiConstants.uploadKyc,
        data: {
          'documentType': documentType,
          'documentNumber': documentNumber,
          'documentUrl': documentUrl,
        },
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'KYC upload failed';
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _dio.post(
          ApiConstants.logout,
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  Future<bool> checkAuthStatus() async {
    return await _tokenStorage.hasValidToken();
  }
}
