import 'package:agro_bridge/features/microfinance/domain/entities/credit_profile_entity.dart';

abstract class MicrofinanceRepository {
  Future<Map<String, dynamic>> getFarmerCreditProfile({String? farmerId});
  Future<Map<String, dynamic>> simulateEmi(double principal, double rate, int tenure);
  Future<LoanApplicationEntity> applyForLoan(Map<String, dynamic> data);
  Future<List<LoanApplicationEntity>> getLoanApplications({String? status});
  Future<LoanApplicationEntity> updateLoanStatus(String id, String status, {double? approvedAmount, String? mfsProvider});
}

