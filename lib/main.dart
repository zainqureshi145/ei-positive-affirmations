import 'package:ei_positive_affirmations/screens/OnBoardingScreen.dart';
import 'package:ei_positive_affirmations/screens/PlayScreen.dart';
import 'package:ei_positive_affirmations/screens/RecordingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<DeviceOrientation> orientation = [DeviceOrientation.portraitUp];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(orientation);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //     overlays: [SystemUiOverlay.bottom]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      //home: RecordingScreen(),
      //home: PlayScreen(),
      home: OnBoardingScreen(),
    );
  }
}
