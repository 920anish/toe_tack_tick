import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flame_audio/flame_audio.dart';
import 'play.dart';

class ChooseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          RiveAnimation.asset(
            'assets/space.riv',
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMarkButton(context, 'X'),
                SizedBox(height: 30),
                _buildMarkButton(context, 'O'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkButton(BuildContext context, String userMark) {
    return ElevatedButton(
      onPressed: () {
        _startGame(context, userMark);
        _playButtonClickSound();
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 5,
      ),
      child: Text(
        'Play as $userMark',
        style: TextStyle(
          fontFamily: 'Hello Graduation',
          fontSize: 28,
          color: Colors.white,
        ),
      ),
    );
  }

  void _startGame(BuildContext context, String userMark) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlayScreen(userMark: userMark),
      ),
    );
  }

  void _playButtonClickSound() {
    FlameAudio.play('button.mp3');
  }
}
