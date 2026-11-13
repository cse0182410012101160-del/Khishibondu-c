import 'package:agro_bridge/features/traceability/domain/entities/traceability_entity.dart';

abstract class TraceabilityRepository {
  Future<TraceabilityEntity> getTraceability(String batchQrCode);
  Future<Map<String, dynamic>> generateBatchQr(String cropId);
}

