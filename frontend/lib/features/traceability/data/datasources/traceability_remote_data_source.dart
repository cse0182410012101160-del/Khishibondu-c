import 'package:agro_bridge/core/constants/api_endpoints.dart';
import 'package:agro_bridge/core/network/api_client.dart';
import '../models/traceability_model.dart';

abstract class TraceabilityRemoteDataSource {
  Future<TraceabilityModel> getTraceability(String batchQrCode);
  Future<Map<String, dynamic>> generateBatchQr(String cropId);
}

class TraceabilityRemoteDataSourceImpl implements TraceabilityRemoteDataSource {
  final ApiClient _client;

  TraceabilityRemoteDataSourceImpl(this._client);

  @override
  Future<TraceabilityModel> getTraceability(String batchQrCode) async {
    final res = await _client.get(ApiEndpoints.traceBatch(batchQrCode));
    return TraceabilityModel.fromJson(res.data);
  }

  @override
  Future<Map<String, dynamic>> generateBatchQr(String cropId) async {
    final res = await _client.post(ApiEndpoints.generateBatchQr, data: {'cropId': cropId});
    return res.data;
  }
}

