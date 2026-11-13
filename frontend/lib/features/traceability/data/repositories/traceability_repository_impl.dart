import 'package:agro_bridge/features/traceability/domain/entities/traceability_entity.dart';
import 'package:agro_bridge/features/traceability/domain/repositories/traceability_repository.dart';
import 'package:agro_bridge/features/traceability/data/datasources/traceability_remote_data_source.dart';

class TraceabilityRepositoryImpl implements TraceabilityRepository {
  final TraceabilityRemoteDataSource _remoteDataSource;

  TraceabilityRepositoryImpl(this._remoteDataSource);

  @override
  Future<TraceabilityEntity> getTraceability(String batchQrCode) {
    return _remoteDataSource.getTraceability(batchQrCode);
  }

  @override
  Future<Map<String, dynamic>> generateBatchQr(String cropId) {
    return _remoteDataSource.generateBatchQr(cropId);
  }
}
