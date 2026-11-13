import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../bloc/chat_bloc.dart';
import 'chat_room_screen.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ChatThreadsScreen extends StatefulWidget {
  final UserEntity currentUser;
  const ChatThreadsScreen({super.key, required this.currentUser});

  @override
  State<ChatThreadsScreen> createState() => _ChatThreadsScreenState();
}

class _ChatThreadsScreenState extends State<ChatThreadsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(FetchChatThreadsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('chat')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ChatBloc>().add(FetchChatThreadsEvent()),
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatThreadsLoadedState) {
            final threads = state.threads;
            if (threads.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 54, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('No negotiation messages yet.', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final thread = threads[index];
                final otherPartyName = widget.currentUser.role == 'farmer' ? thread.buyerName : thread.farmerName;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    title: Text(otherPartyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                      thread.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRoomScreen(
                            threadId: thread.id,
                            otherPartyName: otherPartyName,
                            currentUser: widget.currentUser,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

