import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yaqin/localization/app_localization.dart';
import 'package:yaqin/models/models.dart';
import 'package:yaqin/main.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUserId;
  const ProfileScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firestore = FirebaseFirestore.instance;

  Future<void> _toggleStealth(bool value) async {
    await _firestore.collection('users').doc(widget.currentUserId).update({
      'isStealth': value,
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = YaqinLocalization.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('profile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => YaqinApp.toggleTheme(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(widget.currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = UserModel.fromMap(
            snapshot.data!.data() as Map<String, dynamic>,
            widget.currentUserId,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundImage: NetworkImage(user.avatarUrl),
                  backgroundColor: Colors.grey[700],
                ),
                const SizedBox(height: 16),
                Text(
                  '${user.name}, ${user.age}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  user.bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: user.interests
                      .map((t) => Chip(label: Text(t)))
                      .toList(),
                ),
                const SizedBox(height: 32),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: SwitchListTile(
                    title: Text(
                      loc.translate('stealth_mode'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(loc.translate('stealth_desc')),
                    value: user.isStealth,
                    activeColor: theme.primaryColor,
                    onChanged: (val) => _toggleStealth(val),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Язык / Забон'),
                    trailing: DropdownButton<String>(
                      value: Localizations.localeOf(context).languageCode,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'ru', child: Text('Русский')),
                        DropdownMenuItem(value: 'tg', child: Text('Тоҷикӣ')),
                      ],
                      onChanged: (code) {
                        if (code != null) {
                          YaqinApp.setLocale(context, Locale(code));
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
