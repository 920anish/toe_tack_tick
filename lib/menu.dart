import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:toe_tack_tick/setting.dart';

import 'choose.dart';


class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController titleAnimationController;
  late Animation<double> titleAnimation;
  bool _isRiveLoading = false; // Set to false to display the Rive animation immediately

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Register WidgetsBindingObserver
    loadBackgroundMusic();
    setupAnimation();
  }

  void setupAnimation() {
    titleAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    titleAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(
        parent: titleAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> loadBackgroundMusic() async {
    final musicSettings = Provider.of<MusicSettings>(context, listen: false);

    if (musicSettings.isMusicOn) {
      try {
        await FlameAudio.bgm.play('background.mp3');
      } catch (e) {
        print('Error loading background music: $e');
      }
    }

  }

  @override
  void dispose() {
    titleAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this); // Unregister WidgetsBindingObserver
    super.dispose();
  }

  // Override didChangeAppLifecycleState to pause/resume audio
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      FlameAudio.bgm.pause();
    } else if (state == AppLifecycleState.resumed) {
      FlameAudio.bgm.resume();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          if (!_isRiveLoading)
            RiveAnimation.asset(
              'assets/riv.riv',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              antialiasing: true,
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      'Toe Tack Tick!',
                      textStyle: TextStyle(
                        fontFamily: 'Hello Graduation',
                        fontSize: 60,
                        color: Colors.white,
                      ),
                      speed: Duration(milliseconds: 200),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                CustomButton(
                  onPressed: () {
                    FlameAudio.play('zapsplat_multimedia_button_click_bright_003_92100.mp3');
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChooseScreen()));
                  },
                  label: 'Play',
                ),
                SizedBox(height: 20),
                CustomButton(
                  onPressed: () {
                    FlameAudio.play('zapsplat_multimedia_button_click_bright_003_92100.mp3');
                    Navigator.push(context, MaterialPageRoute(builder: (_) =>SettingsScreen()));
                  },
                  label: 'Settings',
                ),
                SizedBox(height: 20),
                CustomButton(
                  onPressed: () {
                    FlameAudio.play('zapsplat_multimedia_button_click_bright_003_92100.mp3');
                    GoRouter.of(context).go('/about');
                  },
                  label: 'About',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.label,
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          color: isPressed ? Colors.green : Colors.blue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Hello Graduation',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
