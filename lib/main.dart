import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toe_tack_tick/menu.dart';
import 'package:toe_tack_tick/setting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load the music settings
  MusicSettings musicSettings = MusicSettings();
  await musicSettings.loadMusicSetting();

  runApp(
    ChangeNotifierProvider.value(
      value: musicSettings,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toe Tack Tick',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: MenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
