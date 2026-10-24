import 'package:flutter/material.dart';
import 'package:yaqin/localization/app_localization.dart';
import 'package:yaqin/models/models.dart';
import 'package:yaqin/services/proximity_engine.dart';
import 'package:yaqin/screens/chat_screen.dart';

class RadarScreen extends StatefulWidget {
  final String currentUserId;
  const RadarScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> with SingleTickerProviderStateMixin {
  late final ProximityEngine _engine;
  UserModel? _matchedUser;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _engine = ProximityEngine();
    _engine.startTracking(widget.currentUserId);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _engine.onProximityMatchTriggered.listen((user) {
      if (mounted) {
        setState(() {
          _matchedUser = user;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _engine.stop();
    super.dispose();
  }

  void _onSwipeLike() {
    if (_matchedUser == null) return;
    final partner = _matchedUser!;
    setState(() => _matchedUser = null);

    // Open temporary chat
    final chatId = '${widget.currentUserId}_${partner.uid}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chatId,
          currentUserId: widget.currentUserId,
          partnerName: partner.name,
        ),
      ),
    );
  }

  void _onSwipePass() {
    setState(() => _matchedUser = null);
  }

  @override
  Widget build(BuildContext context) {
    final loc = YaqinLocalization.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('radar')),
        centerTitle: true,
      ),
      body: _matchedUser != null
          ? _buildTinderCard(loc, theme, _matchedUser!)
          : _buildScanningRadar(loc, theme),
    );
  }

  Widget _buildScanningRadar(YaqinLocalization loc, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220 * _pulseController.value,
                    height: 220 * _pulseController.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primaryColor.withOpacity(1.0 - _pulseController.value),
                    ),
                  ),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [theme.primaryColor, theme.colorScheme.secondary],
                      ),
                    ),
                    child: const Icon(Icons.radar, size: 64, color: Colors.white),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              loc.translate('status_stationary'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTinderCard(YaqinLocalization loc, ThemeData theme, UserModel user) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                user.avatarUrl,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 280,
                  color: Colors.grey[800],
                  child: const Icon(Icons.person, size: 80, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${user.name}, ${user.age}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('10-15m', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(user.bio, style: const TextStyle(fontSize: 15, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: user.interests
                          .map((tag) => Chip(
                                label: Text(tag, style: const TextStyle(fontSize: 12)),
                                backgroundColor: theme.colorScheme.surface,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton(
                          heroTag: 'pass',
                          onPressed: _onSwipePass,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.close, color: Colors.redAccent, size: 32),
                        ),
                        FloatingActionButton(
                          heroTag: 'like',
                          onPressed: _onSwipeLike,
                          backgroundColor: theme.primaryColor,
                          child: const Icon(Icons.favorite, color: Colors.white, size: 32),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
