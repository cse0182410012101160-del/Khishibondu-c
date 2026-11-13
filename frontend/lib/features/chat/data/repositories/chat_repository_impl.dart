import 'package:agro_bridge/features/chat/domain/entities/chat_entity.dart';
import 'package:agro_bridge/features/chat/domain/repositories/chat_repository.dart';
import 'package:agro_bridge/features/chat/data/datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ChatThreadEntity>> getThreads() => _remoteDataSource.getThreads();

  @override
  Future<List<ChatMessageEntity>> getMessages(String threadId) => _remoteDataSource.getMessages(threadId);

  @override
  Future<ChatMessageEntity> sendMessage(String threadId, Map<String, dynamic> data) =>
      _remoteDataSource.sendMessage(threadId, data);
}
