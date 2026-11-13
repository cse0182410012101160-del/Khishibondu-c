import 'package:agro_bridge/features/chat/domain/entities/chat_entity.dart';

class ChatThreadModel extends ChatThreadEntity {
  const ChatThreadModel({
    required super.id,
    required super.cropId,
    required super.farmerId,
    required super.farmerName,
    required super.buyerId,
    required super.buyerName,
    required super.lastMessage,
    required super.lastMessageAt,
    super.unreadCount = 0,
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    return ChatThreadModel(
      id: json['id'] ?? '',
      cropId: json['cropId'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? 'Farmer',
      buyerId: json['buyerId'] ?? '',
      buyerName: json['buyerName'] ?? 'Buyer',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageAt: json['lastMessageAt'] ?? '',
      unreadCount: json['unreadByFarmer'] ?? json['unreadByBuyer'] ?? 0,
    );
  }
}

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.threadId,
    required super.senderId,
    required super.senderRole,
    required super.senderName,
    required super.text,
    super.offerPricePerUnit,
    super.quantity,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      threadId: json['threadId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderRole: json['senderRole'] ?? 'buyer',
      senderName: json['senderName'] ?? 'User',
      text: json['text'] ?? '',
      offerPricePerUnit: (json['offerPricePerUnit'] != null)
          ? (json['offerPricePerUnit'] as num).toDouble()
          : null,
      quantity: (json['quantity'] != null) ? (json['quantity'] as num).toDouble() : null,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

