import 'package:agro_bridge/core/constants/api_endpoints.dart';
import 'package:agro_bridge/core/network/api_client.dart';
import 'package:agro_bridge/features/marketplace/data/models/crop_model.dart';
import 'package:agro_bridge/core/network/offline_request_queue.dart';
import 'package:dio/dio.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<CropModel>> getCrops({
    String? category,
    String? division,
    String? search,
    String? farmerId,
  });
  Future<Map<String, dynamic>> getCropById(String id);
  Future<CropModel> createCrop(Map<String, dynamic> data);
  Future<BidModel> submitBid(String cropId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateBidStatus(String bidId, String status);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final ApiClient _client;
  final OfflineRequestQueue? _offlineQueue;

  MarketplaceRemoteDataSourceImpl(this._client, [this._offlineQueue]);

  @override
  Future<List<CropModel>> getCrops({
    String? category,
    String? division,
    String? search,
    String? farmerId,
  }) async {
    final query = <String, dynamic>{};
    if (category != null && category != 'All') query['category'] = category;
    if (division != null && division != 'All') query['division'] = division;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (farmerId != null) query['farmerId'] = farmerId;

    final res = await _client.get(ApiEndpoints.crops, queryParameters: query);
    final list = res.data['crops'] as List;
    return list.map((c) => CropModel.fromJson(c)).toList();
  }

  @override
  Future<Map<String, dynamic>> getCropById(String id) async {
    final res = await _client.get(ApiEndpoints.cropDetail(id));
    return res.data;
  }

  @override
  Future<CropModel> createCrop(Map<String, dynamic> data) async {
    try {
      final res = await _client.post(ApiEndpoints.crops, data: data);
      return CropModel.fromJson(res.data['crop']);
    } on DioException {
      await _offlineQueue?.enqueueListing(data);
      rethrow;
    }
  }

  @override
  Future<BidModel> submitBid(String cropId, Map<String, dynamic> data) async {
    try {
      final res =
          await _client.post(ApiEndpoints.submitBid(cropId), data: data);
      return BidModel.fromJson(res.data['bid']);
    } on DioException {
      await _offlineQueue?.enqueueBid(cropId, data);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateBidStatus(
      String bidId, String status) async {
    final res = await _client
        .put(ApiEndpoints.updateBidStatus(bidId), data: {'status': status});
    return res.data;
  }
}
