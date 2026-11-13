import 'package:agro_bridge/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> requestOtp(String phone);
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp);
  Future<UserEntity> register(Map<String, dynamic> data);
  Future<UserEntity> demoLogin(String role);
  Future<List<Map<String, dynamic>>> getDemoAccounts();
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
}

