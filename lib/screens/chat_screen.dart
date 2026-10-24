import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yaqin/localization/app_localization.dart';
import 'package:yaqin/models/models.dart';
import 'package:yaqin/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String partnerName;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.currentUserId,
    required this.partnerName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _textController = TextEditingController();

  Future<void> _sendText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    await _chatService.sendMessage(
      chatId: widget.chatId,
      senderId: widget.currentUserId,
      text: text,
    );
  }

  Future<void> _sharePin() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _chatService.shareMeetingPin(
        chatId: widget.chatId,
        senderId: widget.currentUserId,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось получить координаты GPS')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = YaqinLocalization.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partnerName),
        actions: [
          IconButton(
            icon: const Icon(Icons.pin_drop, color: Colors.redAccent),
            tooltip: loc.translate('share_meeting_pin'),
            onPressed: _sharePin,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? theme.primaryColor
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (msg.isMeetingPin) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on, color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${msg.pinLatitude?.toStringAsFixed(4)}, ${msg.pinLongitude?.toStringAsFixed(4)}',
                                    style: TextStyle(
                                      color: isMe ? Colors.white : theme.textTheme.bodyMedium?.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              msg.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_location_alt, color: Colors.redAccent),
                    onPressed: _sharePin,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: loc.translate('type_message'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: theme.primaryColor),
                    onPressed: _sendText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
