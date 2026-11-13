import 'package:agro_bridge/features/marketplace/domain/entities/crop_entity.dart';

abstract class MarketplaceRepository {
  Future<List<CropEntity>> getCrops({
    String? category,
    String? division,
    String? search,
    String? farmerId,
  });
  Future<Map<String, dynamic>> getCropById(String id);
  Future<CropEntity> createCrop(Map<String, dynamic> data);
  Future<BidEntity> submitBid(String cropId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateBidStatus(String bidId, String status);
}

