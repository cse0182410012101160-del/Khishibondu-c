import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agro_bridge/features/chat/domain/entities/chat_entity.dart';
import 'package:agro_bridge/features/chat/domain/repositories/chat_repository.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class FetchChatThreadsEvent extends ChatEvent {}

class FetchChatMessagesEvent extends ChatEvent {
  final String threadId;
  const FetchChatMessagesEvent(this.threadId);
  @override
  List<Object?> get props => [threadId];
}

class SendChatMessageEvent extends ChatEvent {
  final String threadId;
  final String text;
  final double? offerPrice;
  final double? quantity;
  const SendChatMessageEvent(this.threadId, this.text, {this.offerPrice, this.quantity});
  @override
  List<Object?> get props => [threadId, text, offerPrice, quantity];
}

// States
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatThreadsLoadedState extends ChatState {
  final List<ChatThreadEntity> threads;
  const ChatThreadsLoadedState(this.threads);
  @override
  List<Object?> get props => [threads];
}

class ChatMessagesLoadedState extends ChatState {
  final List<ChatMessageEntity> messages;
  final String threadId;
  const ChatMessagesLoadedState(this.messages, this.threadId);
  @override
  List<Object?> get props => [messages, threadId];
}

class ChatErrorState extends ChatState {
  final String message;
  const ChatErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;

  ChatBloc(this._repository) : super(ChatInitial()) {
    on<FetchChatThreadsEvent>(_onFetchThreads);
    on<FetchChatMessagesEvent>(_onFetchMessages);
    on<SendChatMessageEvent>(_onSendMessage);
  }

  Future<void> _onFetchThreads(FetchChatThreadsEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final threads = await _repository.getThreads();
      emit(ChatThreadsLoadedState(threads));
    } catch (e) {
      emit(ChatErrorState(e.toString()));
    }
  }

  Future<void> _onFetchMessages(FetchChatMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = await _repository.getMessages(event.threadId);
      emit(ChatMessagesLoadedState(messages, event.threadId));
    } catch (e) {
      emit(ChatErrorState(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendChatMessageEvent event, Emitter<ChatState> emit) async {
    try {
      await _repository.sendMessage(event.threadId, {
        'text': event.text,
        'offerPricePerUnit': event.offerPrice,
        'quantity': event.quantity,
      });
      add(FetchChatMessagesEvent(event.threadId));
    } catch (e) {
      emit(ChatErrorState(e.toString()));
    }
  }
}
