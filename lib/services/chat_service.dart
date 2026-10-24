import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yaqin/models/models.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream messages for a specific session (pair or capsule room)
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Send standard text message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final msgDoc = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final message = ChatMessage(
      id: msgDoc.id,
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
    );

    await msgDoc.set(message.toMap());
  }

  // Share Meeting Pin marker
  Future<void> shareMeetingPin({
    required String chatId,
    required String senderId,
    required double latitude,
    required double longitude,
  }) async {
    final msgDoc = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final message = ChatMessage(
      id: msgDoc.id,
      senderId: senderId,
      text: '📍 Точка встречи / Нуқтаи вохӯрӣ',
      timestamp: DateTime.now(),
      isMeetingPin: true,
      pinLatitude: latitude,
      pinLongitude: longitude,
    );

    await msgDoc.set(message.toMap());
  }
}
