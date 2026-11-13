import 'package:agro_bridge/core/storage/cache_service.dart';
import 'package:agro_bridge/features/auth/domain/entities/user_entity.dart';
import 'package:agro_bridge/features/auth/domain/repositories/auth_repository.dart';
import 'package:agro_bridge/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:agro_bridge/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  AuthRepositoryImpl(this._remoteDataSource, this._cacheService);

  @override
  Future<Map<String, dynamic>> requestOtp(String phone) {
    return _remoteDataSource.requestOtp(phone);
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final res = await _remoteDataSource.verifyOtp(phone, otp);
    if (res['token'] != null) {
      await _cacheService.saveToken(res['token']);
      if (res['user'] != null) {
        await _cacheService.saveUser(res['user']);
      }
    }
    return res;
  }

  @override
  Future<UserEntity> register(Map<String, dynamic> data) async {
    final user = await _remoteDataSource.register(data);
    await _cacheService.saveUser(user.toJson());
    return user;
  }

  @override
  Future<UserEntity> demoLogin(String role) async {
    final res = await _remoteDataSource.demoLogin(role);
    final user = UserModel.fromJson(res['user']);
    await _cacheService.saveToken(res['token']);
    await _cacheService.saveUser(user.toJson());
    return user;
  }

  @override
  Future<List<Map<String, dynamic>>> getDemoAccounts() {
    return _remoteDataSource.getDemoAccounts();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final cached = _cacheService.getUser();
    if (cached != null) {
      return UserModel.fromJson(cached);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _cacheService.clearAuth();
  }
}
