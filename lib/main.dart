import 'package:ei_positive_affirmations/model/recording.dart';
import 'package:ei_positive_affirmations/screens/OnBoardingScreen.dart';
import 'package:ei_positive_affirmations/screens/PlayScreen.dart';
import 'package:ei_positive_affirmations/screens/RecordingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

List<DeviceOrientation> orientation = [DeviceOrientation.portraitUp];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(orientation);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //     overlays: [SystemUiOverlay.bottom]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

////// Purple Color 483553
////// Gold Color D8CA67
