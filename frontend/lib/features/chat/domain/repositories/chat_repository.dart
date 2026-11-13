import 'package:agro_bridge/features/chat/domain/entities/chat_entity.dart';

abstract class ChatRepository {
  Future<List<ChatThreadEntity>> getThreads();
  Future<List<ChatMessageEntity>> getMessages(String threadId);
  Future<ChatMessageEntity> sendMessage(String threadId, Map<String, dynamic> data);
}

