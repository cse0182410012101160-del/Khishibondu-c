import 'package:agro_bridge/core/constants/api_endpoints.dart';
import 'package:agro_bridge/core/network/api_client.dart';

class Phase2Api {
  final ApiClient _client;

  Phase2Api(this._client);

  Future<Map<String, dynamic>> assist(String question,
      {String language = 'bn'}) async {
    final response = await _client.post(ApiEndpoints.aiAssist, data: {
      'question': question,
      'language': language,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> verifyCropPhoto(String imageData,
      {String? cropType}) async {
    final response = await _client.post(ApiEndpoints.cropQualityCheck, data: {
      'imageData': imageData,
      'cropType': cropType,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getProcurement(
      {String? search, String? district}) async {
    final response = await _client.get(
      ApiEndpoints.procurement,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (district != null && district.isNotEmpty) 'district': district,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getNgoAnalytics() async {
    final response = await _client.get(ApiEndpoints.ngoAnalytics);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getMfiPortfolio() async {
    final response = await _client.get(ApiEndpoints.mfiPortfolio);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> fundSandboxPayment({
    required String orderId,
    required String paymentRail,
    required String payerMfsNumber,
    required String idempotencyKey,
  }) async {
    final response = await _client.post(ApiEndpoints.fundEscrow, data: {
      'orderId': orderId,
      'paymentRail': paymentRail,
      'payerMfsNumber': payerMfsNumber,
      'idempotencyKey': idempotencyKey,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getInputShop() async {
    final response = await _client.get(ApiEndpoints.inputShop);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> applyBnpl(
      {required String productId,
      required int quantity,
      required int tenureMonths}) async {
    final response = await _client.post(ApiEndpoints.bnplApplication, data: {
      'productId': productId,
      'quantity': quantity,
      'tenureMonths': tenureMonths,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getSensors() async {
    final response = await _client.get(ApiEndpoints.soilSensors);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getExportMatches({String? cropType}) async {
    final response =
        await _client.get(ApiEndpoints.exportMatches, queryParameters: {
      if (cropType != null && cropType.isNotEmpty) 'cropType': cropType,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> createExportInquiry(String matchId) async {
    final response = await _client
        .post(ApiEndpoints.exportInquiries, data: {'matchId': matchId});
    return Map<String, dynamic>.from(response.data as Map);
  }
}
