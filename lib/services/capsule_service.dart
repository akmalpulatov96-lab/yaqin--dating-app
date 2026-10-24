import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yaqin/models/models.dart';

class CapsuleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream active unexpired capsules
  Stream<List<CapsuleModel>> getNearbyCapsules() {
    final now = Timestamp.now();
    return _firestore
        .collection('capsules')
        .where('expiresAt', isGreaterThan: now)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CapsuleModel.fromMap(doc.data(), doc.id))
          .where((c) => !(c.isPhantom && c.isOpened)) // Phantoms disappear once opened
          .toList();
    });
  }

  // Create standard or Phantom capsule
  Future<void> dropCapsule({
    required String authorId,
    required String authorName,
    required String message,
    required double latitude,
    required double longitude,
    required int lifespanHours,
    required bool isPhantom,
  }) async {
    final docRef = _firestore.collection('capsules').doc();
    final now = DateTime.now();
    final clampedHours = lifespanHours.clamp(1, 5);
    final expiresAt = now.add(Duration(hours: clampedHours));

    final capsule = CapsuleModel(
      id: docRef.id,
      authorId: authorId,
      authorName: authorName,
      message: message.length > 150 ? message.substring(0, 150) : message,
      latitude: latitude,
      longitude: longitude,
      createdAt: now,
      expiresAt: expiresAt,
      isPhantom: isPhantom,
      isOpened: false,
    );

    await docRef.set(capsule.toMap());
  }

  // Attempt unlocking a capsule within 15-20 meters
  Future<bool> attemptUnlockCapsule({
    required String capsuleId,
    required String userId,
    required Position currentPos,
  }) async {
    final docRef = _firestore.collection('capsules').doc(capsuleId);

    return await _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return false;

      final capsule = CapsuleModel.fromMap(snapshot.data()!, capsuleId);

      // Verify expiration
      if (DateTime.now().isAfter(capsule.expiresAt)) {
        transaction.delete(docRef);
        return false;
      }

      // Verify distance <= 20 meters
      double distance = Geolocator.distanceBetween(
        currentPos.latitude,
        currentPos.longitude,
        capsule.latitude,
        capsule.longitude,
      );

      if (distance > 20.0) {
        return false; // User too far
      }

      // If Phantom capsule: check if already claimed
      if (capsule.isPhantom) {
        if (capsule.isOpened) {
          return false; // Already vanished
        }
        // Claim and mark opened atomically
        transaction.update(docRef, {
          'isOpened': true,
          'openedBy': userId,
        });
      }

      return true;
    });
  }
}
