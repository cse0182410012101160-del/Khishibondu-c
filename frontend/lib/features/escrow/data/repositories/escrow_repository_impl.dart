import 'package:agro_bridge/features/escrow/domain/entities/escrow_entity.dart';
import 'package:agro_bridge/features/escrow/domain/repositories/escrow_repository.dart';
import 'package:agro_bridge/features/escrow/data/datasources/escrow_remote_data_source.dart';

class EscrowRepositoryImpl implements EscrowRepository {
  final EscrowRemoteDataSource _remoteDataSource;

  EscrowRepositoryImpl(this._remoteDataSource);

  @override
  Future<Map<String, dynamic>> fundEscrow(Map<String, dynamic> data) {
    return _remoteDataSource.fundEscrow(data);
  }

  @override
  Future<Map<String, dynamic>> releaseEscrow(String escrowId) {
    return _remoteDataSource.releaseEscrow(escrowId);
  }

  @override
  Future<DisputeEntity> raiseDispute(Map<String, dynamic> data) {
    return _remoteDataSource.raiseDispute(data);
  }

  @override
  Future<List<DisputeEntity>> getDisputes() {
    return _remoteDataSource.getDisputes();
  }

  @override
  Future<Map<String, dynamic>> resolveDispute(String disputeId, String decision, {String? adminNotes}) {
    return _remoteDataSource.resolveDispute(disputeId, decision, adminNotes: adminNotes);
  }
}
