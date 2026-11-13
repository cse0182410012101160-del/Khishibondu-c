import 'package:agro_bridge/features/escrow/domain/entities/escrow_entity.dart';

abstract class EscrowRepository {
  Future<Map<String, dynamic>> fundEscrow(Map<String, dynamic> data);
  Future<Map<String, dynamic>> releaseEscrow(String escrowId);
  Future<DisputeEntity> raiseDispute(Map<String, dynamic> data);
  Future<List<DisputeEntity>> getDisputes();
  Future<Map<String, dynamic>> resolveDispute(String disputeId, String decision, {String? adminNotes});
}

