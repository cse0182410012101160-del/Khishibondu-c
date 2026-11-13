import 'package:equatable/equatable.dart';

class ChatThreadEntity extends Equatable {
  final String id;
  final String cropId;
  final String farmerId;
  final String farmerName;
  final String buyerId;
  final String buyerName;
  final String lastMessage;
  final String lastMessageAt;
  final int unreadCount;

  const ChatThreadEntity({
    required this.id,
    required this.cropId,
    required this.farmerId,
    required this.farmerName,
    required this.buyerId,
    required this.buyerName,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [id, cropId, lastMessageAt];
}

class ChatMessageEntity extends Equatable {
  final String id;
  final String threadId;
  final String senderId;
  final String senderRole;
  final String senderName;
  final String text;
  final double? offerPricePerUnit;
  final double? quantity;
  final String createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderRole,
    required this.senderName,
    required this.text,
    this.offerPricePerUnit,
    this.quantity,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, threadId, text, createdAt];
}

