import 'package:agro_bridge/core/constants/api_endpoints.dart';
import 'package:agro_bridge/core/network/api_client.dart';
import '../models/escrow_model.dart';

abstract class EscrowRemoteDataSource {
  Future<Map<String, dynamic>> fundEscrow(Map<String, dynamic> data);
  Future<Map<String, dynamic>> releaseEscrow(String escrowId);
  Future<DisputeModel> raiseDispute(Map<String, dynamic> data);
  Future<List<DisputeModel>> getDisputes();
  Future<Map<String, dynamic>> resolveDispute(String disputeId, String decision, {String? adminNotes});
}

class EscrowRemoteDataSourceImpl implements EscrowRemoteDataSource {
  final ApiClient _client;

  EscrowRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> fundEscrow(Map<String, dynamic> data) async {
    final res = await _client.post(ApiEndpoints.fundEscrow, data: data);
    return res.data;
  }

  @override
  Future<Map<String, dynamic>> releaseEscrow(String escrowId) async {
    final res = await _client.post(ApiEndpoints.releaseEscrow(escrowId));
    return res.data;
  }

  @override
  Future<DisputeModel> raiseDispute(Map<String, dynamic> data) async {
    final res = await _client.post(ApiEndpoints.raiseDispute, data: data);
    return DisputeModel.fromJson(res.data['dispute']);
  }

  @override
  Future<List<DisputeModel>> getDisputes() async {
    final res = await _client.get(ApiEndpoints.disputes);
    final list = res.data['disputes'] as List;
    return list.map((d) => DisputeModel.fromJson(d)).toList();
  }

  @override
  Future<Map<String, dynamic>> resolveDispute(String disputeId, String decision, {String? adminNotes}) async {
    final res = await _client.put(
      ApiEndpoints.resolveDispute(disputeId),
      data: {'decision': decision, 'adminNotes': adminNotes},
    );
    return res.data;
  }
}

