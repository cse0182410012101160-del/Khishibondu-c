import 'package:agro_bridge/core/constants/api_endpoints.dart';
import 'package:agro_bridge/core/network/api_client.dart';
import 'package:agro_bridge/features/chat/data/models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatThreadModel>> getThreads();
  Future<List<ChatMessageModel>> getMessages(String threadId);
  Future<ChatMessageModel> sendMessage(String threadId, Map<String, dynamic> data);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient _client;

  ChatRemoteDataSourceImpl(this._client);

  @override
  Future<List<ChatThreadModel>> getThreads() async {
    final res = await _client.get(ApiEndpoints.chatThreads);
    final list = res.data['threads'] as List;
    return list.map((t) => ChatThreadModel.fromJson(t)).toList();
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String threadId) async {
    final res = await _client.get(ApiEndpoints.chatMessages(threadId));
    final list = res.data['messages'] as List;
    return list.map((m) => ChatMessageModel.fromJson(m)).toList();
  }

  @override
  Future<ChatMessageModel> sendMessage(String threadId, Map<String, dynamic> data) async {
    final res = await _client.post(ApiEndpoints.chatMessages(threadId), data: data);
    return ChatMessageModel.fromJson(res.data['message']);
  }
}

