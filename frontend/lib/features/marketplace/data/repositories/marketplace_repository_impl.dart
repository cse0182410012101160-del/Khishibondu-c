import 'package:agro_bridge/features/marketplace/domain/entities/crop_entity.dart';
import 'package:agro_bridge/features/marketplace/domain/repositories/marketplace_repository.dart';
import '../datasources/marketplace_remote_data_source.dart';
import '../models/crop_model.dart';
import 'package:agro_bridge/core/storage/cache_service.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  MarketplaceRepositoryImpl(this._remoteDataSource, this._cacheService);

  @override
  Future<List<CropEntity>> getCrops({
    String? category,
    String? division,
    String? search,
    String? farmerId,
  }) async {
    try {
      final crops = await _remoteDataSource.getCrops(
        category: category,
        division: division,
        search: search,
        farmerId: farmerId,
      );
      // Cache for offline rural usage
      await _cacheService.cacheCrops(crops.map((c) => c.toJson()).toList());
      return crops;
    } catch (e) {
      // Fallback to offline cache
      final cached = _cacheService.getCachedCrops();
      if (cached != null) {
        return cached.map((c) => CropModel.fromJson(c)).toList();
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getCropById(String id) {
    return _remoteDataSource.getCropById(id);
  }

  @override
  Future<CropEntity> createCrop(Map<String, dynamic> data) {
    return _remoteDataSource.createCrop(data);
  }

  @override
  Future<BidEntity> submitBid(String cropId, Map<String, dynamic> data) {
    return _remoteDataSource.submitBid(cropId, data);
  }

  @override
  Future<Map<String, dynamic>> updateBidStatus(String bidId, String status) {
    return _remoteDataSource.updateBidStatus(bidId, status);
  }
}

