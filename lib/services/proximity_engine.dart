import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yaqin/models/models.dart';

class ProximityEngine {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastRecordedPosition;
  DateTime? _stationaryStartTime;

  // Configuration thresholds
  static const double matchDistanceMeters = 15.0;
  static const int stationaryTriggerMinutes = 10;
  static const double stationaryDriftRadiusMeters = 20.0;

  // Stream of triggered match profiles
  final _matchEventController = StreamController<UserModel>.broadcast();
  Stream<UserModel> get onProximityMatchTriggered => _matchEventController.stream;

  Future<void> startTracking(String currentUserId) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // Battery-optimized location settings: distance filter of 10m
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.balanced,
      distanceFilter: 10,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _processUserMovement(currentUserId, position);
    });
  }

  Future<void> _processUserMovement(String currentUserId, Position currentPos) async {
    // 1. Update user location in Firestore if not stealth
    final userDoc = await _firestore.collection('users').doc(currentUserId).get();
    if (!userDoc.exists) return;
    final currentUser = UserModel.fromMap(userDoc.data()!, currentUserId);

    if (!currentUser.isStealth) {
      await _firestore.collection('users').doc(currentUserId).update({
        'latitude': currentPos.latitude,
        'longitude': currentPos.longitude,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    }

    // 2. Evaluate stationary state for match trigger
    if (_lastRecordedPosition == null) {
      _lastRecordedPosition = currentPos;
      _stationaryStartTime = DateTime.now();
    } else {
      double movedDistance = Geolocator.distanceBetween(
        _lastRecordedPosition!.latitude,
        _lastRecordedPosition!.longitude,
        currentPos.latitude,
        currentPos.longitude,
      );

      if (movedDistance > stationaryDriftRadiusMeters) {
        // User relocated: reset stationary timer
        _lastRecordedPosition = currentPos;
        _stationaryStartTime = DateTime.now();
      } else {
        // User stationary: check if threshold reached
        final durationInSpot = DateTime.now().difference(_stationaryStartTime!);
        if (durationInSpot.inMinutes >= stationaryTriggerMinutes) {
          _scanForStationaryNearbyPartners(currentUser, currentPos);
        }
      }
    }
  }

  Future<void> _scanForStationaryNearbyPartners(UserModel currentUser, Position myPos) async {
    if (currentUser.isStealth) return;

    // Query active non-stealth users
    final query = await _firestore
        .collection('users')
        .where('isStealth', isEqualTo: false)
        .get();

    for (var doc in query.docs) {
      if (doc.id == currentUser.uid) continue;
      final nearbyUser = UserModel.fromMap(doc.data(), doc.id);

      if (nearbyUser.latitude == null || nearbyUser.longitude == null) continue;

      double distance = Geolocator.distanceBetween(
        myPos.latitude,
        myPos.longitude,
        nearbyUser.latitude!,
        nearbyUser.longitude!,
      );

      // Condition: within 10-15 meters
      if (distance <= matchDistanceMeters) {
        // Trigger Match Alert
        _matchEventController.add(nearbyUser);
        break; // Trigger for the closest partner
      }
    }
  }

  void stop() {
    _positionSubscription?.cancel();
    _matchEventController.close();
  }
}
