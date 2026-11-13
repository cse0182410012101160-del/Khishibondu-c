import 'package:agro_bridge/core/constants/api_endpoints.dart';
import 'package:agro_bridge/core/network/api_client.dart';
import 'package:agro_bridge/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> requestOtp(String phone);
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp);
  Future<UserModel> register(Map<String, dynamic> data);
  Future<Map<String, dynamic>> demoLogin(String role);
  Future<List<Map<String, dynamic>>> getDemoAccounts();
  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> requestOtp(String phone) async {
    final res = await _client.post(ApiEndpoints.requestOtp, data: {'phone': phone});
    return res.data;
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final res = await _client.post(ApiEndpoints.verifyOtp, data: {'phone': phone, 'otp': otp});
    return res.data;
  }

  @override
  Future<UserModel> register(Map<String, dynamic> data) async {
    final res = await _client.post(ApiEndpoints.register, data: data);
    return UserModel.fromJson(res.data['user']);
  }

  @override
  Future<Map<String, dynamic>> demoLogin(String role) async {
    final res = await _client.post(ApiEndpoints.demoLogin, data: {'role': role});
    return res.data;
  }

  @override
  Future<List<Map<String, dynamic>>> getDemoAccounts() async {
    final res = await _client.get(ApiEndpoints.demoAccounts);
    return List<Map<String, dynamic>>.from(res.data['accounts']);
  }

  @override
  Future<UserModel> getMe() async {
    final res = await _client.get(ApiEndpoints.me);
    return UserModel.fromJson(res.data['user']);
  }
}
