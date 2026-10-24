import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final int age;
  final String avatarUrl;
  final String bio;
  final List<String> interests;
  final bool isStealth;
  final double? latitude;
  final double? longitude;
  final DateTime? lastLocationUpdate;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.age,
    required this.avatarUrl,
    required this.bio,
    required this.interests,
    this.isStealth = false,
    this.latitude,
    this.longitude,
    this.lastLocationUpdate,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'age': age,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'interests': interests,
      'isStealth': isStealth,
      'latitude': latitude,
      'longitude': longitude,
      'lastLocationUpdate': lastLocationUpdate != null ? Timestamp.fromDate(lastLocationUpdate!) : null,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 18,
      avatarUrl: map['avatarUrl'] ?? '',
      bio: map['bio'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      isStealth: map['isStealth'] ?? false,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      lastLocationUpdate: map['lastLocationUpdate'] != null
          ? (map['lastLocationUpdate'] as Timestamp).toDate()
          : null,
    );
  }
}

class CapsuleModel {
  final String id;
  final String authorId;
  final String authorName;
  final String message;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isPhantom;
  final bool isOpened;
  final String? openedBy;

  CapsuleModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.message,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.expiresAt,
    this.isPhantom = false,
    this.isOpened = false,
    this.openedBy,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isPhantom': isPhantom,
      'isOpened': isOpened,
      'openedBy': openedBy,
    };
  }

  factory CapsuleModel.fromMap(Map<String, dynamic> map, String id) {
    return CapsuleModel(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      message: map['message'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      isPhantom: map['isPhantom'] ?? false,
      isOpened: map['isOpened'] ?? false,
      openedBy: map['openedBy'],
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isMeetingPin;
  final double? pinLatitude;
  final double? pinLongitude;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isMeetingPin = false,
    this.pinLatitude,
    this.pinLongitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isMeetingPin': isMeetingPin,
      'pinLatitude': pinLatitude,
      'pinLongitude': pinLongitude,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isMeetingPin: map['isMeetingPin'] ?? false,
      pinLatitude: (map['pinLatitude'] as num?)?.toDouble(),
      pinLongitude: (map['pinLongitude'] as num?)?.toDouble(),
    );
  }
}
