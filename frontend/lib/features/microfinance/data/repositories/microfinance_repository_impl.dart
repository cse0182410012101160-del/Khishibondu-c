import 'package:agro_bridge/features/microfinance/domain/entities/credit_profile_entity.dart';
import 'package:agro_bridge/features/microfinance/domain/repositories/microfinance_repository.dart';
import 'package:agro_bridge/features/microfinance/data/datasources/microfinance_remote_data_source.dart';
import 'package:agro_bridge/features/microfinance/data/models/credit_profile_model.dart';

class MicrofinanceRepositoryImpl implements MicrofinanceRepository {
  final MicrofinanceRemoteDataSource _remoteDataSource;

  MicrofinanceRepositoryImpl(this._remoteDataSource);

  @override
  Future<Map<String, dynamic>> getFarmerCreditProfile({String? farmerId}) async {
    final res = await _remoteDataSource.getFarmerCreditProfile(farmerId: farmerId);
    return {
      'farmer': res['farmer'],
      'creditProfile': CreditProfileModel.fromJson(res['creditProfile']),
      'partnerSchemes': res['partnerSchemes'] ?? [],
    };
  }

  @override
  Future<Map<String, dynamic>> simulateEmi(double principal, double rate, int tenure) {
    return _remoteDataSource.simulateEmi(principal, rate, tenure);
  }

  @override
  Future<LoanApplicationEntity> applyForLoan(Map<String, dynamic> data) {
    return _remoteDataSource.applyForLoan(data);
  }

  @override
  Future<List<LoanApplicationEntity>> getLoanApplications({String? status}) {
    return _remoteDataSource.getLoanApplications(status: status);
  }

  @override
  Future<LoanApplicationEntity> updateLoanStatus(String id, String status, {double? approvedAmount, String? mfsProvider}) {
    return _remoteDataSource.updateLoanStatus(id, status, approvedAmount: approvedAmount, mfsProvider: mfsProvider);
  }
}
