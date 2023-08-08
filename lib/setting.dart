import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:provider/provider.dart';

class MusicSettings extends ChangeNotifier {
  bool _isMusicOn = true;

  bool get isMusicOn => _isMusicOn;

  void toggleMusic(BuildContext context, bool value) {
    _isMusicOn = value;
    notifyListeners();
    if (value) {
      FlameAudio.bgm.resume();
    } else {
      FlameAudio.bgm.pause();
    }
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          _buildSettingItem(
            title: 'Music',
            description: 'Toggle background music',
            value: context.watch<MusicSettings>().isMusicOn,
            onChanged: (value) => _toggleMusic(context, value),
          ),
        ],
      ),
    );
  }

  void _toggleMusic(BuildContext context, bool value) {
    context.read<MusicSettings>().toggleMusic(context, value);
  }

  Widget _buildSettingItem({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 5),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
          Divider(height: 10, color: Colors.grey),
        ],
      ),
    );
  }
}
