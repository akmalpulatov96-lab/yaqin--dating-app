import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yaqin/localization/app_localization.dart';
import 'package:yaqin/models/models.dart';
import 'package:yaqin/services/capsule_service.dart';
import 'package:yaqin/screens/chat_screen.dart';

class MapScreen extends StatefulWidget {
  final String currentUserId;
  const MapScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final CapsuleService _capsuleService = CapsuleService();
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDropCapsuleDialog() {
    final textController = TextEditingController();
    int lifespan = 2;
    bool isPhantom = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final loc = YaqinLocalization.of(ctx);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loc.translate('drop_capsule'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    maxLength: 150,
                    decoration: InputDecoration(
                      hintText: loc.translate('capsule_hint'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${loc.translate('capsule_lifespan')}: $lifespan ч.'),
                      Slider(
                        value: lifespan.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '$lifespan ч.',
                        onChanged: (val) => setModalState(() => lifespan = val.round()),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: Text(loc.translate('is_phantom')),
                    subtitle: const Text('Исчезает для всех после первого открытия'),
                    value: isPhantom,
                    activeColor: const Color(0xFF9D4EDD),
                    onChanged: (val) => setModalState(() => isPhantom = val),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_currentPosition == null) return;
                      await _capsuleService.dropCapsule(
                        authorId: widget.currentUserId,
                        authorName: 'User',
                        message: textController.text.trim(),
                        latitude: _currentPosition!.latitude,
                        longitude: _currentPosition!.longitude,
                        lifespanHours: lifespan,
                        isPhantom: isPhantom,
                      );
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(loc.translate('drop_now')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _inspectCapsule(CapsuleModel capsule) async {
    final loc = YaqinLocalization.of(context);
    if (_currentPosition == null) return;

    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      capsule.latitude,
      capsule.longitude,
    );

    if (distance > 20.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.translate('too_far')} (${distance.toStringAsFixed(1)}м)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Attempt unlocking
    bool unlocked = await _capsuleService.attemptUnlockCapsule(
      capsuleId: capsule.id,
      userId: widget.currentUserId,
      currentPos: _currentPosition!,
    );

    if (unlocked) {
      _showUnlockedDialog(capsule);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фантом уже был открыт кем-то другим и исчез!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showUnlockedDialog(CapsuleModel capsule) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              capsule.isPhantom ? Icons.auto_awesome : Icons.mark_email_read,
              color: capsule.isPhantom ? Colors.purpleAccent : Colors.pinkAccent,
            ),
            const SizedBox(width: 8),
            Text(capsule.isPhantom ? 'Фантом открыт!' : 'Капсула открыта!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Автор: ${capsule.authorName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(capsule.message, style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    chatId: 'capsule_${capsule.id}',
                    currentUserId: widget.currentUserId,
                    partnerName: capsule.authorName,
                  ),
                ),
              );
            },
            child: const Text('Открыть чат'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = YaqinLocalization.of(context);

    if (_isLoading || _currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    return Scaffold(
      body: StreamBuilder<List<CapsuleModel>>(
        stream: _capsuleService.getNearbyCapsules(),
        builder: (context, snapshot) {
          final capsules = snapshot.data ?? [];

          final markers = <Marker>[
            // User marker
            Marker(
              point: userLatLng,
              width: 50,
              height: 50,
              child: const Icon(Icons.my_location, color: Colors.blueAccent, size: 36),
            ),
            // Capsule markers
            ...capsules.map((c) {
              return Marker(
                point: LatLng(c.latitude, c.longitude),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => _inspectCapsule(c),
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.isPhantom ? Colors.purple : Colors.pinkAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (c.isPhantom ? Colors.purple : Colors.pinkAccent).withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      c.isPhantom ? Icons.bolt : Icons.mail,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              );
            }).toList(),
          ];

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLatLng,
              initialZoom: 16.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yaqin.dating',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showDropCapsuleDialog,
        icon: const Icon(Icons.add_location_alt),
        label: Text(loc.translate('drop_capsule')),
      ),
    );
  }
}
