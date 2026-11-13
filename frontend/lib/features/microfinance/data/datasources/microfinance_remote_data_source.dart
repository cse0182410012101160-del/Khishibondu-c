import 'package:agro_bridge/core/constants/api_endpoints.dart';
import 'package:agro_bridge/core/network/api_client.dart';
import '../models/credit_profile_model.dart';

abstract class MicrofinanceRemoteDataSource {
  Future<Map<String, dynamic>> getFarmerCreditProfile({String? farmerId});
  Future<Map<String, dynamic>> simulateEmi(double principal, double rate, int tenure);
  Future<LoanApplicationModel> applyForLoan(Map<String, dynamic> data);
  Future<List<LoanApplicationModel>> getLoanApplications({String? status});
  Future<LoanApplicationModel> updateLoanStatus(String id, String status, {double? approvedAmount, String? mfsProvider});
}

class MicrofinanceRemoteDataSourceImpl implements MicrofinanceRemoteDataSource {
  final ApiClient _client;

  MicrofinanceRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> getFarmerCreditProfile({String? farmerId}) async {
    final res = await _client.get(ApiEndpoints.creditScore(farmerId));
    return res.data;
  }

  @override
  Future<Map<String, dynamic>> simulateEmi(double principal, double rate, int tenure) async {
    final res = await _client.post(
      ApiEndpoints.simulateEmi,
      data: {'principal': principal, 'annualRatePct': rate, 'tenureMonths': tenure},
    );
    return res.data['simulation'];
  }

  @override
  Future<LoanApplicationModel> applyForLoan(Map<String, dynamic> data) async {
    final res = await _client.post(ApiEndpoints.applyLoan, data: data);
    return LoanApplicationModel.fromJson(res.data['application']);
  }

  @override
  Future<List<LoanApplicationModel>> getLoanApplications({String? status}) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    final res = await _client.get(ApiEndpoints.loanApplications, queryParameters: query);
    final list = res.data['applications'] as List;
    return list.map((a) => LoanApplicationModel.fromJson(a)).toList();
  }

  @override
  Future<LoanApplicationModel> updateLoanStatus(String id, String status, {double? approvedAmount, String? mfsProvider}) async {
    final res = await _client.put(
      ApiEndpoints.updateLoanStatus(id),
      data: {'status': status, 'approvedAmount': approvedAmount, 'mfsProvider': mfsProvider},
    );
    return LoanApplicationModel.fromJson(res.data['application']);
  }
}

